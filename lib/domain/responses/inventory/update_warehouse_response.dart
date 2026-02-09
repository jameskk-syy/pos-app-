class UpdateWarehouseResponse {
  final UpdateWarehouseMessage message;

  UpdateWarehouseResponse({
    required this.message,
  });

  factory UpdateWarehouseResponse.fromJson(Map<String, dynamic> json) =>
      UpdateWarehouseResponse(
        message: UpdateWarehouseMessage.fromJson(json['message']),
      );
}

class UpdateWarehouseMessage {
  final bool success;
  final String message;
  final String name;

  UpdateWarehouseMessage({
    required this.success,
    required this.message,
    required this.name,
  });

  factory UpdateWarehouseMessage.fromJson(Map<String, dynamic> json) => UpdateWarehouseMessage(
        success: json['success'],
        message: json['message'],
        name: json['name'],
      );
}