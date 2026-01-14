// widgets/open_session_bottom_sheet.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/models/pos_session_model.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenSessionBottomSheet extends StatefulWidget {
  final String company;
  final String profilePos;
  final String currentUser;
  final Function(POSSessionResponse?) onSessionOpened;

  const OpenSessionBottomSheet({
    super.key,
    required this.company,
    required this.currentUser,
    required this.onSessionOpened,
    required this.profilePos,
  });

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
      context.read<SalesBloc>().add(
        GetPaymentMethod(company: widget.company, onlyEnabled: true),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPaymentMethods = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _posProfileController.text = widget.profilePos;
      _amountController.text = "0.00";
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SalesBloc, SalesState>(
      listener: (context, state) async {
        if (state is PaymentMethodsLoaded) {
          setState(() {
            _paymentMethods = state.paymentMethods
                .where((method) => method.enabled)
                .toList();
            _isLoadingPaymentMethods = false;

            // Set default selected payment method (prefer Cash)
            if (_paymentMethods.isNotEmpty && _selectedPaymentMethod == null) {
              final cashMethod = _paymentMethods.firstWhere(
                (method) => method.type == 'Cash',
                orElse: () => _paymentMethods.first,
              );
              _selectedPaymentMethod = cashMethod.name;
            }
          });
        } else if (state is PaymentMethodsError) {
          setState(() => _isLoadingPaymentMethods = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load payment methods: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is POSSessionCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('session_name', state.session.name);
          widget.onSessionOpened(state.session);
          Navigator.of(context).pop();
        } else if (state is POSSessionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open session: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Open POS Session',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue[900],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // POS Profile Input
                            _buildLabel('POS Profile *'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _posProfileController,
                              decoration: InputDecoration(
                                hintText: 'Enter POS profile name',
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.blue[400]!,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.point_of_sale,
                                  color: Colors.blue[600],
                                  size: 20,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'POS Profile is required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Company Info
                            _buildLabel('Company'),
                            const SizedBox(height: 8),
                            _buildInfoContainer(widget.company, Icons.business),

                            const SizedBox(height: 20),

                            // User/Cashier Info
                            _buildLabel('User/Cashier'),
                            const SizedBox(height: 8),
                            _buildInfoContainer(
                              widget.currentUser,
                              Icons.person,
                            ),

                            const SizedBox(height: 32),

                            // Opening Balance Section Header
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Opening Balance Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Optional',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Payment Method Table
                            if (_isLoadingPaymentMethods)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                  ),
                                ),
                              )
                            else if (_paymentMethods.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 40,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.payment_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No payment methods available',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              _buildPaymentTable(),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: state is POSSessionLoading
                                ? null
                                : _openSession,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: state is POSSessionLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock_open, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Open Session',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount (KES)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Add New Row Input - Made horizontally scrollable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 600, // Set a fixed width that's wider than normal
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method Dropdown
                  SizedBox(
                    width: 150, // Fixed width for dropdown
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedPaymentMethod,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue[400]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem<String>(
                          value: method.name,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _getPaymentMethodColor(
                                    method.type,
                                  ).withAlpha(10),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  _getPaymentMethodIcon(method.type),
                                  size: 12,
                                  color: _getPaymentMethodColor(method.type),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  method.name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Amount Input
                  SizedBox(
                    width: 150, // Fixed width for amount input
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue[400]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Add Button
                  IconButton(
                    onPressed: _addBalanceDetail,
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    tooltip: 'Add',
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          ),

          // Table Rows (Added Items) - Also horizontally scrollable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 600, // Same width as input section
              child: _balanceDetails.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No payment methods added yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _balanceDetails.length,
                      itemBuilder: (context, index) {
                        final detail = _balanceDetails[index];
                        final paymentType = _getPaymentTypeForName(
                          detail['method'],
                        );

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: index < _balanceDetails.length - 1
                                  ? BorderSide(color: Colors.grey[200]!)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Payment Method Column
                              SizedBox(
                                width: 250,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _getPaymentMethodColor(
                                          paymentType,
                                        ).withAlpha(10),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        _getPaymentMethodIcon(paymentType),
                                        size: 14,
                                        color: _getPaymentMethodColor(
                                          paymentType,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        detail['method'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Amount Column
                              SizedBox(
                                width: 150,
                                child: Text(
                                  NumberFormat(
                                    '#,##0.00',
                                  ).format(detail['amount']),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              // Delete Button Column
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[400],
                                  size: 20,
                                ),
                                onPressed: () => _removeBalanceDetail(index),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Total Row - Also horizontally scrollable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 600,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Total Label Column
                  SizedBox(
                    width: 250,
                    child: Text(
                      'Total Opening Balance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),

                  // Total Amount Column
                  SizedBox(
                    width: 150,
                    child: Text(
                      NumberFormat('#,##0.00').format(
                        _balanceDetails.fold<double>(
                          0,
                          (sum, detail) => sum + (detail['amount'] as double),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),

                  // Empty column for alignment with delete button
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInfoContainer(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[500], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.currency_exchange;
      case 'bank':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Colors.green[600]!;
      case 'bank':
        return Colors.blue[600]!;
      case 'credit':
        return Colors.orange[600]!;
      default:
        return Colors.purple[600]!;
    }
  }

  String _getPaymentTypeForName(String methodName) {
    return _paymentMethods
        .firstWhere(
          (pm) => pm.name == methodName,
          orElse: () => PaymentMethod(
            name: '',
            type: 'Unknown',
            enabled: true,
            accounts: [],
          ),
        )
        .type;
  }

  void _addBalanceDetail() {
    if (_selectedPaymentMethod != null && _amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      setState(() {
        _balanceDetails.add({
          'method': _selectedPaymentMethod!,
          'amount': amount,
        });
        _amountController.clear();
      });

      _paymentMethods.firstWhere(
        (pm) => pm.name == _selectedPaymentMethod,
        orElse: () => PaymentMethod(
          name: _selectedPaymentMethod!,
          type: 'Cash',
          enabled: true,
          accounts: [],
        ),
      );
      context.read<SalesBloc>().add(
        AddBalanceDetail(
          balanceDetail: BalanceDetail(
            modeOfPayment: _selectedPaymentMethod!,
            openingAmount: amount,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_selectedPaymentMethod'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method and enter amount'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeBalanceDetail(int index) {
    if (index < _balanceDetails.length) {
      setState(() {
        _balanceDetails.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method removed'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _openSession() async {
    // final prefs = await SharedPreferences.getInstance();
    // String? sessionName = prefs.getString('session_name');
    // if (sessionName != null && sessionName.isNotEmpty) {
    //   Navigator.pop(context);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         'A session "$sessionName" is already open. Close it first',
    //       ),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }
    if (_formKey.currentState!.validate()) {
      final List<BalanceDetail> balanceDetails = _balanceDetails
          .map(
            (detail) => BalanceDetail(
              modeOfPayment: detail['method'],
              openingAmount: detail['amount'],
              // Add other required fields if needed
            ),
          )
          .toList();

      final request = POSSessionRequest(
        posProfile: _posProfileController.text.trim(),
        company: widget.company,
        user: widget.currentUser,
        balanceDetails: balanceDetails,
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
