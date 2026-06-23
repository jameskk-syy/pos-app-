
class ProcessResponse {
  final String status;
  final int created;
  final int skipped;
  final int failed;
  final List<dynamic> failedItems;
  final List<dynamic> skippedItems;
  final int totalProcessed;

  ProcessResponse({
    required this.status,
    required this.created,
    required this.skipped,
    required this.failed,
    required this.failedItems,
    required this.skippedItems,
    required this.totalProcessed,
  });

  factory ProcessResponse.fromJson(Map<String, dynamic> json) {
    // Handle null message object
    final message = json['message'] as Map<String, dynamic>?;
    
    if (message == null) {
      return ProcessResponse(
        status: 'unknown',
        created: 0,
        skipped: 0,
        failed: 0,
        failedItems: [],
        skippedItems: [],
        totalProcessed: 0,
      );
    }

    final String status = (message['status'] as String?) ?? 'unknown';
    
    // Parse arrays from new API format
    final List<dynamic> itemsCreated = message['items_created'] as List<dynamic>? ?? [];
    final List<dynamic> itemsSkipped = message['items_skipped'] as List<dynamic>? ?? [];
    final List<dynamic> itemsFailed = message['items_failed'] as List<dynamic>? ?? [];
    
    final int createdCount = itemsCreated.length;
    final int skippedCount = itemsSkipped.length;
    final int failedCount = itemsFailed.length;
    final int totalReceived = (message['total_received'] as int?) ?? (createdCount + skippedCount + failedCount);

    return ProcessResponse(
      status: status,
      created: createdCount,
      skipped: skippedCount,
      failed: failedCount,
      failedItems: itemsFailed,
      skippedItems: itemsSkipped,
      totalProcessed: totalReceived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'status': status,
        'items_created': [],
        'items_skipped': skippedItems,
        'items_failed': failedItems,
        'total_received': totalProcessed,
      },
    };
  }

  bool get isSuccess => status == 'success';
  bool get hasFailures => failed > 0;
  bool get hasIssues => failed > 0 || skipped > 0;
  double get successRate => totalProcessed > 0 ? (created / totalProcessed) * 100 : 0;
}