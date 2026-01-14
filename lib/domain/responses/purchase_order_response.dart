// lib/data/models/purchase_order_response.dart

class PurchaseOrderResponse {
  final String status;
  final int totalCount;
  final List<PurchaseOrderData> purchaseOrders;

  PurchaseOrderResponse({
    required this.status,
    required this.totalCount,
    required this.purchaseOrders,
  });

  factory PurchaseOrderResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    return PurchaseOrderResponse(
      status: message['status'] as String,
      totalCount: message['total_count'] as int,
      purchaseOrders: (message['purchase_orders'] as List<dynamic>)
          .map((e) => PurchaseOrderData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'status': status,
        'total_count': totalCount,
        'purchase_orders': purchaseOrders.map((e) => e.toJson()).toList(),
      }
    };
  }
}

class PurchaseOrderData {
  final String name;
  final String supplier;
  final String company;
  final String transactionDate;
  final String status;
  final int docstatus;
  final double grandTotal;

  PurchaseOrderData({
    required this.name,
    required this.supplier,
    required this.company,
    required this.transactionDate,
    required this.status,
    required this.docstatus,
    required this.grandTotal,
  });

  factory PurchaseOrderData.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderData(
      name: json['name'] as String,
      supplier: json['supplier'] as String,
      company: json['company'] as String,
      transactionDate: json['transaction_date'] as String,
      status: json['status'] as String,
      docstatus: json['docstatus'] as int,
      grandTotal: (json['grand_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'supplier': supplier,
      'company': company,
      'transaction_date': transactionDate,
      'status': status,
      'docstatus': docstatus,
      'grand_total': grandTotal,
    };
  }
}