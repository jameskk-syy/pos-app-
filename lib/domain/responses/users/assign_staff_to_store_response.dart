class AssignWarehousesResponse {
  final AssignWarehousesMessage message;

  AssignWarehousesResponse({required this.message});

  factory AssignWarehousesResponse.fromJson(Map<String, dynamic> json) {
    return AssignWarehousesResponse(
      message: json['message'] != null
          ? AssignWarehousesMessage.fromJson(
              json['message'] as Map<String, dynamic>,
            )
          : AssignWarehousesMessage.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
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

  factory AssignWarehousesMessage.empty() => AssignWarehousesMessage(
    success: false,
    message: "",
    user: "",
    warehouses: [],
    count: 0,
  );

  factory AssignWarehousesMessage.fromJson(Map<String, dynamic> json) {
    return AssignWarehousesMessage(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      user: json['user'] ?? "",
      warehouses: List<String>.from(json['warehouses'] ?? []),
      count: json['count'] ?? 0,
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
