import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_supplier_group_request.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';

class AddSupplierGroupPage extends StatefulWidget {
  const AddSupplierGroupPage({super.key});

  @override
  State<AddSupplierGroupPage> createState() => _AddSupplierGroupPageState();
}

class _AddSupplierGroupPageState extends State<AddSupplierGroupPage> {
  final TextEditingController groupNameController = TextEditingController();
  final List<String> parentGroups = [
    'None (Root Group)',
    'All Supplier Groups',
  ];
  String selectedParentGroup = 'None (Root Group)';
  
  final List<String> paymentTerms = [
    '',
    'Credit',
    'Cash',
    'Due on Receipt',
  ];
  String selectedPaymentTerm = '';
  
  bool isCreatingGroup = false;

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SuppliersBloc, SuppliersState>(
      listener: (context, state) {
        if (state is CreateSupplierGroupLoading) {
          setState(() {
            isCreatingGroup = true;
          });
        } else if (state is CreateSupplierGroupSuccess) {
          setState(() {
            isCreatingGroup = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.message.message),
              backgroundColor: Colors.green,
            ),
          );
          
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            }
          });
        } else if (state is CreateSupplierGroupError) {
          setState(() {
            isCreatingGroup = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating supplier group: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Add New Supplier Group',
            style: TextStyle(
              color: Color(0xFF0080C8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier Group Name with *
                    _buildTextField(
                      controller: groupNameController,
                      label: 'Supplier Group Name',
                      required: true,
                      hint: 'Enter supplier group name',
                    ),
                    const SizedBox(height: 16),
                    
                    // Parent Supplier Group
                    _buildDropdownField(
                      label: 'Parent Supplier Group',
                      value: selectedParentGroup,
                      items: parentGroups,
                      onChanged: (value) {
                        setState(() {
                          selectedParentGroup = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment Terms
                    _buildDropdownField(
                      label: 'Payment Terms',
                      value: selectedPaymentTerm,
                      items: paymentTerms,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentTerm = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Information note - moved to bottom
                    _buildInfoBox(
                      text: 'Supplier groups help organize your suppliers for better management and reporting.',
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(10),
                    blurRadius: 2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isCreatingGroup ? null : () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Create button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isCreatingGroup ? null : _handleCreateSupplierGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0080C8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: isCreatingGroup
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool required,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox({required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        border: Border.all(color: const Color(0xFFD6E4FF)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF0080C8).withAlpha(80),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blueGrey.shade700,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreateSupplierGroup() {
    // Validate required fields
    if (groupNameController.text.trim().isEmpty) {
      _showError('Please enter supplier group name');
      return;
    }

    // Handle payment terms - only send if not "None (Root Group)"
    String? paymentTerm;
    if (selectedPaymentTerm != 'None (Root Group)') {
      paymentTerm = selectedPaymentTerm;
    }

    // Create the request - using the exact API structure from your example
    final request = CreateSupplierGroupRequest(
      supplierGroupName: groupNameController.text.trim(),
      isGroup: false, // From your API example (is_group: false)
      paymentTerms: paymentTerm, // Optional field
    );

    // Dispatch the event
    context.read<SuppliersBloc>().add(CreateSupplierGroup(request: request));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}