class PurchaseInvoiceDetailResponse {
  final String status;
  final String? code;
  final String message;
  final PurchaseInvoiceDetailData data;

  PurchaseInvoiceDetailResponse({
    required this.status,
    this.code,
    required this.message,
    required this.data,
  });

  factory PurchaseInvoiceDetailResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    return PurchaseInvoiceDetailResponse(
      status: message['status'] ?? '',
      code: message['code'],
      message: message['message'] ?? '',
      data: PurchaseInvoiceDetailData.fromJson(
        message['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class PurchaseInvoiceDetailData {
  final String invoiceNo;
  final String supplier;
  final String supplierName;
  final String company;
  final String postingDate;
  final String postingTime;
  final String dueDate;
  final String? billNo;
  final String billDate;
  final String status;
  final int docstatus;
  final int isReturn;
  final int isPaid;
  final String currency;
  final double conversionRate;
  final double grandTotal;
  final double netTotal;
  final double totalTaxesAndCharges;
  final double outstandingAmount;
  final double paidAmount;
  final double writeOffAmount;
  final List<PurchaseInvoiceItem> items;
  final List<dynamic> taxes;
  final List<String> purchaseOrders;
  final List<String> purchaseReceipts;
  final List<dynamic> paymentEntries;
  final List<dynamic> attachments;

  PurchaseInvoiceDetailData({
    required this.invoiceNo,
    required this.supplier,
    required this.supplierName,
    required this.company,
    required this.postingDate,
    required this.postingTime,
    required this.dueDate,
    this.billNo,
    required this.billDate,
    required this.status,
    required this.docstatus,
    required this.isReturn,
    required this.isPaid,
    required this.currency,
    required this.conversionRate,
    required this.grandTotal,
    required this.netTotal,
    required this.totalTaxesAndCharges,
    required this.outstandingAmount,
    required this.paidAmount,
    required this.writeOffAmount,
    required this.items,
    required this.taxes,
    required this.purchaseOrders,
    required this.purchaseReceipts,
    required this.paymentEntries,
    required this.attachments,
  });

  factory PurchaseInvoiceDetailData.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceDetailData(
      invoiceNo: json['invoice_no'] ?? '',
      supplier: json['supplier'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      company: json['company'] ?? '',
      postingDate: json['posting_date'] ?? '',
      postingTime: json['posting_time'] ?? '',
      dueDate: json['due_date'] ?? '',
      billNo: json['bill_no'],
      billDate: json['bill_date'] ?? '',
      status: json['status'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      isReturn: json['is_return'] ?? 0,
      isPaid: json['is_paid'] ?? 0,
      currency: json['currency'] ?? '',
      conversionRate: (json['conversion_rate'] as num).toDouble(),
      grandTotal: (json['grand_total'] as num).toDouble(),
      netTotal: (json['net_total'] as num).toDouble(),
      totalTaxesAndCharges: (json['total_taxes_and_charges'] as num).toDouble(),
      outstandingAmount: (json['outstanding_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num).toDouble(),
      writeOffAmount: (json['write_off_amount'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => PurchaseInvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      taxes: json['taxes'] ?? [],
      purchaseOrders: List<String>.from(json['purchase_orders'] ?? []),
      purchaseReceipts: List<String>.from(json['purchase_receipts'] ?? []),
      paymentEntries: json['payment_entries'] ?? [],
      attachments: json['attachments'] ?? [],
    );
  }
}

class PurchaseInvoiceItem {
  final String itemCode;
  final String itemName;
  final String description;
  final double qty;
  final double rate;
  final double amount;
  final String warehouse;
  final String uom;
  final double stockQty;
  final String? purchaseReceipt;
  final String? purchaseReceiptItem;
  final String? purchaseOrder;
  final String? purchaseOrderItem;

  PurchaseInvoiceItem({
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.warehouse,
    required this.uom,
    required this.stockQty,
    this.purchaseReceipt,
    this.purchaseReceiptItem,
    this.purchaseOrder,
    this.purchaseOrderItem,
  });

  factory PurchaseInvoiceItem.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceItem(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      description: json['description'] ?? '',
      qty: (json['qty'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      warehouse: json['warehouse'] ?? '',
      uom: json['uom'] ?? '',
      stockQty: (json['stock_qty'] as num).toDouble(),
      purchaseReceipt: json['purchase_receipt'],
      purchaseReceiptItem: json['purchase_receipt_item'],
      purchaseOrder: json['purchase_order'],
      purchaseOrderItem: json['purchase_order_item'],
    );
  }
}
