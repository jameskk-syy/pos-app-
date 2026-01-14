class SubmitPurchaseOrderData {
  final int docstatus;
  final double grandTotal;
  final String company;
  final String supplier;
  final int itemsCount;

  SubmitPurchaseOrderData({
    required this.docstatus,
    required this.grandTotal,
    required this.company,
    required this.supplier,
    required this.itemsCount,
  });

  factory SubmitPurchaseOrderData.fromJson(Map<String, dynamic> json) {
    return SubmitPurchaseOrderData(
      docstatus: json['docstatus'] ?? 0,
      grandTotal: (json['grand_total'] ?? 0.0).toDouble(),
      company: json['company'] ?? '',
      supplier: json['supplier'] ?? '',
      itemsCount: json['items_count'] ?? 0,
    );
  }
}

class SubmitPurchaseOrderResponse {
  final SubmitPurchaseOrderData data;
  final String lpoNo;

  SubmitPurchaseOrderResponse({
    required this.data,
    required this.lpoNo,
  });

  factory SubmitPurchaseOrderResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] ?? {};
    return SubmitPurchaseOrderResponse(
      data: SubmitPurchaseOrderData.fromJson(message['data'] ?? {}),
      lpoNo: message['lpo_no'] ?? '',
    );
  }
}