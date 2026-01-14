class ReceiveStockResponse {
  final bool success;
  final String message;
  final ReceiveStockData? data;

  ReceiveStockResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ReceiveStockResponse.fromJson(Map<String, dynamic> json) {
    return ReceiveStockResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? ReceiveStockData.fromJson(json['data']) 
          : null,
    );
  }
}

class ReceiveStockData {
  final String status;
  final String stockEntry;
  final String? goodsReceivedNote;

  ReceiveStockData({
    required this.status,
    required this.stockEntry,
    this.goodsReceivedNote,
  });

  factory ReceiveStockData.fromJson(Map<String, dynamic> json) {
    return ReceiveStockData(
      status: json['status'] ?? '',
      stockEntry: json['stock_entry'] ?? '',
      goodsReceivedNote: json['goods_received_note'],
    );
  }
}