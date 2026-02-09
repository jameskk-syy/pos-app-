import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';

class CreateCreditPaymentDialog extends StatefulWidget {
  final String companyName;

  const CreateCreditPaymentDialog({super.key, required this.companyName});

  @override
  State<CreateCreditPaymentDialog> createState() =>
      _CreateCreditPaymentDialogState();
}

class _CreateCreditPaymentDialogState extends State<CreateCreditPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _accountController;
  late TextEditingController _typeController;
  late TextEditingController _currencyController;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(text: 'Debtors');
    _typeController = TextEditingController(text: 'Bank');
    _currencyController = TextEditingController(text: 'KES');

    // Fetch default receivable account for the company
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesBloc>().add(
        FetchReceivableAccount(
          customer: 'Walk-in Customer', // Default customer
          company: widget.companyName,
        ),
      );
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _typeController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ), // Not rounded
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ), // Large width for tablet, fits mobile
        child: BlocListener<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is ReceivableAccountLoaded) {
              final account = state.data['account']?.toString();
              if (account != null && account.isNotEmpty) {
                _accountController.text = account;
              }
            } else if (state is ReceivableAccountError) {
              debugPrint('Error fetching receivable account: ${state.message}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configure Credit Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Configure how credit payments are handled for your company.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const Divider(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        label: 'Company',
                        child: Text(
                          widget.companyName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _accountController,
                        label: 'Default Account',
                        hint: 'e.g. Debtors - POX',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _typeController,
                              label: 'Type',
                              hint: 'Bank',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _currencyController,
                              label: 'Currency',
                              hint: 'KES',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enabled'),
                        value: _enabled,
                        onChanged: (val) => setState(() => _enabled = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BlocBuilder<SalesBloc, SalesState>(
                        builder: (context, state) {
                          bool isLoading = state is CreateCreditPaymentLoading;

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
                            ),
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Configuration'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return _buildField(
      label: label,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = {
        "company": widget.companyName,
        "default_account": _accountController.text,
        "mop_type": _typeController.text,
        "currency": _currencyController.text,
        "enabled": _enabled ? 1 : 0,
      };

      context.read<SalesBloc>().add(CreateCreditPayment(request: request));
      Navigator.pop(context);
    }
  }
}
