class GrnDetailResponse {
  final bool success;
  final GrnDetailData data;

  GrnDetailResponse({required this.success, required this.data});

  factory GrnDetailResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    return GrnDetailResponse(
      success: message['success'] ?? false,
      data: GrnDetailData.fromJson(message['data'] as Map<String, dynamic>),
    );
  }
}

class GrnDetailData {
  final String grnNo;
  final String supplier;
  final String supplierName;
  final String company;
  final String postingDate;
  final String postingTime;
  final String setWarehouse;
  final String purchaseOrder;
  final String status;
  final int docstatus;
  final int isReturn;
  final double grandTotal;
  final double netTotal;
  final double totalQty;
  final double perBilled;
  final double perReturned;
  final List<GrnItem> items;
  final PurchaseOrderDetails poDetails;

  GrnDetailData({
    required this.grnNo,
    required this.supplier,
    required this.supplierName,
    required this.company,
    required this.postingDate,
    required this.postingTime,
    required this.setWarehouse,
    required this.purchaseOrder,
    required this.status,
    required this.docstatus,
    required this.isReturn,
    required this.grandTotal,
    required this.netTotal,
    required this.totalQty,
    required this.perBilled,
    required this.perReturned,
    required this.items,
    required this.poDetails,
  });

  factory GrnDetailData.fromJson(Map<String, dynamic> json) {
    return GrnDetailData(
      grnNo: json['grn_no'] ?? '',
      supplier: json['supplier'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      company: json['company'] ?? '',
      postingDate: json['posting_date'] ?? '',
      postingTime: json['posting_time'] ?? '',
      setWarehouse: json['set_warehouse'] ?? '',
      purchaseOrder: json['purchase_order'] ?? '',
      status: json['status'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      isReturn: json['is_return'] ?? 0,
      grandTotal: (json['grand_total'] as num).toDouble(),
      netTotal: (json['net_total'] as num).toDouble(),
      totalQty: (json['total_qty'] as num).toDouble(),
      perBilled: (json['per_billed'] as num).toDouble(),
      perReturned: (json['per_returned'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => GrnItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      poDetails: PurchaseOrderDetails.fromJson(
        json['purchase_order_details'] as Map<String, dynamic>,
      ),
    );
  }
}

class GrnItem {
  final String itemCode;
  final String itemName;
  final String description;
  final double qty;
  final double receivedQty;
  final double rejectedQty;
  final double rate;
  final double amount;
  final String warehouse;
  final String uom;
  final String purchaseOrder;
  final String purchaseOrderItem;
  final bool appliedToStock;
  final String? stockEntry;
  final String? stockEntryDate;

  GrnItem({
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.qty,
    required this.receivedQty,
    required this.rejectedQty,
    required this.rate,
    required this.amount,
    required this.warehouse,
    required this.uom,
    required this.purchaseOrder,
    required this.purchaseOrderItem,
    required this.appliedToStock,
    this.stockEntry,
    this.stockEntryDate,
  });

  factory GrnItem.fromJson(Map<String, dynamic> json) {
    return GrnItem(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      description: json['description'] ?? '',
      qty: (json['qty'] as num).toDouble(),
      receivedQty: (json['received_qty'] as num).toDouble(),
      rejectedQty: (json['rejected_qty'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      warehouse: json['warehouse'] ?? '',
      uom: json['uom'] ?? '',
      purchaseOrder: json['purchase_order'] ?? '',
      purchaseOrderItem: json['purchase_order_item'] ?? '',
      appliedToStock: json['applied_to_stock'] ?? false,
      stockEntry: json['stock_entry'],
      stockEntryDate: json['stock_entry_date'],
    );
  }
}

class PurchaseOrderDetails {
  final String poNo;
  final String transactionDate;
  final String status;
  final double grandTotal;

  PurchaseOrderDetails({
    required this.poNo,
    required this.transactionDate,
    required this.status,
    required this.grandTotal,
  });

  factory PurchaseOrderDetails.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetails(
      poNo: json['po_no'] ?? '',
      transactionDate: json['transaction_date'] ?? '',
      status: json['status'] ?? '',
      grandTotal: (json['grand_total'] as num).toDouble(),
    );
  }
}
