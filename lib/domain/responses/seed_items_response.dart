class CreateOrderResponse {
  final CreateOrderMessage message;

  CreateOrderResponse({required this.message});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      message: CreateOrderMessage.fromJson(json['message']),
    );
  }
}

class CreateOrderMessage {
  final String status;
  final int created;
  final int skipped;
  final List<dynamic> failed;
  final int totalReceived;

  CreateOrderMessage({
    required this.status,
    required this.created,
    required this.skipped,
    required this.failed,
    required this.totalReceived,
  });

  factory CreateOrderMessage.fromJson(Map<String, dynamic> json) {
    return CreateOrderMessage(
      status: json['status'] ?? '',
      created: json['created'] ?? 0,
      skipped: json['skipped'] ?? 0,
      failed: (json['failed'] as List<dynamic>?) ?? [],
      totalReceived: json['total_received'] ?? 0,
    );
  }
}