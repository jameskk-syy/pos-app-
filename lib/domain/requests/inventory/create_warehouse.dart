class CreateWarehouseRequest {
  final String warehouseName;
  final String company;
  final String warehouseType;
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

  CreateWarehouseRequest({
    required this.warehouseName,
    required this.company,
    required this.warehouseType,
    this.parentWarehouse,
    this.isGroup = false,
    this.isMainDepot = false,
    this.setAsDefault = false,
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
      'warehouse_type': warehouseType,
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
    };
  }

  factory CreateWarehouseRequest.fromJson(Map<String, dynamic> json) {
    return CreateWarehouseRequest(
      warehouseName: json['warehouse_name'] ?? '',
      company: json['company'] ?? '',
      warehouseType: json['warehouse_type'] ?? 'Transit',
      parentWarehouse: json['parent_warehouse'],
      isGroup: json['is_group'] ?? false,
      isMainDepot: json['is_main_depot'] ?? false,
      setAsDefault: json['set_as_default'] ?? false,
      account: json['account'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      city: json['city'],
      state: json['state'],
      pin: json['pin'],
      phoneNo: json['phone_no'],
      mobileNo: json['mobile_no'],
      emailId: json['email_id'],
    );
  }

  CreateWarehouseRequest copyWith({
    String? warehouseName,
    String? company,
    String? warehouseType,
    String? parentWarehouse,
    bool? isGroup,
    bool? isMainDepot,
    bool? setAsDefault,
    String? account,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pin,
    String? phoneNo,
    String? mobileNo,
    String? emailId,
  }) {
    return CreateWarehouseRequest(
      warehouseName: warehouseName ?? this.warehouseName,
      company: company ?? this.company,
      warehouseType: warehouseType ?? this.warehouseType,
      parentWarehouse: parentWarehouse ?? this.parentWarehouse,
      isGroup: isGroup ?? this.isGroup,
      isMainDepot: isMainDepot ?? this.isMainDepot,
      setAsDefault: setAsDefault ?? this.setAsDefault,
      account: account ?? this.account,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pin: pin ?? this.pin,
      phoneNo: phoneNo ?? this.phoneNo,
      mobileNo: mobileNo ?? this.mobileNo,
      emailId: emailId ?? this.emailId,
    );
  }

  @override
  String toString() {
    return 'CreateWarehouseRequest(warehouseName: $warehouseName, company: $company, warehouseType: $warehouseType)';
  }
}