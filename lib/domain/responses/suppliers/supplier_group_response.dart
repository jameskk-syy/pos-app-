// supplier_group_response.dart

class SupplierGroupResponse {
  final SupplierGroupMessage message;

  SupplierGroupResponse({required this.message});

  factory SupplierGroupResponse.fromJson(Map<String, dynamic> json) {
    return SupplierGroupResponse(
      message: SupplierGroupMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class SupplierGroupMessage {
  final bool success;
  final List<SupplierGroup> data;
  final int count;

  SupplierGroupMessage({
    required this.success,
    required this.data,
    required this.count,
  });

  factory SupplierGroupMessage.fromJson(Map<String, dynamic> json) {
    return SupplierGroupMessage(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => SupplierGroup.fromJson(item))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
      'count': count,
    };
  }
}

class SupplierGroup {
  final String name;
  final String supplierGroupName;
  final int isGroup;
  final String? parentSupplierGroup;

  SupplierGroup({
    required this.name,
    required this.supplierGroupName,
    required this.isGroup,
    this.parentSupplierGroup,
  });

  factory SupplierGroup.fromJson(Map<String, dynamic> json) {
    return SupplierGroup(
      name: json['name'] ?? '',
      supplierGroupName: json['supplier_group_name'] ?? '',
      isGroup: json['is_group'] ?? 0,
      parentSupplierGroup: json['parent_supplier_group'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'supplier_group_name': supplierGroupName,
      'is_group': isGroup,
      'parent_supplier_group': parentSupplierGroup,
    };
  }
}