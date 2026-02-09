import 'dart:convert';

class SubmitStockTransferRequest {
  final String requestId;

  SubmitStockTransferRequest({
    required this.requestId,
  });

  factory SubmitStockTransferRequest.fromJson(Map<String, dynamic> json) {
    return SubmitStockTransferRequest(
      requestId: json['request_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}