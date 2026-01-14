class CreateSupplierGroupResponse {
  final CreateSupplierGrouMessage message;

  CreateSupplierGroupResponse({required this.message});

  factory CreateSupplierGroupResponse.fromJson(Map<String, dynamic> json) {
    return CreateSupplierGroupResponse(
      message: CreateSupplierGrouMessage.fromJson(json['message']),
    );
  }
}

class CreateSupplierGrouMessage {
  final bool success;
  final String message;
  final String name;
  final String supplierGroupName;
  final int isGroup;
  final String parentSupplierGroup;

  CreateSupplierGrouMessage({
    required this.success,
    required this.message,
    required this.name,
    required this.supplierGroupName,
    required this.isGroup,
    required this.parentSupplierGroup,
  });

  factory CreateSupplierGrouMessage.fromJson(Map<String, dynamic> json) {
    return CreateSupplierGrouMessage(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      name: json['name'] ?? '',
      supplierGroupName: json['supplier_group_name'] ?? '',
      isGroup: json['is_group'] ?? 0,
      parentSupplierGroup: json['parent_supplier_group'] ?? '',
    );
  }
}