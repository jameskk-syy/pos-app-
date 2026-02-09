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
    final itemsCreated = (json['items_created'] as List<dynamic>?) ?? [];
    final itemsSkipped = (json['items_skipped'] as List<dynamic>?) ?? [];
    final itemsFailed = (json['items_failed'] as List<dynamic>?) ?? [];

    return CreateOrderMessage(
      status: json['status'] ?? '',
      created: itemsCreated.isNotEmpty
          ? itemsCreated.length
          : (json['created'] ?? 0),
      skipped: itemsSkipped.isNotEmpty
          ? itemsSkipped.length
          : (json['skipped'] ?? 0),
      failed: itemsFailed.isNotEmpty
          ? itemsFailed
          : ((json['failed'] as List<dynamic>?) ?? []),
      totalReceived: json['total_received'] ?? 0,
    );
  }
}
