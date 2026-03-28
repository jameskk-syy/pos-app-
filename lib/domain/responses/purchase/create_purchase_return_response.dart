class CreatePurchaseReturnResponse {
  final String status;
  final String? message;
  final PurchaseReturnData? data;

  CreatePurchaseReturnResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory CreatePurchaseReturnResponse.fromJson(Map<String, dynamic> json) {
    final messageData = json['message'] as Map<String, dynamic>?;
    
    return CreatePurchaseReturnResponse(
      status: messageData?['status'] as String? ?? 'error',
      message: messageData?['message'] as String?,
      data: messageData?['data'] != null
          ? PurchaseReturnData.fromJson(messageData!['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PurchaseReturnData {
  final String name;
  final int docstatus;
  final double grandTotal;

  PurchaseReturnData({
    required this.name,
    required this.docstatus,
    required this.grandTotal,
  });

  factory PurchaseReturnData.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnData(
      name: json['name']?.toString() ?? '',
      docstatus: json['docstatus'] as int? ?? 0,
      grandTotal: (json['grand_total'] as num? ?? 0.0).toDouble(),
    );
  }
}
