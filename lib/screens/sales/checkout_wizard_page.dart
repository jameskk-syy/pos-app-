import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/requests/sales/get_customer_request.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/utils/cart_manager.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'package:pos/screens/sales/widgets/checkout_wizard_widgets.dart';
import 'package:pos/screens/sales/widgets/checkout_wizard_logic.dart';

class CheckoutWizardPage extends StatefulWidget {
  final double total;

  const CheckoutWizardPage({super.key, required this.total});

  @override
  State<CheckoutWizardPage> createState() => _CheckoutWizardPageState();
}

class _CheckoutWizardPageState extends State<CheckoutWizardPage> with CheckoutWizardLogic {
  @override int get currentStep => _currentStep;
  @override set currentStep(int v) => setState(() => _currentStep = v);
  @override String? get selectedCustomerId => _selectedCustomerId;
  @override set selectedCustomerId(String? v) => setState(() => _selectedCustomerId = v);
  @override String? get selectedCustomerName => _selectedCustomerName;
  @override set selectedCustomerName(String? v) => setState(() => _selectedCustomerName = v);
  @override Customer? get selectedCustomer => _selectedCustomer;
  @override set selectedCustomer(Customer? v) => setState(() => _selectedCustomer = v);
  @override List<Customer> get allCustomers => _allCustomers;
  @override set allCustomers(List<Customer> v) => setState(() => _allCustomers = v);
  @override List<Customer> get filteredCustomers => _filteredCustomers;
  @override set filteredCustomers(List<Customer> v) => setState(() => _filteredCustomers = v);
  @override bool get isLoadingCustomers => _isLoadingCustomers;
  @override set isLoadingCustomers(bool v) => setState(() => _isLoadingCustomers = v);
  @override List<Map<String, dynamic>> get paymentMethodsFromApi => _paymentMethodsFromApi;
  @override set paymentMethodsFromApi(List<Map<String, dynamic>> v) => setState(() => _paymentMethodsFromApi = v);
  @override bool get isLoadingPaymentMethods => _isLoadingPaymentMethods;
  @override set isLoadingPaymentMethods(bool v) => setState(() => _isLoadingPaymentMethods = v);
  @override bool get isCreatingInvoice => _isCreatingInvoice;
  @override set isCreatingInvoice(bool v) => setState(() => _isCreatingInvoice = v);
  @override CreateInvoiceResponse? get createdInvoice => _createdInvoice;
  @override set createdInvoice(CreateInvoiceResponse? v) => setState(() => _createdInvoice = v);
  @override late SalesBloc salesBloc;
  @override late CrmBloc crmBloc;
  
  int _currentStep = 0;
  String selectedPayment = '';
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  Customer? _selectedCustomer;
  bool _receiptPrinted = false;
  @override CurrentUserResponse? currentUserResponse;
  CreateInvoiceResponse? _createdInvoice;
  bool _isCreatingInvoice = false;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerSearchController = TextEditingController();
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoadingCustomers = false;
  bool showCustomerResults = false;
  List<Map<String, dynamic>> _paymentMethodsFromApi = [];
  bool _isLoadingPaymentMethods = false;
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _mpesaPhoneController = TextEditingController();
  double _changeAmount = 0.0;

  @override
  void initState() {
    super.initState();
    salesBloc = getIt<SalesBloc>();
    crmBloc = getIt<CrmBloc>();
    _loadCurrentUser().then((_) { if (mounted && currentUserResponse != null) { setupListeners(); _loadCustomers(); } });
    _amountPaidController.text = widget.total.toStringAsFixed(2);
    _amountPaidController.addListener(_calculateChange);
  }

  Future<void> _loadCurrentUser() async {
    final s = getIt<StorageService>();
    final u = await s.getString('current_user');
    if (u == null || !mounted) return;
    setState(() => currentUserResponse = CurrentUserResponse.fromJson(jsonDecode(u)));
    salesBloc.add(GetPaymentMethod(company: currentUserResponse!.message.company.name, onlyEnabled: false));
  }

  void _loadCustomers() {
    crmBloc.add(GetAllCustomers(custmoerRequest: CustomerRequest(
      searchTerm: '', customerGroup: '', territory: '', customerType: '', disabled: false,
      filterByCompanyTransactions: false, company: currentUserResponse!.message.company.name,
      limit: 20, offset: 0,
    )));
  }

  void _searchCustomers(String q) {
    setState(() => _filteredCustomers = q.isEmpty ? _allCustomers : _allCustomers.where((c) => c.name.toLowerCase().contains(q.toLowerCase()) || (c.emailId?.toLowerCase().contains(q.toLowerCase()) ?? false)).toList());
  }

  void _selectCustomer(Customer c) {
    setState(() { _selectedCustomer = c; _selectedCustomerId = c.name; _selectedCustomerName = c.customerName.isNotEmpty ? c.customerName : c.name; showCustomerResults = false; _customerSearchController.clear(); });
  }

  void _clearCustomerSelection() { setState(() { _selectedCustomer = null; _selectedCustomerId = null; _selectedCustomerName = null; }); }

  void _calculateChange() {
    final paid = double.tryParse(_amountPaidController.text) ?? 0.0;
    setState(() => _changeAmount = paid > widget.total ? paid - widget.total : 0.0);
  }

  Future<void> _completeOrder() async {
    if (_currentStep == 1 && _selectedCustomerId == null) { _msg('Please select a customer', Colors.red); return; }
    if (_currentStep == 2 && selectedPayment.isEmpty) { _msg('Please select a payment method', Colors.red); return; }
    if (_currentStep == 2 && _isMPesa(selectedPayment)) {
      final p = _mpesaPhoneController.text.trim();
      if (p.length != 10 && p.length != 12) { _msg('Invalid MPesa number', Colors.red); return; }
    }
    if (_currentStep == 2) {
      if (_isCreditPayment()) {
        final c = _selectedCustomer;
        if (c == null || c.name == 'Walk-in Customer' || c.creditLimit <= 0 || c.availableCredit < widget.total) { _showCreditLimitWarning(c?.creditLimit ?? 0, c?.availableCredit ?? 0, widget.total); return; }
      }
      await _createInvoice(); return;
    }
    if (_currentStep == 3 && _createdInvoice?.success == true) await CartManager.clearCart();
    if (_currentStep < _steps.length - 1) goToStep(_currentStep + 1);
  }

  void _msg(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m, style: const TextStyle(fontSize: 13)), backgroundColor: c));

  bool _isCreditPayment() {
    if (selectedPayment.isEmpty) return false;
    if (selectedPayment.toLowerCase().contains('credit') || selectedPayment.toLowerCase().contains('account')) return true;
    try {
      final m = _paymentMethodsFromApi.firstWhere((pm) => pm['name'] == selectedPayment);
      return (m['type']?.toString().toLowerCase() ?? '') == 'credit' || (m['type']?.toString().toLowerCase() ?? '') == 'account';
    } catch (_) { return false; }
  }

  bool _isMPesa(String n) => n.toLowerCase().replaceAll('-', '').contains('mpesa');

  void _showCreditLimitWarning(double l, double a, double t) {
    showDialog(context: context, builder: (ctx) => CreditLimitWarningDialog(limit: l, available: a, total: t, onConfirm: () => Navigator.pop(ctx)));
  }

  Future<void> _createInvoice() async {
    try {
      setState(() => _isCreatingInvoice = true);
      final items = await CartManager.getCart();
      final invItems = items.map((i) => InvoiceItem(itemCode: i.product.id, qty: i.quantity.toInt(), rate: i.product.price, uom: 'Nos', warehouse: currentUserResponse?.message.defaultWarehouse ?? 'Default Warehouse')).toList();
      salesBloc.add(CreateInvoice(request: InvoiceRequest(
        customer: _selectedCustomerId ?? 'Walk-in Customer', company: currentUserResponse?.message.company.name ?? 'Default Company',
        warehouse: currentUserResponse?.message.defaultWarehouse ?? 'Default Warehouse', updateStock: true, items: invItems,
        postingDate: DateFormat('yyyy-MM-dd').format(DateTime.now()), posProfile: currentUserResponse!.message.posProfile.name,
        payments: [InvoicePayment(modeOfPayment: _isMPesa(selectedPayment) ? 'mpesa' : selectedPayment, amount: widget.total, baseAmount: widget.total, mpesaNumber: _isMPesa(selectedPayment) ? _mpesaPhoneController.text : null)],
        doNotSubmit: false, isPos: 1, invoiceType: 'POS Invoice',
      )));
    } catch (e) { setState(() => _isCreatingInvoice = false); _msg('Error: $e', Colors.red); }
  }

  List<Step> get _steps => [
    Step(title: const Text('Review', style: TextStyle(fontSize: 12)), content: FutureBuilder<List<CartItem>>(future: CartManager.getCart(), builder: (c, s) => CheckoutReviewStep(cartItems: s.data ?? [], total: widget.total)), isActive: _currentStep == 0, state: _currentStep > 0 ? StepState.complete : StepState.indexed),
    Step(title: const Text('Customer', style: TextStyle(fontSize: 12)), content: CheckoutCustomerStep(selectedCustomerId: _selectedCustomerId, selectedCustomerName: _selectedCustomerName, filteredCustomers: _filteredCustomers, isLoadingCustomers: _isLoadingCustomers, showCustomerResults: showCustomerResults, searchController: _customerSearchController, onSearch: _searchCustomers, onSelect: _selectCustomer, onClear: _clearCustomerSelection, onTapSearch: () => setState(() => showCustomerResults = true)), isActive: _currentStep == 1, state: _currentStep > 1 ? StepState.complete : StepState.indexed),
    Step(title: const Text('Payment', style: TextStyle(fontSize: 12)), content: CheckoutPaymentStep(paymentMethods: _paymentMethodsFromApi, selectedPayment: selectedPayment, isLoading: _isLoadingPaymentMethods, total: widget.total, changeAmount: _changeAmount, amountPaidController: _amountPaidController, mpesaPhoneController: _mpesaPhoneController, onPaymentChanged: (v) => setState(() => selectedPayment = v ?? ''), isMPesa: _isMPesa(selectedPayment), customerName: _selectedCustomerName), isActive: _currentStep == 2),
    Step(title: const Text('Complete', style: TextStyle(fontSize: 12)), content: CheckoutCompleteStep(createdInvoice: _createdInvoice, customerName: _selectedCustomerName, customerId: _selectedCustomerId, selectedPayment: selectedPayment, paymentMethods: _paymentMethodsFromApi, onPrint: () { setState(() => _receiptPrinted = true); _msg('Sent to printer', Colors.green); }, onEmail: () => _msg('Sent via email', Colors.orange), receiptPrinted: _receiptPrinted, total: widget.total), isActive: _currentStep == 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), backgroundColor: Colors.blue[700], foregroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back, size: 22), onPressed: () => _currentStep > 0 ? setState(() => _currentStep--) : Navigator.pop(context))),
      body: Column(children: [
        CheckoutStepIndicator(currentStep: _currentStep),
        Expanded(child: Stepper(currentStep: _currentStep, onStepContinue: _completeOrder, onStepCancel: () => _currentStep > 0 ? goToStep(_currentStep - 1) : Navigator.pop(context), onStepTapped: (s) { if (s <= _currentStep) goToStep(s); }, steps: _steps, controlsBuilder: (c, d) => _buildStepperControls(d))),
        if (_currentStep < 3) _buildSummaryFooter(),
      ]),
    );
  }

  Widget _buildStepperControls(ControlsDetails d) {
    return Padding(padding: const EdgeInsets.only(top: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      if (_currentStep > 0) SizedBox(width: 100, child: ElevatedButton(onPressed: d.onStepCancel, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.grey[800], padding: const EdgeInsets.symmetric(vertical: 10), textStyle: const TextStyle(fontSize: 12)), child: const Text('Back'))) else const SizedBox(width: 100),
      SizedBox(width: 100, child: ElevatedButton(onPressed: _isCreatingInvoice ? null : d.onStepContinue, style: ElevatedButton.styleFrom(backgroundColor: _isCreatingInvoice ? Colors.grey : Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), textStyle: const TextStyle(fontSize: 12)), child: _isCreatingInvoice ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_currentStep == _steps.length - 1 ? 'Finish' : 'Continue'))),
    ]));
  }

  Widget _buildSummaryFooter() {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]!)), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(5), blurRadius: 8, offset: const Offset(0, -4))]),
      child: SafeArea(top: false, child: Column(children: [
        if (_selectedCustomerId != null && _currentStep >= 1) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.person, size: 16, color: Colors.blue), const SizedBox(width: 8), Expanded(child: Text(_selectedCustomerName ?? 'Unknown', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500)))])) ,
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_currentStep == 0 ? 'Order Total:' : _currentStep == 1 ? 'Customer Total:' : 'Amount to Pay:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), Text(widget.total.toStringAsFixed(2), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blue))]),
        if (_isCreatingInvoice) Padding(padding: const EdgeInsets.only(top: 8), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 8), Text('Creating invoice...', style: TextStyle(fontSize: 12, color: Colors.grey[600]))])),
      ])),
    );
  }

  @override
  void dispose() { _notesController.dispose(); _customerSearchController.dispose(); _amountPaidController.dispose(); _mpesaPhoneController.dispose(); super.dispose(); }
}
