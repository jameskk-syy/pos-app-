class StoreGetResponse {
  final ResponseMessage message;

  StoreGetResponse({
    required this.message,
  });

  factory StoreGetResponse.fromJson(Map<String, dynamic> json) {
    return StoreGetResponse(
      message: ResponseMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class ResponseMessage {
  final bool success;
  final List<Warehouse> data;

  ResponseMessage({
    required this.success,
    required this.data,
  });

  factory ResponseMessage.fromJson(Map<String, dynamic> json) {
    return ResponseMessage(
      success: json['success'] ?? false,
      data: json['data'] is List
          ? (json['data'] as List)
              .map((item) => Warehouse.fromJson(item))
              .toList()
          : [Warehouse.fromJson(json['data'])], // Handle single object as list
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Warehouse {
  final String name;
  final String warehouseName;
  final String company;
  final String? warehouseType;
  final String? warehouseTypeDescription;
  final int isGroup;
  final String? parentWarehouse;
  final String? account;
  final int disabled;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pin;
  final String? phoneNo;
  final String? mobileNo;
  final String? emailId;
  final bool isMainDepot;
  final bool isDefault;

  Warehouse({
    required this.name,
    required this.warehouseName,
    required this.company,
    this.warehouseType,
    this.warehouseTypeDescription,
    required this.isGroup,
    this.parentWarehouse,
    this.account,
    required this.disabled,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pin,
    this.phoneNo,
    this.mobileNo,
    this.emailId,
    required this.isMainDepot,
    required this.isDefault,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      name: json['name'] ?? '',
      warehouseName: json['warehouse_name'] ?? '',
      company: json['company'] ?? '',
      warehouseType: json['warehouse_type'],
      warehouseTypeDescription: json['warehouse_type_description'],
      isGroup: json['is_group'] ?? 0,
      parentWarehouse: json['parent_warehouse'],
      account: json['account'],
      disabled: json['disabled'] ?? 0,
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      city: json['city'],
      state: json['state'],
      pin: json['pin'],
      phoneNo: json['phone_no'],
      mobileNo: json['mobile_no'],
      emailId: json['email_id'],
      isMainDepot: json['is_main_depot'] ?? false,
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'warehouse_name': warehouseName,
      'company': company,
      'warehouse_type': warehouseType,
      'warehouse_type_description': warehouseTypeDescription,
      'is_group': isGroup,
      'parent_warehouse': parentWarehouse,
      'account': account,
      'disabled': disabled,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'pin': pin,
      'phone_no': phoneNo,
      'mobile_no': mobileNo,
      'email_id': emailId,
      'is_main_depot': isMainDepot,
      'is_default': isDefault,
    };
  }
}