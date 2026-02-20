import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/presentation/widgets/custom_text_field.dart';
import 'package:pos/widgets/common/app_drop_down.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/inventory/create_warehouse.dart';
import 'package:pos/domain/requests/inventory/update_warehouse.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
}

class WarehouseForm extends StatefulWidget {
  final Warehouse? warehouseToEdit;
  final CurrentUserResponse? currentUserResponse;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const WarehouseForm({
    super.key,
    this.warehouseToEdit,
    required this.currentUserResponse,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<WarehouseForm> createState() => _WarehouseFormState();
}

class _WarehouseFormState extends State<WarehouseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController warehouseNameController;
  late TextEditingController parentWarehouseController;
  late String warehouseType;
  late bool isGroupWarehouse;
  late bool isMainDepot;
  late bool setAsDefaultWarehouse;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController cityController;
  late TextEditingController stateProvinceController;
  late TextEditingController pinCodeController;
  late TextEditingController phoneNumberController;
  late TextEditingController mobileNumberController;
  late TextEditingController emailController;
  late TextEditingController accountController;

  List<String> parentWarehouseOptions = [];
  List<String> warehouseTypeOptions = [
    'Transit',
    'Storage',
    'Distribution',
    'Retail',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadParentWarehouses();
  }

  void _loadParentWarehouses() {
    final storeBloc = context.read<StoreBloc>();
    final state = storeBloc.state;
    if (state is StoreStateSuccess) {
      setState(() {
        parentWarehouseOptions = state.storeGetResponse.message.data
            .where(
              (warehouse) => warehouse.name != widget.warehouseToEdit?.name,
            )
            .map((warehouse) => warehouse.name)
            .toList();
      });
    }
  }

  void _initializeControllers() {
    final warehouse = widget.warehouseToEdit;

    warehouseNameController = TextEditingController(
      text: warehouse?.warehouseName ?? '',
    );
    parentWarehouseController = TextEditingController(
      text: warehouse?.parentWarehouse ?? '',
    );
    warehouseType = warehouse?.warehouseType ?? 'Transit';
    isGroupWarehouse = warehouse?.isGroup == 1;
    isMainDepot = warehouse?.isMainDepot ?? false;
    setAsDefaultWarehouse = warehouse?.isDefault ?? false;

    addressLine1Controller = TextEditingController(
      text: warehouse?.addressLine1 ?? '',
    );
    addressLine2Controller = TextEditingController(
      text: warehouse?.addressLine2 ?? '',
    );
    cityController = TextEditingController(text: warehouse?.city ?? '');
    stateProvinceController = TextEditingController(
      text: warehouse?.state ?? '',
    );
    pinCodeController = TextEditingController(text: warehouse?.pin ?? '');

    phoneNumberController = TextEditingController(
      text: warehouse?.phoneNo ?? '',
    );
    mobileNumberController = TextEditingController(
      text: warehouse?.mobileNo ?? '',
    );
    emailController = TextEditingController(text: warehouse?.emailId ?? '');

    accountController = TextEditingController(text: warehouse?.account ?? '');

    if (!warehouseTypeOptions.contains(warehouseType)) {
      warehouseType = 'Transit';
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Custom Validations
      if (phoneNumberController.text.isNotEmpty) {
        if (phoneNumberController.text.trim().length < 10 ||
            phoneNumberController.text.trim().length > 12) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number must be between 10 and 12 digits'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final company = widget.currentUserResponse?.message.company.name ?? '';

      if (widget.warehouseToEdit == null) {
        final request = CreateWarehouseRequest(
          warehouseName: warehouseNameController.text,
          company: company,
          warehouseType: warehouseType,
          parentWarehouse: parentWarehouseController.text.isNotEmpty
              ? parentWarehouseController.text
              : null,
          isGroup: isGroupWarehouse,
          isMainDepot: isMainDepot,
          setAsDefault: setAsDefaultWarehouse,
          account: accountController.text.isNotEmpty
              ? accountController.text
              : null,
          addressLine1: addressLine1Controller.text.isNotEmpty
              ? addressLine1Controller.text
              : null,
          addressLine2: addressLine2Controller.text.isNotEmpty
              ? addressLine2Controller.text
              : null,
          city: cityController.text.isNotEmpty ? cityController.text : null,
          state: stateProvinceController.text.isNotEmpty
              ? stateProvinceController.text
              : null,
          pin: pinCodeController.text.isNotEmpty
              ? pinCodeController.text
              : null,
          phoneNo: phoneNumberController.text.isNotEmpty
              ? phoneNumberController.text
              : null,
          mobileNo: mobileNumberController.text.isNotEmpty
              ? mobileNumberController.text
              : null,
          emailId: emailController.text.isNotEmpty
              ? emailController.text
              : null,
        );

        context.read<StoreBloc>().add(
          Createwarehouse(createWarehouseRequest: request),
        );
      } else {
        final request = UpdateWarehouseRequest(
          name: widget.warehouseToEdit!.name,
          warehouseName: warehouseNameController.text,
          company: company,
          warehouseType: warehouseType,
          parentWarehouse: parentWarehouseController.text.isNotEmpty
              ? parentWarehouseController.text
              : null,
          isGroup: isGroupWarehouse,
          isMainDepot: isMainDepot,
          setAsDefault: setAsDefaultWarehouse,
          account: accountController.text.isNotEmpty
              ? accountController.text
              : null,
          addressLine1: addressLine1Controller.text.isNotEmpty
              ? addressLine1Controller.text
              : null,
          addressLine2: addressLine2Controller.text.isNotEmpty
              ? addressLine2Controller.text
              : null,
          city: cityController.text.isNotEmpty ? cityController.text : null,
          state: stateProvinceController.text.isNotEmpty
              ? stateProvinceController.text
              : null,
          pin: pinCodeController.text.isNotEmpty
              ? pinCodeController.text
              : null,
          phoneNo: phoneNumberController.text.isNotEmpty
              ? phoneNumberController.text
              : null,
          mobileNo: mobileNumberController.text.isNotEmpty
              ? mobileNumberController.text
              : null,
          emailId: emailController.text.isNotEmpty
              ? emailController.text
              : null,
        );

        context.read<StoreBloc>().add(
          UpdateWarehouse(updateWarehouseRequest: request),
        );
      }
    }
  }

  @override
  void dispose() {
    warehouseNameController.dispose();
    parentWarehouseController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateProvinceController.dispose();
    pinCodeController.dispose();
    phoneNumberController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreBloc, StoreState>(
      listener: (context, state) {
        if (state is StoreSuccessfulState && widget.warehouseToEdit == null) {
          widget.onSuccess();
        } else if (state is StoreUpdateSuccessState &&
            widget.warehouseToEdit != null) {
          widget.onSuccess();
        }
      },
      child: _buildFormContent(context),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return SingleChildScrollView(
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onCancel,
                    iconSize: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: isMobile ? 4 : 8),
                  Expanded(
                    child: Text(
                      widget.warehouseToEdit == null
                          ? 'Add New Warehouse'
                          : 'Edit Warehouse',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildFormSections(context, isMobile, isTablet)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSections(
    BuildContext context,
    bool isMobile,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionTitle(context, 'Basic Information'),
        SizedBox(height: isMobile ? 16 : 20),
        _buildBasicInfoFields(context, isMobile),
        SizedBox(height: isMobile ? 24 : 32),

        // _buildSectionTitle(context, 'Address Information'),
        // SizedBox(height: isMobile ? 16 : 20),
        // _buildAddressFields(context, isMobile),
        // SizedBox(height: isMobile ? 24 : 32),

        _buildSectionTitle(context, 'Contact Information'),
        SizedBox(height: isMobile ? 16 : 20),
        _buildContactFields(context, isMobile),
        SizedBox(height: isMobile ? 24 : 32),

        _buildActionButtons(context, isMobile, isTablet),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveHelper.getResponsiveFontSize(
          context,
          mobile: 16,
          tablet: 17,
          desktop: 18,
        ),
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildBasicInfoFields(BuildContext context, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildResponsiveRow(context, [
          _buildField(
            label: 'Warehouse Name',
            controller: warehouseNameController,
            required: true,
            hint: 'Warehouse Name',
          ),
          _buildDropdown(
            label: 'Warehouse Type',
            value: warehouseType,
            items: warehouseTypeOptions,
            onChanged: (value) {
              if (value != null) setState(() => warehouseType = value);
            },
          ),
          _buildDropdown(
            label: 'Parent Warehouse',
            value:
                parentWarehouseController.text.isNotEmpty &&
                    parentWarehouseOptions.contains(
                      parentWarehouseController.text,
                    )
                ? parentWarehouseController.text
                : null,
            items: ['None', ...parentWarehouseOptions],
            onChanged: (value) {
              setState(
                () => parentWarehouseController.text =
                    (value == 'None' ? '' : value) ?? '',
              );
            },
          ),
        ]),
        SizedBox(height: isMobile ? 16 : 20),
        _buildCheckboxRow(context),
        SizedBox(height: isMobile ? 8 : 10),
        _buildDefaultCheckbox(context),
        SizedBox(height: isMobile ? 16 : 20),
        _buildField(
          label: 'Account',
          controller: accountController,
          required: false,
          hint: 'Account',
        ),
      ],
    );
  }

  Widget _buildAddressFields(BuildContext context, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildResponsiveRow(context, [
          _buildField(
            label: 'Address Line 1',
            controller: addressLine1Controller,
            required: false,
            hint: 'Address Line 1',
          ),
          _buildField(
            label: 'Address Line 2',
            controller: addressLine2Controller,
            required: false,
            hint: 'Address Line 2',
          ),
        ]),
        SizedBox(height: isMobile ? 16 : 20),
        _buildResponsiveRow(context, [
          _buildField(
            label: 'City',
            controller: cityController,
            required: false,
            hint: 'City',
          ),
          _buildField(
            label: 'State/Province',
            controller: stateProvinceController,
            required: false,
            hint: 'State/Province',
          ),
          _buildField(
            label: 'PIN Code',
            controller: pinCodeController,
            required: false,
            hint: 'PIN Code',
          ),
        ]),
      ],
    );
  }

  Widget _buildContactFields(BuildContext context, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildResponsiveRow(context, [
          _buildField(
            label: 'Mobile Number',
            controller: mobileNumberController,
            required: false,
            hint: 'Mobile Number',
          ),
        ]),
        SizedBox(height: isMobile ? 16 : 20),
        _buildField(
          label: 'Email',
          controller: emailController,
          required: false,
          hint: 'Email',
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              _buildCheckbox(context, 'Is Group Warehouse', isGroupWarehouse, (
                val,
              ) {
                setState(() => isGroupWarehouse = val!);
              }),
              _buildCheckbox(context, 'Is Main Depot', isMainDepot, (val) {
                setState(() => isMainDepot = val!);
              }),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildCheckbox(
                context,
                'Is Group Warehouse',
                isGroupWarehouse,
                (val) {
                  setState(() => isGroupWarehouse = val!);
                },
              ),
            ),
            Expanded(
              child: _buildCheckbox(context, 'Is Main Depot', isMainDepot, (
                val,
              ) {
                setState(() => isMainDepot = val!);
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckbox(
    BuildContext context,
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 13,
            tablet: 14,
            desktop: 15,
          ),
        ),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDefaultCheckbox(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        'Set as Default Warehouse',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 13,
            tablet: 14,
            desktop: 15,
          ),
        ),
      ),
      subtitle: Text(
        'This warehouse will be used as default when no warehouse is specified',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 11,
            tablet: 12,
            desktop: 12,
          ),
        ),
      ),
      value: setAsDefaultWarehouse,
      onChanged: (value) {
        setState(() {
          setAsDefaultWarehouse = value!;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool isMobile,
    bool isTablet,
  ) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.warehouseToEdit == null ? Icons.add : Icons.save,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.warehouseToEdit == null ? 'Create' : 'Update',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: widget.onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey[300]!),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 32,
              vertical: isTablet ? 14 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Cancel', style: TextStyle(fontSize: isTablet ? 13 : 14)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 32,
              vertical: isTablet ? 14 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.warehouseToEdit == null ? Icons.add : Icons.save,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.warehouseToEdit == null ? 'Create' : 'Update',
                style: TextStyle(fontSize: isTablet ? 13 : 14),
              ),
            ],
          ),
        ),
      ],
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
      keyboardType: label.contains('Number') || label.contains('PIN')
          ? TextInputType.number
          : TextInputType.text,
      inputFormatters: label.contains('Number') || label.contains('PIN')
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
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

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isMobile(context)) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                children[i],
              ],
            ],
          );
        } else if (constraints.maxWidth > 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: children[i]),
              ],
            ],
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                children[i],
              ],
            ],
          );
        }
      },
    );
  }
}
