class CreateWarehouseResponse {
  final WarehouseCreateMessage message;

  CreateWarehouseResponse({
    required this.message,
  });

  factory CreateWarehouseResponse.fromJson(Map<String, dynamic> json) {
    return CreateWarehouseResponse(
      message: WarehouseCreateMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }

  @override
  String toString() {
    return 'CreateWarehouseResponse(message: $message)';
  }
}

class WarehouseCreateMessage {
  final bool success;
  final String message;
  final String name;
  final String warehouseName;
  final String company;
  final String? warehouseType;
  final int isGroup;
  final bool isMainDepot;
  final bool setAsDefault;
  final String? parentWarehouse;

  WarehouseCreateMessage({
    required this.success,
    required this.message,
    required this.name,
    required this.warehouseName,
    required this.company,
    this.warehouseType,
    required this.isGroup,
    required this.isMainDepot,
    required this.setAsDefault,
    this.parentWarehouse,
  });

  factory WarehouseCreateMessage.fromJson(Map<String, dynamic> json) {
    return WarehouseCreateMessage(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      name: json['name'] ?? '',
      warehouseName: json['warehouse_name'] ?? '',
      company: json['company'] ?? '',
      warehouseType: json['warehouse_type'],
      isGroup: json['is_group'] ?? 0,
      isMainDepot: json['is_main_depot'] ?? false,
      setAsDefault: json['set_as_default'] ?? false,
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

  WarehouseCreateMessage copyWith({
    bool? success,
    String? message,
    String? name,
    String? warehouseName,
    String? company,
    String? warehouseType,
    int? isGroup,
    bool? isMainDepot,
    bool? setAsDefault,
    String? parentWarehouse,
  }) {
    return WarehouseCreateMessage(
      success: success ?? this.success,
      message: message ?? this.message,
      name: name ?? this.name,
      warehouseName: warehouseName ?? this.warehouseName,
      company: company ?? this.company,
      warehouseType: warehouseType ?? this.warehouseType,
      isGroup: isGroup ?? this.isGroup,
      isMainDepot: isMainDepot ?? this.isMainDepot,
      setAsDefault: setAsDefault ?? this.setAsDefault,
      parentWarehouse: parentWarehouse ?? this.parentWarehouse,
    );
  }

  @override
  String toString() {
    return 'WarehouseCreateMessage(success: $success, message: $message, name: $name, warehouseName: $warehouseName)';
  }
}