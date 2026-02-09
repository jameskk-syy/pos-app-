import 'dart:convert';
import 'package:pos/presentation/widgets/custom_text_field.dart';
import 'package:pos/widgets/common/app_drop_down.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/sales/create_customer.dart';
import 'package:pos/domain/requests/sales/update_customer_request.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

class CustomerFormView extends StatefulWidget {
  final Customer? customer;
  final VoidCallback onCancel;
  final Function(CompleteCustomerRequest) onSave;
  final Function(UpdateCustomerRequest, String)? onUpdate;

  const CustomerFormView({
    super.key,
    this.customer,
    required this.onCancel,
    required this.onSave,
    this.onUpdate,
  });

  @override
  State<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends State<CustomerFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController customerNameController;
  late TextEditingController customerGroupController;
  late TextEditingController territoryController;
  late TextEditingController taxIdController;
  late TextEditingController mobileNoController;
  late TextEditingController emailIdController;
  late TextEditingController defaultPriceListController;
  late String customerType;
  late String defaultCurrency;
  late bool disabled;
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCurrentUser();
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

    setState(() {
      currentUserResponse = savedUser;
    });
  }

  void _initializeControllers() {
    customerNameController = TextEditingController(
      text: widget.customer?.customerName ?? '',
    );
    customerGroupController = TextEditingController(
      text: widget.customer?.customerGroup ?? '',
    );
    territoryController = TextEditingController(
      text: widget.customer?.territory ?? '',
    );
    taxIdController = TextEditingController(text: widget.customer?.taxId ?? '');
    mobileNoController = TextEditingController(
      text: widget.customer?.mobileNo ?? '',
    );
    emailIdController = TextEditingController(
      text: widget.customer?.emailId ?? '',
    );
    defaultPriceListController = TextEditingController(
      text: widget.customer?.defaultPriceList ?? '',
    );
    customerType = widget.customer?.customerType ?? 'Individual';
    defaultCurrency = widget.customer?.defaultCurrency ?? 'KES';
    disabled = widget.customer?.isActive == false ? true : false;
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerGroupController.dispose();
    territoryController.dispose();
    taxIdController.dispose();
    mobileNoController.dispose();
    emailIdController.dispose();
    defaultPriceListController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Custom Validations
      if (mobileNoController.text.isNotEmpty) {
        if (mobileNoController.text.trim().length < 10 ||
            mobileNoController.text.trim().length > 12) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mobile number must be between 10 and 12 digits'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (taxIdController.text.isNotEmpty) {
        if (!RegExp(
          r'^[a-zA-Z0-9]{11}$',
        ).hasMatch(taxIdController.text.trim())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tax ID must be exactly 11 alphanumeric characters',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (widget.customer == null) {
        // CREATE NEW CUSTOMER
        final request = CompleteCustomerRequest(
          customerName: customerNameController.text.trim(),
          customerType: customerType,
          company: currentUserResponse!.message.company.name,
          customerGroup: customerGroupController.text.trim(),
          territory: territoryController.text.trim(),
          taxId: taxIdController.text.trim(),
          mobileNo: mobileNoController.text.trim(),
          emailId: emailIdController.text.trim(),
          defaultCurrency: defaultCurrency,
          disabled: disabled,
          defaultPriceList: defaultPriceListController.text.trim().isEmpty
              ? null
              : defaultPriceListController.text.trim(),
        );
        widget.onSave(request);
      } else {
        // UPDATE EXISTING CUSTOMER
        if (widget.onUpdate != null) {
          final updateRequest = UpdateCustomerRequest(
            name: widget.customer!.name,
            customerName: customerNameController.text.trim(),
            customerType: customerType,
            customerGroup: customerGroupController.text.trim(),
            territory: territoryController.text.trim(),
            taxId: taxIdController.text.trim(),
            mobileNo: mobileNoController.text.trim(),
            emailId: emailIdController.text.trim(),
            defaultCurrency: defaultCurrency,
            defaultPriceList: defaultPriceListController.text.trim(),
            disabled: disabled,
          );
          widget.onUpdate!(updateRequest, widget.customer!.name);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    final paddingValue = isMobile
        ? 16.0
        : isTablet
        ? 24.0
        : 32.0;
    final spacingValue = isMobile
        ? 12.0
        : isTablet
        ? 16.0
        : 20.0;
    final borderRadiusValue = isMobile
        ? 8.0
        : isTablet
        ? 12.0
        : 16.0;
    final iconSize = isMobile
        ? 20.0
        : isTablet
        ? 22.0
        : 24.0;
    final fontSize = isMobile
        ? 14.0
        : isTablet
        ? 16.0
        : 18.0;
    final double formMaxWidth;
    if (isMobile) {
      formMaxWidth = screenWidth - 32;
    } else if (isTablet) {
      formMaxWidth = 500;
    } else {
      formMaxWidth = 600;
    }

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: isMobile
                ? 8.0
                : isTablet
                ? 20.0
                : 40.0,
            horizontal: isMobile
                ? 8.0
                : isTablet
                ? 20.0
                : 40.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: BoxConstraints(maxWidth: formMaxWidth),
            child: Padding(
              padding: EdgeInsets.all(paddingValue),
              child: BlocConsumer<CrmBloc, CrmState>(
                listener: (context, state) {
                  // Listen for success states
                  if (state is CrmStateSuccessful) {
                    // Customer created successfully
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Customer created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is UpdateCustomerSuccess) {
                    // Customer updated successfully
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Customer updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is CrmStateFailure) {
                    // Handle errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is CrmStateLoading;

                  return Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMobile)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              widget.customer == null
                                  ? 'Create New Customer'
                                  : 'Edit Customer',
                              style: TextStyle(
                                fontSize: isTablet ? 20.0 : 24.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),

                        _buildField(
                          label: 'Customer Name',
                          required: true,
                          controller: customerNameController,
                          hint: 'Enter customer name',
                        ),
                        SizedBox(height: spacingValue),

                        _buildDropdown(
                          label: 'Customer Type',
                          value: customerType,
                          items: ['Individual', 'Company', 'Partnership'],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                customerType = value;
                              });
                            }
                          },
                        ),
                        SizedBox(height: spacingValue),

                        _buildField(
                          label: 'Customer Group',
                          required: false,
                          controller: customerGroupController,
                          hint: 'Enter customer group',
                        ),
                        SizedBox(height: spacingValue),

                        _buildField(
                          label: 'Tax ID/PIN',
                          required: true,
                          controller: taxIdController,
                          hint: 'Enter tax ID',
                        ),
                        SizedBox(height: spacingValue),

                        _buildField(
                          label: 'Mobile Number',
                          required: false,
                          controller: mobileNoController,
                          hint: '07XXXXXXXX',
                        ),
                        SizedBox(height: spacingValue),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(
                              borderRadiusValue,
                            ),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          padding: EdgeInsets.all(
                            isMobile
                                ? 12
                                : isTablet
                                ? 16
                                : 20,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                disabled ? Icons.cancel : Icons.check_circle,
                                color: disabled ? Colors.red : Colors.green,
                                size: iconSize,
                              ),
                              SizedBox(
                                width: isMobile
                                    ? 8
                                    : isTablet
                                    ? 12
                                    : 16,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                        fontSize: isMobile
                                            ? 13
                                            : isTablet
                                            ? 14
                                            : 15,
                                      ),
                                    ),
                                    SizedBox(height: isMobile ? 2 : 4),
                                    Text(
                                      disabled
                                          ? 'Customer is disabled and cannot make transactions'
                                          : 'Customer is active and can make transactions',
                                      style: TextStyle(
                                        fontSize: isMobile
                                            ? 11
                                            : isTablet
                                            ? 12
                                            : 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: disabled,
                                onChanged: (value) {
                                  setState(() {
                                    disabled = value;
                                  });
                                },
                                activeTrackColor: Colors.red[200],
                                activeThumbColor: Colors.red,
                                inactiveTrackColor: Colors.green[200],
                                inactiveThumbColor: Colors.green,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: isMobile
                              ? 24
                              : isTablet
                              ? 32
                              : 40,
                        ),

                        Row(
                          mainAxisAlignment: isMobile
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: isLoading ? null : widget.onCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile
                                      ? 20
                                      : isTablet
                                      ? 24
                                      : 32,
                                  vertical: isMobile
                                      ? 12
                                      : isTablet
                                      ? 14
                                      : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    borderRadiusValue,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                            SizedBox(
                              width: isMobile
                                  ? 8
                                  : isTablet
                                  ? 16
                                  : 24,
                            ),
                            ElevatedButton(
                              onPressed: isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile
                                      ? 20
                                      : isTablet
                                      ? 24
                                      : 32,
                                  vertical: isMobile
                                      ? 12
                                      : isTablet
                                      ? 14
                                      : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    borderRadiusValue,
                                  ),
                                ),
                                minimumSize: Size(
                                  isMobile
                                      ? 120
                                      : isTablet
                                      ? 140
                                      : 160,
                                  isMobile
                                      ? 44
                                      : isTablet
                                      ? 48
                                      : 52,
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: isMobile
                                          ? 18
                                          : isTablet
                                          ? 20
                                          : 22,
                                      width: isMobile
                                          ? 18
                                          : isTablet
                                          ? 20
                                          : 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          widget.customer == null
                                              ? Icons.add
                                              : Icons.save,
                                          size: isMobile
                                              ? 16
                                              : isTablet
                                              ? 18
                                              : 20,
                                        ),
                                        SizedBox(
                                          width: isMobile
                                              ? 6
                                              : isTablet
                                              ? 8
                                              : 10,
                                        ),
                                        Text(
                                          widget.customer == null
                                              ? 'Create Customer'
                                              : 'Update Customer',
                                          style: TextStyle(fontSize: fontSize),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required bool required,
    String? hint,
  }) {
    return CustomTextField(
      controller: controller,
      label: required ? '$label*' : label,
      hint: hint,
      enabled: currentUserResponse != null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return AppDropDown<String>(
      labelText: label,
      selectedValue: value,
      dropdownItems: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
