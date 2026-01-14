import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/customer_credit.dart';
import 'package:pos/domain/requests/get_customer_request.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditManagementModal extends StatefulWidget {
  final Customer customer;

  const CreditManagementModal({
    super.key,
    required this.customer,
  });

  @override
  State<CreditManagementModal> createState() => _CreditManagementModalState();
}

class _CreditManagementModalState extends State<CreditManagementModal> {
  CurrentUserResponse? currentUserResponse;
  late CustomerRequest _searchRequest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
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
    _searchRequest = CustomerRequest(
      searchTerm: '',
      customerGroup: '',
      territory: '',
      customerType: '',
      disabled: false,
      filterByCompanyTransactions: false,
      company: currentUserResponse!.message.company.name,
      limit: 20,
      offset: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrmBloc, CrmState>(
      listener: (context, state) {
        if (state is UpdateCreditLimitSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.response.message)),
          );
          context
              .read<CrmBloc>()
              .add(GetAllCustomers(custmoerRequest: _searchRequest));
        }

        if (state is CrmStateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[50]!,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Credit Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.customer.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withAlpha(230),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: currentUserResponse != null
                      ? _CreditFormContent(
                          customer: widget.customer,
                          currentUserResponse: currentUserResponse,
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditFormContent extends StatefulWidget {
  final Customer customer;
  final CurrentUserResponse? currentUserResponse;

  const _CreditFormContent({
    required this.customer,
    this.currentUserResponse,
  });

  @override
  State<_CreditFormContent> createState() => _CreditFormContentState();
}

class _CreditFormContentState extends State<_CreditFormContent> {
  final creditLimitController = TextEditingController();
  final amountController = TextEditingController();
  String selectedAction = 'adjust';

  @override
  void initState() {
    super.initState();
    creditLimitController.text = widget.customer.creditLimit.toStringAsFixed(0);
  }

  @override
  void dispose() {
    creditLimitController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCreditInfoCard(
                'Credit Limit',
                widget.customer.creditLimit,
                Icons.credit_card,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCreditInfoCard(
                'Outstanding',
                widget.customer.outstandingAmount,
                Icons.receipt_long,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCreditInfoCard(
                'Available Credit',
                widget.customer.availableCredit,
                Icons.account_balance,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCreditInfoCard(
                'Utilization',
                widget.customer.creditLimit > 0
                    ? (widget.customer.outstandingAmount /
                            widget.customer.creditLimit *
                            100)
                    : 0,
                Icons.pie_chart,
                Colors.purple,
                isPercentage: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        const Text(
          'Select Action',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildActionChip(
                    'Adjust Limit',
                    Icons.tune,
                    'adjust',
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),

            const SizedBox(height: 24),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildActionForm(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreditInfoCard(
    String label,
    double value,
    IconData icon,
    Color color, {
    bool isPercentage = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(25)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (isPercentage && value > 80)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'High',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPercentage
                ? '${value.toStringAsFixed(1)}%'
                : '${value.toStringAsFixed(2)} KES',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    String label,
    IconData icon,
    String value,
  ) {
    final isSelected = value == selectedAction;
    return InkWell(
      onTap: () => setState(() => selectedAction = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionForm() {
    if (selectedAction == 'adjust') {
      return Container(
        key: const ValueKey('adjust'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Adjust Credit Limit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: creditLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Credit Limit',
                prefixIcon: const Icon(Icons.credit_card),
                suffixText: 'KES',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Validate input
                    if (creditLimitController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a credit limit'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newLimit =
                        double.tryParse(creditLimitController.text);
                    if (newLimit == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid number'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Dispatch the UpdateCreditLimit event
                    context.read<CrmBloc>().add(
                          UpdateCreditLimit(
                            request: UpdateCreditLimitRequest(
                              customer: widget.customer.name,
                              company: widget.currentUserResponse!.message.company.name,
                              creditLimit: newLimit,
                              bypassCreditLimitCheck:
                                  false, // Set based on your business logic
                            ),
                          ),
                        );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Update Limit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (selectedAction == 'payment') {
      return Container(
        key: const ValueKey('payment'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Record Payment',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                prefixIcon: const Icon(Icons.add_circle_outline),
                suffixText: 'KES',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Payment Reference',
                prefixIcon: const Icon(Icons.receipt),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      // You might want to create a separate Payment event
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Payment of ${amountController.text} KES recorded',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Record Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        key: const ValueKey('charge'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Add Charge',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Charge Amount',
                prefixIcon: const Icon(Icons.remove_circle_outline),
                suffixText: 'KES',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Charge Description',
                prefixIcon: const Icon(Icons.description),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      // You might want to create a separate AddCharge event
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Charge of ${amountController.text} KES added',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Add Charge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}