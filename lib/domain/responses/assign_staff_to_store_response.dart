class AssignWarehousesResponse {
  final AssignWarehousesMessage message;

  AssignWarehousesResponse({required this.message});

  factory AssignWarehousesResponse.fromJson(Map<String, dynamic> json) {
    return AssignWarehousesResponse(
      message: AssignWarehousesMessage.fromJson(json['message'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class AssignWarehousesMessage {
  final bool success;
  final String message;
  final String user;
  final List<String> warehouses;
  final int count;

  AssignWarehousesMessage({
    required this.success,
    required this.message,
    required this.user,
    required this.warehouses,
    required this.count,
  });

  factory AssignWarehousesMessage.fromJson(Map<String, dynamic> json) {
    return AssignWarehousesMessage(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: json['user'] as String,
      warehouses: List<String>.from(json['warehouses'] ?? []),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user,
      'warehouses': warehouses,
      'count': count,
    };
  }
}
