class CreateSupplierResponse {
  final CreateSupplierMessage message;

  CreateSupplierResponse({required this.message});

  factory CreateSupplierResponse.fromJson(Map<String, dynamic> json) {
    return CreateSupplierResponse(
      message: CreateSupplierMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class CreateSupplierMessage {
  final bool success;
  final String message;
  final String name;
  final String supplierName;

  CreateSupplierMessage({
    required this.success,
    required this.message,
    required this.name,
    required this.supplierName,
  });

  factory CreateSupplierMessage.fromJson(Map<String, dynamic> json) {
    return CreateSupplierMessage(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      name: json['name'] ?? '',
      supplierName: json['supplier_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'name': name,
      'supplier_name': supplierName,
    };
  }
}