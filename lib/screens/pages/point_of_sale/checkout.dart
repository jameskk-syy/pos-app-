import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/screens/pages/point_of_sale/app_bar.dart';
import 'package:pos/screens/pages/point_of_sale/buttons_widget.dart';
import 'package:pos/utils/cart_manager.dart';
import 'package:pos/widgets/invoice_details.dart';
import 'package:pos/widgets/open_session_dialog.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/widgets/redeem_points_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplitPayment {
  String? paymentMethod;
  TextEditingController amountController = TextEditingController();

  SplitPayment({this.paymentMethod});

  void dispose() {
    amountController.dispose();
  }
}

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

  bool isSplitPayment = false;
  List<SplitPayment> splitPayments = [SplitPayment()];

  List<CartItem> cart = [];
  double? _availablePoints;
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
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;

    setState(() {
      currentUserResponse = savedUser;
    });

    _loadCart();
    _loadPaymentMethods();
    _fetchLoyaltyBalance();
  }

  void _fetchLoyaltyBalance() {
    context.read<CrmBloc>().add(
      GetLoyaltyBalance(customerId: widget.customer.name),
    );
  }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);
    final loadedCart = await CartManager.getCart();
    setState(() {
      cart = loadedCart;
      isLoading = false;
    });
  }

  void _loadPaymentMethods() {
    context.read<SalesBloc>().add(
      GetPaymentMethod(company: widget.company, onlyEnabled: true),
    );
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
        setState(() {
          change = 0.0;
          changeController.clear();
        });
      }
    } catch (e) {
      setState(() {
        change = 0.0;
        changeController.clear();
      });
    }
  }

  @override
  void dispose() {
    voucherNumberController.dispose();
    amountPaidController.dispose();
    changeController.dispose();
    for (var split in splitPayments) {
      split.dispose();
    }
    amountPaidController.removeListener(_calculateChange);
    super.dispose();
  }

  void _addSplitPaymentRow() {
    setState(() {
      splitPayments.add(SplitPayment());
    });
  }

  void _removeSplitPaymentRow(int index) {
    if (splitPayments.length > 1) {
      setState(() {
        splitPayments[index].dispose();
        splitPayments.removeAt(index);
      });
    }
  }

  Future<void> _completeSale() async {
    if (isCreatingInvoice) return;

    if (isSplitPayment) {
      bool allValid = splitPayments.every(
        (split) =>
            split.paymentMethod != null &&
            split.amountController.text.isNotEmpty,
      );
      if (!allValid) {
        _showWarningDialog('Please complete all split payment entries');
        return;
      }

      // Calculate total from split payments
      double splitTotal = splitPayments.fold(0, (sum, split) {
        try {
          return sum + double.parse(split.amountController.text);
        } catch (e) {
          return sum;
        }
      });

      // Validate split total equals sale total
      if (splitTotal != total) {
        _showWarningDialog(
          'Split payment total (KES ${splitTotal.toStringAsFixed(2)}) does not match sale total (KES ${total.toStringAsFixed(2)})',
        );
        return;
      }

      // Check credit limit for split payments
      for (var split in splitPayments) {
        final method = paymentMethods.firstWhere(
          (m) => m.name == split.paymentMethod,
          orElse: () =>
              PaymentMethod(name: '', type: '', enabled: false, accounts: []),
        );
        if (_isCreditPayment(method)) {
          final creditAmount =
              double.tryParse(split.amountController.text) ?? 0.0;
          if (widget.customer.creditLimit == 0) {
            _showWarningDialog(
              'Customer ${widget.customer.customerName} has no credit limit enabled.',
            );
            return;
          }
          if (creditAmount > widget.customer.availableCredit) {
            _showWarningDialog(
              'Credit limit exceeded. Available credit: KES ${widget.customer.availableCredit.toStringAsFixed(2)}',
            );
            return;
          }
        }
      }

      // Create invoice with split payments
      _createInvoiceWithSplitPayments();
    } else {
      if (selectedPaymentMethod == null) {
        _showWarningDialog('There is no payment method selected yet');
        return;
      }

      // Check if it's cash payment
      final paymentMethod = _getSelectedPaymentMethod();
      if (paymentMethod.type.toLowerCase() == 'cash') {
        // Validate cash payment
        final amountPaid = double.tryParse(amountPaidController.text) ?? 0.0;
        if (amountPaidController.text.isEmpty) {
          _showWarningDialog('Please enter the amount paid');
          return;
        }

        if (amountPaid < total) {
          _showWarningDialog(
            'Amount paid (KES ${amountPaid.toStringAsFixed(2)}) is less than total (KES ${total.toStringAsFixed(2)})',
          );
          return;
        }
      }

      // Check credit limit for single payment
      if (_isCreditPayment(paymentMethod)) {
        if (widget.customer.creditLimit == 0) {
          _showWarningDialog(
            'Customer ${widget.customer.customerName} has no credit limit enabled.',
          );
          return;
        }
        if (total > widget.customer.availableCredit) {
          _showWarningDialog(
            'Credit limit exceeded. Available credit: KES ${widget.customer.availableCredit.toStringAsFixed(2)}',
          );
          return;
        }
      }

      // Create invoice with single payment
      _createInvoiceWithSinglePayment();
    }
  }

  void _createInvoiceWithSinglePayment() {
    setState(() {
      isCreatingInvoice = true;
    });

    final now = DateTime.now();
    final postingDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final invoiceItems = cart.map((cartItem) {
      return InvoiceItem(
        itemCode: cartItem.product.id,
        qty: cartItem.quantity,
        rate: cartItem.product.price,
        uom: cartItem.product.uom,
        warehouse: widget.warehouse,
      );
    }).toList();

    final paymentMethod = _getSelectedPaymentMethod();
    final isCash = paymentMethod.type.toLowerCase() == 'cash';
    final amountPaid = isCash
        ? (double.tryParse(amountPaidController.text) ?? total)
        : total;

    final invoiceRequest = InvoiceRequest(
      customer: widget.customer.name,
      company: widget.company,
      warehouse: widget.warehouse,
      updateStock: true,
      items: invoiceItems,
      postingDate: postingDate,
      posProfile: currentUserResponse!.message.posProfile.name,
      payments: [
        InvoicePayment(
          modeOfPayment: paymentMethod.name,
          amount: amountPaid,
          baseAmount: total,
        ),
      ],
      doNotSubmit: false,
      isPos: 1,
      invoiceType: 'Sales',
    );

    context.read<SalesBloc>().add(CreateInvoice(request: invoiceRequest));
  }

  void _createInvoiceWithSplitPayments() {
    setState(() {
      isCreatingInvoice = true;
    });

    final now = DateTime.now();
    final postingDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final invoiceItems = cart.map((cartItem) {
      return InvoiceItem(
        itemCode: cartItem.product.id,
        qty: cartItem.quantity,
        rate: cartItem.product.price,
        uom: cartItem.product.uom,
        warehouse: widget.warehouse,
      );
    }).toList();

    final invoicePayments = splitPayments.map((split) {
      return InvoicePayment(
        modeOfPayment: split.paymentMethod!,
        amount: double.parse(split.amountController.text),
        baseAmount: double.parse(split.amountController.text),
      );
    }).toList();

    final invoiceRequest = InvoiceRequest(
      customer: widget.customer.name,
      company: widget.company,
      warehouse: widget.warehouse,
      updateStock: true,
      items: invoiceItems,
      postingDate: postingDate,
      posProfile: currentUserResponse!.message.posProfile.name,
      payments: invoicePayments,
      doNotSubmit: false,
      isPos: 1,
      invoiceType: 'Sales',
    );

    context.read<SalesBloc>().add(CreateInvoice(request: invoiceRequest));
  }

  void _handleSuccessfulInvoiceCreation(CreateInvoiceResponse response) async {
    setState(() {
      isCreatingInvoice = false;
    });

    if (response.success) {
      // Clear cart
      await CartManager.clearCart();
      widget.onCartUpdated?.call();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invoice ${response.data?.name ?? ''} created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        _showInvoiceDetails(response);
      }
    } else {
      _showWarningDialog('Failed to create invoice: ${response.message}');
    }
  }

  void _handleInvoiceError(String errorMessage) {
    setState(() {
      isCreatingInvoice = false;
    });

    if (mounted) {
      _showWarningDialog('Invoice creation failed: $errorMessage');
    }
  }

  void _showInvoiceDetails(CreateInvoiceResponse response) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoiceDetailsWidget(response: response),
    ).then((_) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  String _getPaymentMethodDisplayName(PaymentMethod method) {
    return '${method.name} (${method.type})';
  }

  PaymentMethod _getSelectedPaymentMethod() {
    return paymentMethods.firstWhere(
      (method) => method.name == selectedPaymentMethod,
      orElse: () =>
          PaymentMethod(name: '', type: '', enabled: false, accounts: []),
    );
  }

  bool get _isCashPaymentSelected {
    if (selectedPaymentMethod == null) return false;
    final method = _getSelectedPaymentMethod();
    return method.type.toLowerCase() == 'cash';
  }

  bool _isCreditPayment(PaymentMethod method) {
    return method.type.toLowerCase() == 'credit';
  }

  void _showOpenSessionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return OpenSessionBottomSheet(
          company: currentUserResponse!.message.company.name,
          currentUser: currentUserResponse!.message.user.name,
          profilePos: currentUserResponse!.message.posProfile.name,
          onSessionOpened: (session) {
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalesBloc, SalesState>(
      listener: (context, state) {
        if (state is PaymentMethodsLoaded) {
          setState(() {
            paymentMethods = List.from(state.paymentMethods);
            // Append Loyalty Points as a manual payment method
            paymentMethods.add(
              PaymentMethod(
                name: 'Loyalty Points',
                type: 'Points',
                enabled: true,
                accounts: [],
              ),
            );
            isLoadingPaymentMethods = false;
          });
        } else if (state is PaymentMethodsError) {
          setState(() {
            isLoadingPaymentMethods = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load payment methods: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is InvoiceCreated) {
          _handleSuccessfulInvoiceCreation(state.invoiceResponse);
        } else if (state is InvoiceError) {
          _handleInvoiceError(state.message);
        }
      },
      builder: (context, state) {
        return BlocListener<CrmBloc, CrmState>(
          listener: (context, crmState) {
            if (crmState is LoyaltyBalanceLoaded) {
              setState(() {
                _availablePoints = crmState.balanceResponse.pointsBalance;
              });
            } else if (crmState is PointsRedeemSuccess) {
              _onRedemptionSuccess(crmState.redeemResponse.redeemedPoints);
            }
          },
          child: _buildBody(context, state),
        );
      },
    );
  }

  void _onRedemptionSuccess(double redeemedPoints) {
    if (isSplitPayment) {
      // Find the row that was being edited - this is tricky without tracking focus
      // For now, let's assume it's the last one touched or show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Points redeemed: $redeemedPoints. Please enter this amount in the payment row.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        amountPaidController.text = redeemedPoints.toStringAsFixed(2);
        _calculateChange();
      });
    }
  }

  void _handleLoyaltyRedemption(int? splitIndex) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RedeemPointsDialog(
        customerId: widget.customer.name,
        customerName: widget.customer.customerName,
      ),
    );

    if (result != true) {
      // Reset selection if cancelled
      setState(() {
        if (splitIndex != null) {
          splitPayments[splitIndex].paymentMethod = null;
        } else {
          selectedPaymentMethod = null;
        }
      });
    }
  }

  Widget _buildBody(BuildContext context, SalesState state) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: POSAppBar(
          statusText: 'Open session',
          statusColor: Colors.green,
          onBackPressed: () => Navigator.pop(context),
          onStatusPressed: _showOpenSessionBottomSheet,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: POSAppBar(
            statusText: 'Open session',
            statusColor: Colors.green,
            onBackPressed: () => Navigator.pop(context),
            onStatusPressed: () {},
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      POSActionButtons(
                        onCloseSession: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Close Session'),
                              content: const Text(
                                'Are you sure you want to close this session?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        onSaveDraft: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Draft saved successfully'),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Row(
                          children: [
                            Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildRow(
                              'Subtotal',
                              'KES ${subtotal.toStringAsFixed(2)}',
                            ),
                            _buildRow(
                              'Product Discount',
                              'KES ${discount.toStringAsFixed(2)}',
                            ),
                            _buildRow(
                              'Product Commission',
                              'KES ${commission.toStringAsFixed(2)}',
                            ),
                            _buildRow(
                              'Sales Amount',
                              'KES ${total.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            if (_availablePoints != null)
                              _buildRow(
                                'Available Points',
                                '${_availablePoints!.toStringAsFixed(0)} pts',
                                textColor: Colors.blue.shade700,
                              ),
                            _buildRow(
                              'Total Amount',
                              'KES ${total.toStringAsFixed(2)}',
                              bold: true,
                              textColor: Colors.blue.shade700,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: isSplitPayment,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isSplitPayment = value ?? false;
                                      if (!isSplitPayment) {
                                        for (var split in splitPayments) {
                                          split.dispose();
                                        }
                                        splitPayments = [SplitPayment()];
                                        amountPaidController.clear();
                                        changeController.clear();
                                        change = 0.0;
                                      }
                                    });
                                  },
                                  activeColor: Colors.blue.shade700,
                                ),
                                const Text(
                                  'Split Payment',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (isSplitPayment) ...[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Payment Method',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Amount',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 40),
                                        ],
                                      ),
                                    ),

                                    ...List.generate(splitPayments.length, (
                                      index,
                                    ) {
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border:
                                              index < splitPayments.length - 1
                                              ? Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: isLoadingPaymentMethods
                                                    ? const Center(
                                                        child: SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              ),
                                                        ),
                                                      )
                                                    : DropdownButtonHideUnderline(
                                                        child: DropdownButton<String>(
                                                          value:
                                                              splitPayments[index]
                                                                  .paymentMethod,
                                                          hint: const Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                ),
                                                            child: Text(
                                                              'Select',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                          ),
                                                          isExpanded: true,
                                                          icon: Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  right: 8,
                                                                ),
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              size: 20,
                                                              color: Colors
                                                                  .grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                          items: paymentMethods.map((
                                                            PaymentMethod
                                                            method,
                                                          ) {
                                                            return DropdownMenuItem<
                                                              String
                                                            >(
                                                              value:
                                                                  method.name,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8,
                                                                    ),
                                                                child: Text(
                                                                  _getPaymentMethodDisplayName(
                                                                    method,
                                                                  ),
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                          onChanged: (String? newValue) {
                                                            setState(() {
                                                              splitPayments[index]
                                                                      .paymentMethod =
                                                                  newValue;
                                                            });
                                                            if (newValue ==
                                                                'Loyalty Points') {
                                                              _handleLoyaltyRedemption(
                                                                index,
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            Expanded(
                                              flex: 2,
                                              child: TextField(
                                                controller: splitPayments[index]
                                                    .amountController,
                                                keyboardType:
                                                    TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                decoration: InputDecoration(
                                                  hintText: '0.00',
                                                  hintStyle: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  isDense: true,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                                onChanged: (_) {
                                                  // Re-calculate if needed
                                                },
                                              ),
                                            ),

                                            SizedBox(
                                              width: 40,
                                              child: IconButton(
                                                onPressed: () =>
                                                    _removeSplitPaymentRow(
                                                      index,
                                                    ),
                                                icon: Icon(
                                                  Icons.close,
                                                  size: 18,
                                                  color:
                                                      splitPayments.length > 1
                                                      ? Colors.red.shade400
                                                      : Colors.grey.shade300,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _addSplitPaymentRow,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Row'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            if (!isSplitPayment) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Payment Method',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: isLoadingPaymentMethods
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Loading payment methods...',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : paymentMethods.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'No payment methods available',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      )
                                    : DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedPaymentMethod,
                                          hint: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              'Select Payment Method',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          isExpanded: true,
                                          icon: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            child: Icon(
                                              Icons.arrow_drop_down,
                                              size: 24,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          items: paymentMethods.map((
                                            PaymentMethod method,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: method.name,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                child: Text(
                                                  _getPaymentMethodDisplayName(
                                                    method,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedPaymentMethod = newValue;
                                              amountPaidController.clear();
                                              changeController.clear();
                                              change = 0.0;

                                              final selectedMethod =
                                                  paymentMethods.firstWhere(
                                                    (method) =>
                                                        method.name == newValue,
                                                    orElse: () => PaymentMethod(
                                                      name: '',
                                                      type: '',
                                                      enabled: false,
                                                      accounts: [],
                                                    ),
                                                  );

                                              if (selectedMethod.type
                                                      .toLowerCase() ==
                                                  'cash') {
                                                amountPaidController.text =
                                                    total.toStringAsFixed(2);
                                              }

                                              // Handle cheque specifically
                                              if (selectedMethod.type
                                                      .toLowerCase() ==
                                                  'cheque') {
                                                uploadedFileName = null;
                                                voucherNumberController.clear();
                                              }
                                            });

                                            if (newValue == 'Loyalty Points') {
                                              _handleLoyaltyRedemption(null);
                                            }
                                          },
                                        ),
                                      ),
                              ),

                              // Amount Paid and Change fields for cash payment
                              if (_isCashPaymentSelected) ...[
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Amount Paid',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(
                                            color: Colors.red.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: amountPaidController,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter amount paid',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixText: 'KES ',
                                    prefixStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),

                                if (change > 0) ...[
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Change',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'KES ${change.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],

                              if (selectedPaymentMethod != null) ...[
                                if (_getSelectedPaymentMethod().type
                                        .toLowerCase() ==
                                    'cheque') ...[
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        uploadedFileName = 'cheque_image.jpg';
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'File uploaded successfully',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade700,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.cloud_upload_outlined,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Click to upload a file',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            uploadedFileName ?? 'Max size: 5MB',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: isCreatingInvoice ? null : _completeSale,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    disabledBackgroundColor: Colors.blue.shade300,
                  ),
                  child: isCreatingInvoice
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Close Sale',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),

        if (isCreatingInvoice)
          Container(
            color: Colors.black.withAlpha(50),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool bold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 8),

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Warning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
