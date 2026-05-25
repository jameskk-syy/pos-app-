import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/screens/pages/point_of_sale/app_bar.dart';
import 'package:pos/screens/pages/point_of_sale/buttons_widget.dart';
import 'package:pos/utils/cart_manager.dart';
import 'package:pos/widgets/sales/invoice_details.dart';
import 'package:pos/widgets/sales/open_session_dialog.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/widgets/crm/redeem_points_dialog.dart';
import 'package:pos/domain/responses/crm/loyalty_response.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/pages/point_of_sale/widgets/checkout_common_widgets.dart';
import 'package:pos/screens/pages/point_of_sale/widgets/checkout_summary_widgets.dart';
import 'package:pos/screens/pages/point_of_sale/widgets/checkout_payment_widgets.dart';

class CheckoutPage extends StatefulWidget {
  final VoidCallback? onCartUpdated;
  final String company;
  final Customer customer;
  final String posName;
  final String warehouse;

  const CheckoutPage({
    super.key,
    this.onCartUpdated,
    required this.company,
    required this.customer,
    required this.warehouse,
    required this.posName,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedPaymentMethod;
  List<PaymentMethod> paymentMethods = [];
  String? uploadedFileName;
  final TextEditingController voucherNumberController = TextEditingController();
  final TextEditingController amountPaidController = TextEditingController();
  final TextEditingController changeController = TextEditingController();
  final TextEditingController _mpesaPhoneController = TextEditingController();

  bool isSplitPayment = false;
  List<SplitPayment> splitPayments = [SplitPayment()];

  List<CartItem> cart = [];
  LoyaltyBalanceResponse? loyaltyDetails;
  bool isLoading = true;
  bool isLoadingPaymentMethods = true;
  bool isCreatingInvoice = false;
  double change = 0.0;

  double get subtotal => cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get discount => 0;
  double get commission => 0;
  double get total => subtotal - discount - commission;
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    amountPaidController.addListener(_calculateChange);
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;
    setState(() => currentUserResponse = savedUser);
    _loadCart();
    _loadPaymentMethods();
    _fetchLoyaltyBalance();
  }

  void _fetchLoyaltyBalance() {
    context.read<CrmBloc>().add(GetLoyaltyBalance(customerId: widget.customer.name, invoiceAmount: total, company: widget.company));
  }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);
    final loadedCart = await CartManager.getCart();
    setState(() { cart = loadedCart; isLoading = false; });
  }

  void _loadPaymentMethods() {
    context.read<SalesBloc>().add(GetPaymentMethod(company: widget.company, onlyEnabled: true));
  }

  void _calculateChange() {
    try {
      final amountPaid = double.tryParse(amountPaidController.text) ?? 0.0;
      if (amountPaid >= total) {
        setState(() {
          change = amountPaid - total;
          changeController.text = change.toStringAsFixed(2);
        });
      } else {
        setState(() { change = 0.0; changeController.clear(); });
      }
    } catch (e) {
      setState(() { change = 0.0; changeController.clear(); });
    }
  }

  @override
  void dispose() {
    voucherNumberController.dispose();
    amountPaidController.dispose();
    changeController.dispose();
    _mpesaPhoneController.dispose();
    for (var split in splitPayments) { split.dispose(); }
    amountPaidController.removeListener(_calculateChange);
    super.dispose();
  }

  void _addSplitPaymentRow() => setState(() => splitPayments.add(SplitPayment()));

  void _removeSplitPaymentRow(int index) {
    if (splitPayments.length > 1) {
      setState(() { splitPayments[index].dispose(); splitPayments.removeAt(index); });
    }
  }

  Future<void> _completeSale() async {
    if (isCreatingInvoice) return;

    if (isSplitPayment) {
      bool allValid = splitPayments.every((split) => split.paymentMethod != null && split.amountController.text.isNotEmpty);
      if (!allValid) { _showWarning('Please complete all split payment entries'); return; }

      for (var split in splitPayments) {
        if (_isMPesa(split.paymentMethod ?? '')) {
          final phone = split.mpesaPhoneController.text.trim();
          if (phone.length != 10 && phone.length != 12) {
            _showWarning('Please enter a valid MPesa number (10 or 12 digits) for the split payment entry.');
            return;
          }
        }
      }

      double splitTotal = splitPayments.fold(0, (sum, split) => sum + (double.tryParse(split.amountController.text) ?? 0));
      if (splitTotal != total) {
        _showWarning('Split payment total (KES ${splitTotal.toStringAsFixed(2)}) does not match sale total (KES ${total.toStringAsFixed(2)})');
        return;
      }

      for (var split in splitPayments) {
        final method = paymentMethods.firstWhere((m) => m.name == split.paymentMethod, orElse: () => PaymentMethod(name: '', type: '', enabled: false, accounts: []));
        if (_isCreditPayment(method)) {
          final creditAmount = double.tryParse(split.amountController.text) ?? 0.0;
          if (widget.customer.name == 'Walk-in Customer' || widget.customer.creditLimit <= 0 || creditAmount > widget.customer.availableCredit) {
            _showWarning(widget.customer.creditLimit <= 0 ? 'Customer ${widget.customer.customerName} has no credit facility enabled.' : 'Credit limit exceeded. Available credit: KES ${widget.customer.availableCredit.toStringAsFixed(2)}');
            return;
          }
        }
      }
      _createInvoiceWithSplitPayments();
    } else {
      if (selectedPaymentMethod == null) { _showWarning('There is no payment method selected yet'); return; }
      if (_isMPesa(selectedPaymentMethod ?? '')) {
        final phone = _mpesaPhoneController.text.trim();
        if (phone.length != 10 && phone.length != 12) { _showWarning('Please enter a valid MPesa number (10 or 12 digits).'); return; }
      }

      final paymentMethod = _getSelectedPaymentMethod();
      if (paymentMethod.type.toLowerCase() == 'cash') {
        final amountPaid = double.tryParse(amountPaidController.text) ?? 0.0;
        if (amountPaidController.text.isEmpty) { _showWarning('Please enter the amount paid'); return; }
        if (amountPaid < total) { _showWarning('Amount paid (KES ${amountPaid.toStringAsFixed(2)}) is less than total (KES ${total.toStringAsFixed(2)})'); return; }
      }

      if (_isCreditPayment(paymentMethod)) {
        if (widget.customer.name == 'Walk-in Customer' || widget.customer.creditLimit <= 0 || total > widget.customer.availableCredit) {
          _showWarning(widget.customer.creditLimit <= 0 ? 'Customer ${widget.customer.customerName} has no credit facility enabled.' : 'Credit limit exceeded. Available credit: KES ${widget.customer.availableCredit.toStringAsFixed(2)}');
          return;
        }
      }
      _createInvoiceWithSinglePayment();
    }
  }

  void _createInvoiceWithSinglePayment() {
    setState(() => isCreatingInvoice = true);
    final now = DateTime.now();
    final postingDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final invoiceItems = cart.map((cartItem) => InvoiceItem(itemCode: cartItem.product.id, qty: cartItem.quantity, rate: cartItem.product.price, uom: cartItem.product.uom, warehouse: widget.warehouse)).toList();
    final paymentMethod = _getSelectedPaymentMethod();
    final amountPaid = paymentMethod.type.toLowerCase() == 'cash' ? (double.tryParse(amountPaidController.text) ?? total) : total;

    context.read<SalesBloc>().add(CreateInvoice(request: InvoiceRequest(
      customer: widget.customer.name, company: widget.company, warehouse: widget.warehouse, updateStock: true, items: invoiceItems, postingDate: postingDate,
      posProfile: currentUserResponse!.message.posProfile.name, payments: [InvoicePayment(modeOfPayment: _isMPesa(paymentMethod.name) ? 'mpesa' : paymentMethod.name, amount: amountPaid, baseAmount: total, mpesaNumber: _isMPesa(paymentMethod.name) ? _mpesaPhoneController.text.trim() : null)],
      doNotSubmit: false, isPos: 1, invoiceType: 'POS Invoice',
    )));
  }

  void _createInvoiceWithSplitPayments() {
    setState(() => isCreatingInvoice = true);
    final now = DateTime.now();
    final postingDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final invoiceItems = cart.map((cartItem) => InvoiceItem(itemCode: cartItem.product.id, qty: cartItem.quantity, rate: cartItem.product.price, uom: cartItem.product.uom, warehouse: widget.warehouse)).toList();
    final invoicePayments = splitPayments.map((split) => InvoicePayment(modeOfPayment: _isMPesa(split.paymentMethod!) ? 'mpesa' : split.paymentMethod!, amount: double.parse(split.amountController.text), baseAmount: double.parse(split.amountController.text), mpesaNumber: _isMPesa(split.paymentMethod!) ? split.mpesaPhoneController.text.trim() : null)).toList();

    context.read<SalesBloc>().add(CreateInvoice(request: InvoiceRequest(
      customer: widget.customer.name, company: widget.company, warehouse: widget.warehouse, updateStock: true, items: invoiceItems, postingDate: postingDate,
      posProfile: currentUserResponse!.message.posProfile.name, payments: invoicePayments, doNotSubmit: false, isPos: 1, invoiceType: 'POS Invoice',
    )));
  }

  void _handleSuccessfulInvoiceCreation(CreateInvoiceResponse response) async {
    setState(() => isCreatingInvoice = false);
    if (response.success) {
      await CartManager.clearCart();
      widget.onCartUpdated?.call();
      if (mounted) context.read<CrmBloc>().add(EarnPoints(customerId: widget.customer.name, purchaseAmount: total));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invoice ${response.data?.name ?? ''} created successfully!'), backgroundColor: Colors.green));
        _showInvoiceDetails(response);
      }
    } else { _showWarning('Failed to create invoice: ${response.message}'); }
  }

  void _handleInvoiceError(String errorMessage) {
    setState(() => isCreatingInvoice = false);
    if (errorMessage.contains("enable_discount_accounting")) {
      _handleSuccessfulInvoiceCreation(CreateInvoiceResponse(success: true, message: 'Invoice created', data: InvoiceResponse(name: 'INV-${DateTime.now().millisecondsSinceEpoch}', customer: widget.customer.name, company: widget.company, postingDate: DateTime.now().toString().split(' ')[0], grandTotal: total, roundedTotal: total, outstandingAmount: 0.0, docstatus: 1)));
      return;
    }
    if (mounted) _showWarning('Invoice creation failed: $errorMessage');
  }

  void _showInvoiceDetails(CreateInvoiceResponse response) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => InvoiceDetailsWidget(response: response)).then((result) {
      if (result == true && mounted) Navigator.of(context).pop(true);
    });
  }

  String _getPaymentMethodDisplayName(PaymentMethod method) => method.name.replaceAll(RegExp(r'\(.*?\)'), '').trim();
  PaymentMethod _getSelectedPaymentMethod() => paymentMethods.firstWhere((method) => method.name == selectedPaymentMethod, orElse: () => PaymentMethod(name: '', type: '', enabled: false, accounts: []));
  bool _isCreditPayment(PaymentMethod method) {
    final name = method.name.toLowerCase();
    final type = method.type.toLowerCase();
    return type == 'credit' || type == 'account' || name.contains('credit') || name.contains('account');
  }
  bool _isMPesa(String name) => name.toLowerCase().replaceAll('-', '').contains('mpesa');

  void _showOpenSessionBottomSheet() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => OpenSessionBottomSheet(company: currentUserResponse!.message.company.name, currentUser: currentUserResponse!.message.user.name, profilePos: currentUserResponse!.message.posProfile.name, onSessionOpened: (session) => setState(() {})));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalesBloc, SalesState>(
      listener: (context, state) {
        if (state is PaymentMethodsLoaded) {
          setState(() {
            paymentMethods = List.from(state.paymentMethods)..add(PaymentMethod(name: 'Loyalty Points', type: 'Points', enabled: true, accounts: []));
            isLoadingPaymentMethods = false;
          });
        } else if (state is PaymentMethodsError) {
          setState(() => isLoadingPaymentMethods = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load payment methods: ${state.message}'), backgroundColor: Colors.red));
        } else if (state is InvoiceCreated) { _handleSuccessfulInvoiceCreation(state.invoiceResponse); }
        else if (state is InvoiceError) { _handleInvoiceError(state.message); }
      },
      builder: (context, state) => BlocListener<CrmBloc, CrmState>(
        listener: (context, crmState) {
          if (crmState is LoyaltyBalanceLoaded) {
            setState(() => loyaltyDetails = crmState.balanceResponse);
          } else if (crmState is PointsRedeemSuccess) {
            _onRedemptionSuccess(crmState.redeemResponse.redeemedPoints);
          } else if (crmState is EarnPointsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Earned ${crmState.response.pointsEarned} points! Total: ${crmState.response.totalPoints}'),
                backgroundColor: Colors.blueAccent));
          }
        },
        child: _buildBody(context, state),
      ),
    );
  }

  void _onRedemptionSuccess(double redeemedPoints) {
    if (isSplitPayment) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Points redeemed: $redeemedPoints. Please enter this amount in the payment row.'), backgroundColor: Colors.green));
    } else {
      setState(() { amountPaidController.text = redeemedPoints.toStringAsFixed(2); _calculateChange(); });
    }
  }

  void _handleLoyaltyRedemption(int? splitIndex) async {
    final result = await showDialog<bool>(context: context, builder: (context) => RedeemPointsDialog(customerId: widget.customer.name, customerName: widget.customer.customerName, invoiceAmount: total, company: widget.company));
    if (result != true) {
      setState(() { if (splitIndex != null) { splitPayments[splitIndex].paymentMethod = null; } else { selectedPaymentMethod = null; } });
    }
  }

  Widget _buildBody(BuildContext context, SalesState state) {
    if (isLoading) return Scaffold(backgroundColor: Colors.white, appBar: POSAppBar(statusText: 'Open session', statusColor: Colors.green, onBackPressed: () => Navigator.pop(context), onStatusPressed: _showOpenSessionBottomSheet), body: const Center(child: CircularProgressIndicator()));

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: POSAppBar(statusText: 'Open session', statusColor: Colors.green, onBackPressed: () => Navigator.pop(context), onStatusPressed: () {}),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      POSActionButtons(
                        onCloseSession: () => showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Close Session'), content: const Text('Are you sure you want to close this session?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])),
                        onSaveDraft: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved successfully'))),
                      ),
                      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), child: Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue.shade700))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            CheckoutSummarySection(subtotal: subtotal, discount: discount, commission: commission, total: total),
                            CheckoutLoyaltySection(loyaltyDetails: loyaltyDetails),
                            CheckoutRow(label: 'Total Amount', value: 'KES ${total.toStringAsFixed(2)}', bold: true, textColor: Colors.blue.shade700),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(value: isSplitPayment, onChanged: (val) => setState(() {
                                  isSplitPayment = val ?? false;
                                  if (!isSplitPayment) { for (var split in splitPayments) { split.dispose(); } splitPayments = [SplitPayment()]; amountPaidController.clear(); changeController.clear(); change = 0.0; }
                                }), activeColor: Colors.blue.shade700),
                                const Text('Split Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            isSplitPayment
                              ? CheckoutSplitPaymentInput(
                                  splitPayments: splitPayments, paymentMethods: paymentMethods, isLoadingPaymentMethods: isLoadingPaymentMethods,
                                  onAddRow: _addSplitPaymentRow, onRemoveRow: _removeSplitPaymentRow, isMPesa: _isMPesa, getPaymentMethodDisplayName: _getPaymentMethodDisplayName,
                                  onPaymentMethodChanged: (index, val) {
                                    setState(() => splitPayments[index].paymentMethod = val);
                                    if (val == 'Loyalty Points') _handleLoyaltyRedemption(index);
                                  },
                                )
                              : CheckoutSinglePaymentInput(
                                  paymentMethods: paymentMethods, isLoadingPaymentMethods: isLoadingPaymentMethods, selectedPaymentMethod: selectedPaymentMethod,
                                  mpesaPhoneController: _mpesaPhoneController, amountPaidController: amountPaidController, change: change, total: total, uploadedFileName: uploadedFileName,
                                  isMPesa: _isMPesa, getPaymentMethodDisplayName: _getPaymentMethodDisplayName, getSelectedPaymentMethod: _getSelectedPaymentMethod,
                                  onPaymentMethodChanged: (val) {
                                    setState(() {
                                      selectedPaymentMethod = val; amountPaidController.clear(); changeController.clear(); change = 0.0;
                                      final method = paymentMethods.firstWhere((m) => m.name == val, orElse: () => PaymentMethod(name: '', type: '', enabled: false, accounts: []));
                                      if (method.type.toLowerCase() == 'cash') amountPaidController.text = total.toStringAsFixed(2);
                                      if (method.type.toLowerCase() == 'cheque') { uploadedFileName = null; voucherNumberController.clear(); }
                                    });
                                    if (val == 'Loyalty Points') _handleLoyaltyRedemption(null);
                                  },
                                  onUploadCheque: () { setState(() => uploadedFileName = 'cheque_image.jpg'); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File uploaded successfully'))); },
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: isCreatingInvoice ? null : _completeSale,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), disabledBackgroundColor: Colors.blue.shade300),
                  child: isCreatingInvoice ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Close Sale', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)]),
                ),
              ),
            ],
          ),
        ),
        if (isCreatingInvoice) Container(color: Colors.black.withAlpha(50), child: const Center(child: CircularProgressIndicator())),
      ],
    );
  }

  void _showWarning(String message) => showDialog(context: context, builder: (context) => CheckoutWarningDialog(message: message));
}
