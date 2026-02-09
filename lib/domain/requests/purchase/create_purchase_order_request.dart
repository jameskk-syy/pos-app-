// lib/domain/requests/create_purchase_order_request.dart

class CreatePurchaseOrderRequest {
  final String company;
  final String supplier;
  final String transactionDate;
  final List<PurchaseOrderItemRequest> items;

  CreatePurchaseOrderRequest({
    required this.company,
    required this.supplier,
    required this.transactionDate,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'supplier': supplier,
      'transaction_date': transactionDate,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class PurchaseOrderItemRequest {
  final String itemCode;
  final double qty;
  final double rate;
  final String warehouse;
  final String scheduleDate;

  PurchaseOrderItemRequest({
    required this.itemCode,
    required this.qty,
    required this.rate,
    required this.warehouse,
    required this.scheduleDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
      'rate': rate,
      'warehouse': warehouse,
      'schedule_date': scheduleDate,
    };
  }
}