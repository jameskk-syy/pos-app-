class WarehouseResponse {
  final WarehouseMessage message;

  WarehouseResponse({required this.message});

  factory WarehouseResponse.fromJson(Map<String, dynamic> json) {
    return WarehouseResponse(
      message: WarehouseMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class WarehouseMessage {
  final bool success;
  final String message;
  final String name;
  final String warehouseName;
  final String company;
  final String warehouseType;
  final int isGroup;
  final bool isMainDepot;
  final bool setAsDefault;
  final String? parentWarehouse;

  WarehouseMessage({
    required this.success,
    required this.message,
    required this.name,
    required this.warehouseName,
    required this.company,
    required this.warehouseType,
    required this.isGroup,
    required this.isMainDepot,
    required this.setAsDefault,
    this.parentWarehouse,
  });

  factory WarehouseMessage.fromJson(Map<String, dynamic> json) {
    return WarehouseMessage(
      success: json['success'],
      message: json['message'],
      name: json['name'],
      warehouseName: json['warehouse_name'],
      company: json['company'],
      warehouseType: json['warehouse_type'],
      isGroup: json['is_group'],
      isMainDepot: json['is_main_depot'],
      setAsDefault: json['set_as_default'],
      parentWarehouse: json['parent_warehouse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'name': name,
      'warehouse_name': warehouseName,
      'company': company,
      'warehouse_type': warehouseType,
      'is_group': isGroup,
      'is_main_depot': isMainDepot,
      'set_as_default': setAsDefault,
      'parent_warehouse': parentWarehouse,
    };
  }
}
