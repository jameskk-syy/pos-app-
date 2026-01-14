import 'dart:convert';
import 'package:pos/widgets/app_drop_down.dart';

import 'package:flutter/material.dart';
import 'package:pos/presentation/widgets/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_supplier_request.dart';
import 'package:pos/domain/requests/update_supplier_request.dart';
import 'package:pos/domain/responses/suppliers_response.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSupplierPage extends StatefulWidget {
  final Supplier? supplier;

  const AddSupplierPage({super.key, this.supplier});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController taxIdController = TextEditingController();
  final TextEditingController countryController = TextEditingController(
    text: 'Kenya',
  );
  final TextEditingController defaultCurrencyController = TextEditingController(
    text: 'KES',
  );
  String companyName = "";

  String selectedType = 'Company';
  String? selectedGroup;
  bool isInternalSupplier = false;

  final List<String> supplierTypes = ['Company', 'Individual'];
  List<String> supplierGroups = [];
  bool isLoadingGroups = false;
  bool isCreatingSupplier = false; // ADDED: Loading state for create button

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      final supplier = widget.supplier!;
      supplierNameController.text = supplier.supplierName;
      taxIdController.text = supplier.taxId ?? '';
      countryController.text = supplier.country;
      defaultCurrencyController.text = supplier.defaultCurrency ?? 'KES';
      isInternalSupplier =
          supplier.isInternalSupplier == 1; // Assuming 1 is true
      selectedType = supplier.supplierType;
      selectedGroup = supplier.supplierGroup;
    }
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
      companyName = savedUser.message.company.name;
    });

    context.read<SuppliersBloc>().add(GetSupplierGroups());
  }

  @override
  void dispose() {
    supplierNameController.dispose();
    taxIdController.dispose();
    countryController.dispose();
    defaultCurrencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SuppliersBloc, SuppliersState>(
      listener: (context, state) {
        if (state is SupplierGroupsLoading) {
          setState(() {
            isLoadingGroups = true;
          });
        } else if (state is SupplierGroupsSuccess) {
          setState(() {
            supplierGroups = state.response.message.data
                .map((group) => group.supplierGroupName)
                .toList();
            isLoadingGroups = false;
          });
        } else if (state is SupplierGroupsError) {
          setState(() {
            isLoadingGroups = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading groups: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // ADDED: Handle supplier creation states
        else if (state is CreateSupplierLoading) {
          setState(() {
            isCreatingSupplier = true;
          });
        } else if (state is CreateSupplierSuccess) {
          setState(() {
            isCreatingSupplier = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.message.message),
              backgroundColor: Colors.green,
            ),
          );

          // Pop back to previous screen after a short delay
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (!context.mounted) return;
            Navigator.pop(context);
          });
        } else if (state is CreateSupplierError) {
          setState(() {
            isCreatingSupplier = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating supplier: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is UpdateSupplierLoading) {
          setState(() {
            isCreatingSupplier = true;
          });
        } else if (state is UpdateSupplierSuccess) {
          setState(() {
            isCreatingSupplier = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.message.message),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (!context.mounted) return;
            Navigator.pop(context);
          });
        } else if (state is UpdateSupplierError) {
          setState(() {
            isCreatingSupplier = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating supplier: ${state.message}'),
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
          title: Text(
            widget.supplier != null ? 'Edit Supplier' : 'Add New Supplier',
            style: const TextStyle(
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
                    if (MediaQuery.of(context).size.width > 600) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: supplierNameController,
                              label: 'Supplier Name',
                              required: true,
                              hint: '',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Type',
                              value: selectedType,
                              items: supplierTypes,
                              onChanged: (value) {
                                setState(() {
                                  selectedType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Select Group',
                              value: selectedGroup,
                              items: supplierGroups,
                              hint: isLoadingGroups ? 'Loading...' : '...',
                              onChanged: isLoadingGroups
                                  ? null
                                  : (value) {
                                      setState(() {
                                        selectedGroup = value;
                                      });
                                    },
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              controller: taxIdController,
                              label: 'Tax ID/PIN',
                              required: false,
                              hint: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: countryController,
                              label: 'Country',
                              required: false,
                              hint: '',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              controller: defaultCurrencyController,
                              label: 'Default Currency',
                              required: false,
                              hint: '',
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildTextField(
                        controller: supplierNameController,
                        label: 'Supplier Name',
                        required: true,
                        hint: '',
                      ),
                      const SizedBox(height: 14),
                      _buildDropdownField(
                        label: 'Type',
                        value: selectedType,
                        items: supplierTypes,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildDropdownField(
                        label: 'Select Group',
                        value: selectedGroup,
                        items: supplierGroups,
                        hint: isLoadingGroups ? 'Loading...' : '...',
                        onChanged: isLoadingGroups
                            ? null
                            : (value) {
                                setState(() {
                                  selectedGroup = value;
                                });
                              },
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: taxIdController,
                        label: 'Tax ID/PIN',
                        required: false,
                        hint: '',
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: countryController,
                        label: 'Country',
                        required: false,
                        hint: '',
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: defaultCurrencyController,
                        label: 'Default Currency',
                        required: false,
                        hint: '',
                      ),
                    ],
                    const SizedBox(height: 14),
                    _buildSwitchField(
                      label: 'Internal Supplier',
                      value: isInternalSupplier,
                      onChanged: (value) {
                        setState(() {
                          isInternalSupplier = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
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
    return CustomTextField(
      controller: controller,
      label: required ? '$label*' : label,
      hint: hint,
      enabled: !isCreatingSupplier,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    String? hint,
    required Function(String?)? onChanged,
  }) {
    return AppDropDown<String>(
      labelText: label,
      selectedValue: value,
      hintText: hint,
      dropdownItems: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: (val) => onChanged?.call(val),
      enabled: !isLoadingGroups,
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.blue,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: isCreatingSupplier
                ? null
                : () {
                    // DISABLE when loading
                    Navigator.pop(context);
                  },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
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
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isCreatingSupplier
                ? null
                : _handleCreateSupplier, // DISABLE when loading
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0080C8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: isCreatingSupplier
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.supplier != null ? 'Update' : 'Create',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleCreateSupplier() {
    // Validate required fields
    if (supplierNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter supplier name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (companyName.isEmpty) {
      // FIXED: Removed unnecessary null check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create the request
    if (widget.supplier != null) {
      final request = UpdateSupplierRequest(
        name: widget.supplier!.name,
        company: companyName,
        supplierName: supplierNameController.text.trim(),
        supplierType: selectedType,
        supplierGroup: selectedGroup ?? 'All Supplier Groups',
        taxId: taxIdController.text.trim().isNotEmpty
            ? taxIdController.text.trim()
            : null,
        country: countryController.text.trim().isNotEmpty
            ? countryController.text.trim()
            : null,
        defaultCurrency: defaultCurrencyController.text.trim().isNotEmpty
            ? defaultCurrencyController.text.trim()
            : null,
        isInternalSupplier: isInternalSupplier,
      );
      context.read<SuppliersBloc>().add(UpdateSupplier(request: request));
    } else {
      final request = CreateSupplierRequest(
        company: companyName,
        supplierName: supplierNameController.text.trim(),
        supplierType: selectedType,
        supplierGroup: selectedGroup ?? 'All Supplier Groups',
        taxId: taxIdController.text.trim().isNotEmpty
            ? taxIdController.text.trim()
            : null,
        country: countryController.text.trim().isNotEmpty
            ? countryController.text.trim()
            : null,
        defaultCurrency: defaultCurrencyController.text.trim().isNotEmpty
            ? defaultCurrencyController.text.trim()
            : null,
        isInternalSupplier: isInternalSupplier,
      );
      context.read<SuppliersBloc>().add(CreateSupplier(request: request));
    }
  }
}
