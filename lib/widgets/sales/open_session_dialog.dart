import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/models/pos_session_model.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/widgets/sales/open_session_widgets.dart';

class OpenSessionBottomSheet extends StatefulWidget {
  final String company;
  final String profilePos;
  final String currentUser;
  final Function(POSSessionResponse?) onSessionOpened;

  const OpenSessionBottomSheet({super.key, required this.company, required this.currentUser, required this.onSessionOpened, required this.profilePos});

  @override
  State<OpenSessionBottomSheet> createState() => _OpenSessionBottomSheetState();
}

class _OpenSessionBottomSheetState extends State<OpenSessionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _posProfileController = TextEditingController();
  final List<Map<String, dynamic>> _balanceDetails = [];
  String? _selectedPaymentMethod;
  final TextEditingController _amountController = TextEditingController();
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoadingPaymentMethods = false;
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _fetchPaymentMethods();
    }
  }

  void _fetchPaymentMethods() {
    if (!mounted) return;
    setState(() => _isLoadingPaymentMethods = true);
    try {
      context.read<SalesBloc>().add(GetPaymentMethod(company: widget.company, onlyEnabled: true));
    } catch (e) {
      if (mounted) setState(() => _isLoadingPaymentMethods = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _posProfileController.text = widget.profilePos;
    _amountController.text = "0.00";
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalesBloc, SalesState>(
      listener: (context, state) async {
        if (state is PaymentMethodsLoaded) {
          setState(() {
            _paymentMethods = state.paymentMethods.where((method) => method.enabled).toList();
            _isLoadingPaymentMethods = false;
            if (_paymentMethods.isNotEmpty && _selectedPaymentMethod == null) {
              _selectedPaymentMethod = _paymentMethods.firstWhere((m) => m.type == 'Cash', orElse: () => _paymentMethods.first).name;
            }
          });
        } else if (state is PaymentMethodsError) {
          setState(() => _isLoadingPaymentMethods = false);
          _showSnackBar('Failed to load payment methods: ${state.message}', Colors.red);
        } else if (state is POSSessionCreated) {
          _showSnackBar(state.message, Colors.green);
          await getIt<StorageService>().setString('session_name', state.session.name);
          if (!context.mounted) return;
          widget.onSessionOpened(state.session);
          Navigator.of(context).pop();
        } else if (state is POSSessionError) {
          _showSnackBar('Failed to open session: ${state.message}', Colors.red);
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(
                children: [
                  SessionHeader(title: 'Open POS Session', onClose: () => Navigator.of(context).pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController, padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileInput(),
                            const SizedBox(height: 20),
                            SessionInfoContainer(label: 'Company', content: widget.company, icon: Icons.business),
                            const SizedBox(height: 20),
                            SessionInfoContainer(label: 'User/Cashier', content: widget.currentUser, icon: Icons.person),
                            const SizedBox(height: 32),
                            const OpeningBalanceDetailsHeader(),
                            const SizedBox(height: 16),
                            _buildBalanceContent(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomActions(state),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('POS Profile *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _posProfileController,
          decoration: _inputDecoration(hint: 'Enter POS profile name', icon: Icons.point_of_sale),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          validator: (v) => v == null || v.isEmpty ? 'POS Profile is required' : null,
        ),
      ],
    );
  }

  Widget _buildBalanceContent() {
    if (_isLoadingPaymentMethods) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CircularProgressIndicator(strokeWidth: 2)));
    if (_paymentMethods.isEmpty) return _buildEmptyMethods();
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildTableHeader(),
          PaymentMethodInputRow(
            selectedMethod: _selectedPaymentMethod, methods: _paymentMethods, amountController: _amountController,
            onMethodChanged: (v) => setState(() => _selectedPaymentMethod = v), onAdd: _addBalanceDetail,
          ),
          _buildBalanceList(),
          OpeningBalanceTotalRow(total: _balanceDetails.fold(0, (sum, d) => sum + (d['amount'] as double))),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Payment Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blue[900]))),
          Expanded(flex: 2, child: Text('Amount (KES)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blue[900]))),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBalanceList() {
    if (_balanceDetails.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('No payment methods added yet', style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic))));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 600,
        child: ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: _balanceDetails.length,
          itemBuilder: (context, i) => BalanceDetailListItem(
            detail: _balanceDetails[i], onDelete: () => _removeBalanceDetail(i),
            paymentType: _paymentMethods.firstWhere((p) => p.name == _balanceDetails[i]['method'], orElse: () => PaymentMethod(name: '', type: 'Unknown', enabled: true, accounts: [])).type,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(SalesState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: ElevatedButton(
            onPressed: state is POSSessionLoading ? null : _openSession,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
            child: state is POSSessionLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_open, size: 18), SizedBox(width: 8), Text('Open Session')]),
          )),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint, filled: true, fillColor: Colors.grey[50], prefixIcon: Icon(icon, color: Colors.blue[600], size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue[400]!, width: 2)),
    );
  }

  Widget _buildEmptyMethods() {
    return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Column(children: [Icon(Icons.payment_outlined, size: 48, color: Colors.grey[400]), const SizedBox(height: 12), const Text('No payment methods available', style: TextStyle(color: Colors.grey, fontSize: 14))])));
  }

  void _showSnackBar(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));

  void _addBalanceDetail() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_selectedPaymentMethod != null) {
      setState(() {
        _balanceDetails.add({'method': _selectedPaymentMethod!, 'amount': amount});
        _amountController.text = "0.00";
      });
      context.read<SalesBloc>().add(AddBalanceDetail(balanceDetail: BalanceDetail(modeOfPayment: _selectedPaymentMethod!, openingAmount: amount)));
    }
  }

  void _removeBalanceDetail(int i) => setState(() => _balanceDetails.removeAt(i));

  Future<void> _openSession() async {
    if (_formKey.currentState!.validate()) {
      final request = POSSessionRequest(
        posProfile: _posProfileController.text.trim(), company: widget.company, user: widget.currentUser,
        balanceDetails: _balanceDetails.map((d) => BalanceDetail(modeOfPayment: d['method'], openingAmount: d['amount'])).toList(),
      );
      context.read<SalesBloc>().add(CreatePOSSession(request: request));
    }
  }

  @override
  void dispose() {
    _posProfileController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
