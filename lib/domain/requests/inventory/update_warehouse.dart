class UpdateWarehouseRequest {
  final String name;
  final String warehouseName;
  final String company;
  final String? warehouseType;
  final String? parentWarehouse;
  final bool isGroup;
  final bool isMainDepot;
  final bool setAsDefault;
  final String? account;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pin;
  final String? phoneNo;
  final String? mobileNo;
  final String? emailId;

  UpdateWarehouseRequest({
    required this.name,
    required this.warehouseName,
    required this.company,
    this.warehouseType,
    this.parentWarehouse,
    required this.isGroup,
    required this.isMainDepot,
    required this.setAsDefault,
    this.account,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pin,
    this.phoneNo,
    this.mobileNo,
    this.emailId,
  });

  Map<String, dynamic> toJson() {
    return {
      'warehouse_name': warehouseName,
      'company': company,
      'warehouse_type': warehouseType ?? '',
      'parent_warehouse': parentWarehouse ?? '',
      'is_group': isGroup,
      'is_main_depot': isMainDepot,
      'set_as_default': setAsDefault,
      'account': account ?? '',
      'address_line_1': addressLine1 ?? '',
      'address_line_2': addressLine2 ?? '',
      'city': city ?? '',
      'state': state ?? '',
      'pin': pin ?? '',
      'phone_no': phoneNo ?? '',
      'mobile_no': mobileNo ?? '',
      'email_id': emailId ?? '',
      'name': name,
    };
  }
}