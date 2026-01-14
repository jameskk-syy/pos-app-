class PurchaseOrderDetailResponse {
  final String status;
  final PurchaseOrderDetail purchaseOrder;

  PurchaseOrderDetailResponse({
    required this.status,
    required this.purchaseOrder,
  });

  factory PurchaseOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    final messageData = json['message'] as Map<String, dynamic>;
    
    return PurchaseOrderDetailResponse(
      status: messageData['status'] as String,
      purchaseOrder: PurchaseOrderDetail.fromJson(
        messageData['purchase_order'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'status': status,
        'purchase_order': purchaseOrder.toJson(),
      }
    };
  }
}

class PurchaseOrderDetail {
  final String name;
  final String supplier;
  final String company;
  final String transactionDate;
  final String status;
  final int docstatus;
  final double grandTotal;
  final double totalQty;
  final String currency;
  final String? idempotencyKey;
  final String? taxesAndCharges;
  final List<PurchaseOrderItem> items;
  final List<PurchaseReceipt> purchaseReceipts;

  PurchaseOrderDetail({
    required this.name,
    required this.supplier,
    required this.company,
    required this.transactionDate,
    required this.status,
    required this.docstatus,
    required this.grandTotal,
    required this.totalQty,
    required this.currency,
    this.idempotencyKey,
    this.taxesAndCharges,
    required this.items,
    required this.purchaseReceipts,
  });

  factory PurchaseOrderDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetail(
      name: json['name'] as String,
      supplier: json['supplier'] as String,
      company: json['company'] as String,
      transactionDate: json['transaction_date'] as String,
      status: json['status'] as String,
      docstatus: json['docstatus'] as int,
      grandTotal: (json['grand_total'] as num).toDouble(),
      totalQty: (json['total_qty'] as num).toDouble(),
      currency: json['currency'] as String,
      idempotencyKey: json['idempotency_key'] as String?,
      taxesAndCharges: json['taxes_and_charges'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => PurchaseOrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      purchaseReceipts: (json['purchase_receipts'] as List<dynamic>)
          .map((receipt) {
            // Handle both string and object formats
            if (receipt is String) {
              return PurchaseReceipt(name: receipt);
            } else if (receipt is Map<String, dynamic>) {
              return PurchaseReceipt.fromJson(receipt);
            } else {
              return PurchaseReceipt(name: null);
            }
          })
          .toList(),
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
      'total_qty': totalQty,
      'currency': currency,
      'idempotency_key': idempotencyKey,
      'taxes_and_charges': taxesAndCharges,
      'items': items.map((item) => item.toJson()).toList(),
      'purchase_receipts': purchaseReceipts.map((receipt) => receipt.toJson()).toList(),
    };
  }
}

class PurchaseOrderItem {
  final String itemCode;
  final String description;
  final double qty;
  final String uom;
  final double rate;
  final double amount;
  final String warehouse;
  final String? materialRequest;
  final String? materialRequestItem;

  PurchaseOrderItem({
    required this.itemCode,
    required this.description,
    required this.qty,
    required this.uom,
    required this.rate,
    required this.amount,
    required this.warehouse,
    this.materialRequest,
    this.materialRequestItem,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      itemCode: json['item_code'] as String,
      description: json['description'] as String,
      qty: (json['qty'] as num).toDouble(),
      uom: json['uom'] as String,
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      warehouse: json['warehouse'] as String,
      materialRequest: json['material_request'] as String?,
      materialRequestItem: json['material_request_item'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'description': description,
      'qty': qty,
      'uom': uom,
      'rate': rate,
      'amount': amount,
      'warehouse': warehouse,
      'material_request': materialRequest,
      'material_request_item': materialRequestItem,
    };
  }
}

class PurchaseReceipt {
  final String? name;
  final String? status;
  final double? receivedQty;

  PurchaseReceipt({
    this.name,
    this.status,
    this.receivedQty,
  });

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) {
    return PurchaseReceipt(
      name: json['name'] as String?,
      status: json['status'] as String?,
      receivedQty: json['received_qty'] != null 
          ? (json['received_qty'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'received_qty': receivedQty,
    };
  }
}