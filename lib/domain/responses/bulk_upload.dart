class ProcessResponse {
  final String status;
  final int created;
  final int skipped;
  final int failed;
  final List<String> ignoredIndustries;
  final List<dynamic> failedItems;
  final int totalProcessed;

  ProcessResponse({
    required this.status,
    required this.created,
    required this.skipped,
    required this.failed,
    required this.ignoredIndustries,
    required this.failedItems,
    required this.totalProcessed,
  });

  factory ProcessResponse.fromJson(Map<String, dynamic> json) {
    // Handle null message object
    final message = json['message'] as Map<String, dynamic>?;
    
    if (message == null) {
      // Return a default/empty response if message is null
      return ProcessResponse(
        status: 'unknown',
        created: 0,
        skipped: 0,
        failed: 0,
        ignoredIndustries: [],
        failedItems: [],
        totalProcessed: 0,
      );
    }

    return ProcessResponse(
      status: (message['status'] as String?) ?? 'unknown',
      created: (message['created'] as int?) ?? 0,
      skipped: (message['skipped'] as int?) ?? 0,
      failed: (message['failed'] as int?) ?? 0,
      ignoredIndustries: message['ignored_industries'] != null
          ? List<String>.from(message['ignored_industries'] as List)
          : [],
      failedItems: message['failed_items'] != null
          ? List<dynamic>.from(message['failed_items'] as List)
          : [],
      totalProcessed: (message['total_processed'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'status': status,
        'created': created,
        'skipped': skipped,
        'failed': failed,
        'ignored_industries': ignoredIndustries,
        'failed_items': failedItems,
        'total_processed': totalProcessed,
      },
    };
  }

  bool get isSuccess => status == 'success';
  bool get hasFailures => failed > 0;
  double get successRate => totalProcessed > 0 ? (created / totalProcessed) * 100 : 0;
}