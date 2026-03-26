class TopSellingItemResponse {
  final bool success;
  final List<TopSellingItem> data;
  final String? error;
  final String? messageTxt;

  TopSellingItemResponse({
    required this.success,
    required this.data,
    this.error,
    this.messageTxt,
  });

  factory TopSellingItemResponse.fromJson(Map<String, dynamic> json) {
    // If the data is nested under 'message'
    if (json.containsKey('message') && json['message'] is Map) {
      final msg = json['message'] as Map<String, dynamic>;
      return TopSellingItemResponse(
        success: msg['success'] ?? false,
        data: msg['data'] != null
            ? (msg['data'] as List)
                .map((i) => TopSellingItem.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
        error: json['error']?.toString() ?? msg['error']?.toString(),
        messageTxt: msg['message']?.toString(),
      );
    }
    
    return TopSellingItemResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => TopSellingItem.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
      error: json['error']?.toString(),
      messageTxt: json['message']?.toString(),
    );
  }
}

class TopSellingItem {
  final String? itemCode;
  final String? itemName;
  final double? totalQty;
  final double? totalRevenue;

  TopSellingItem({
    this.itemCode,
    this.itemName,
    this.totalQty,
    this.totalRevenue,
  });

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    return TopSellingItem(
      itemCode: json['item_code']?.toString(),
      itemName: json['item_name']?.toString(),
      totalQty: json['total_qty'] != null
          ? double.tryParse(json['total_qty'].toString())
          : null,
      totalRevenue: json['total_revenue'] != null
          ? double.tryParse(json['total_revenue'].toString())
          : null,
    );
  }
}
