class SubmitStockTransferResponse {
  final SubmitStockTransferMessage message;

  SubmitStockTransferResponse({
    required this.message,
  });

  factory SubmitStockTransferResponse.fromJson(Map<String, dynamic> json) {
    return SubmitStockTransferResponse(
      message: SubmitStockTransferMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class SubmitStockTransferMessage {
  final bool success;
  final String message;
  final SubmitStockTransferData data;

  SubmitStockTransferMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubmitStockTransferMessage.fromJson(Map<String, dynamic> json) {
    return SubmitStockTransferMessage(
      success: json['success'],
      message: json['message'],
      data: SubmitStockTransferData.fromJson(json['data']),
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

class SubmitStockTransferData {
  final String requestId;
  final String status;
  final int docstatus;

  SubmitStockTransferData({
    required this.requestId,
    required this.status,
    required this.docstatus,
  });

  factory SubmitStockTransferData.fromJson(Map<String, dynamic> json) {
    return SubmitStockTransferData(
      requestId: json['request_id'],
      status: json['status'],
      docstatus: json['docstatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'status': status,
      'docstatus': docstatus,
    };
  }
}