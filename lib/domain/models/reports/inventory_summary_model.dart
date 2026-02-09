class InventorySummaryResponse {
  final bool success;
  final List<InventorySummaryData> data;

  InventorySummaryResponse({required this.success, required this.data});

  factory InventorySummaryResponse.fromJson(Map<String, dynamic> json) {
    // Check if the response is wrapped in a 'message' object
    Map<String, dynamic> source = json;
    if (json.containsKey('message') &&
        json['message'] is Map<String, dynamic>) {
      source = json['message'];
    }

    return InventorySummaryResponse(
      success: source['success'] ?? true,
      data:
          (source['data'] as List?)
              ?.map((e) => InventorySummaryData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class InventorySummaryData {
  final String warehouse;
  final double totalQty;
  final double totalValue;

  InventorySummaryData({
    required this.warehouse,
    required this.totalQty,
    required this.totalValue,
  });

  factory InventorySummaryData.fromJson(Map<String, dynamic> json) {
    return InventorySummaryData(
      warehouse: json['warehouse'] ?? '',
      totalQty: (json['total_qty'] as num?)?.toDouble() ?? 0.0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
