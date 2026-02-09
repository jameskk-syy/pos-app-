// lib/domain/responses/create_purchase_order_response.dart

class CreatePurchaseOrderResponse {
  final PurchaseOrderMessage message;

  CreatePurchaseOrderResponse({required this.message});

  factory CreatePurchaseOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreatePurchaseOrderResponse(
      message: PurchaseOrderMessage.fromJson(json['message']),
    );
  }
}

class PurchaseOrderMessage {
  final String status;
  final String code;
  final String message;
  final PurchaseOrderData data;
  final String lpoNo;

  PurchaseOrderMessage({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    required this.lpoNo,
  });

  factory PurchaseOrderMessage.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderMessage(
      status: json['status'] ?? '',
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: PurchaseOrderData.fromJson(json['data']),
      lpoNo: json['lpo_no'] ?? '',
    );
  }
}

class PurchaseOrderData {
  final int docstatus;
  final double grandTotal;
  final String company;
  final String supplier;
  final int itemsCount;

  PurchaseOrderData({
    required this.docstatus,
    required this.grandTotal,
    required this.company,
    required this.supplier,
    required this.itemsCount,
  });

  factory PurchaseOrderData.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderData(
      docstatus: json['docstatus'] ?? 0,
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
      company: json['company'] ?? '',
      supplier: json['supplier'] ?? '',
      itemsCount: json['items_count'] ?? 0,
    );
  }
}