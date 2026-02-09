class DispatchStockTransferResponse {
  final DispatchMessage message;

  DispatchStockTransferResponse({
    required this.message,
  });

  factory DispatchStockTransferResponse.fromJson(Map<String, dynamic> json) {
    return DispatchStockTransferResponse(
      message: DispatchMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class DispatchMessage {
  final bool success;
  final String message;
  final DispatchStockTransferData data;

  DispatchMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DispatchMessage.fromJson(Map<String, dynamic> json) {
    return DispatchMessage(
      success: json['success'],
      message: json['message'],
      data: DispatchStockTransferData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class DispatchStockTransferData {
  final String status;
  final String stockEntry;

  DispatchStockTransferData({
    required this.status,
    required this.stockEntry,
  });

  factory DispatchStockTransferData.fromJson(Map<String, dynamic> json) {
    return DispatchStockTransferData(
      status: json['status'],
      stockEntry: json['stock_entry'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'stock_entry': stockEntry,
    };
  }
}