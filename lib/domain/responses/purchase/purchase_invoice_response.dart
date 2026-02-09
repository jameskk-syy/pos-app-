class PurchaseInvoiceResponse {
  final String status;
  final String message;
  final List<PurchaseInvoiceData> data;
  final Meta meta;

  PurchaseInvoiceResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory PurchaseInvoiceResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    return PurchaseInvoiceResponse(
      status: message['status'] ?? '',
      message: message['message'] ?? '',
      data: (message['data'] as List<dynamic>)
          .map((e) => PurchaseInvoiceData.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: Meta.fromJson(message['meta'] as Map<String, dynamic>),
    );
  }
}

class PurchaseInvoiceData {
  final String name;
  final String supplier;
  final String supplierName;
  final String company;
  final String postingDate;
  final String dueDate;
  final String? billNo;
  final String billDate;
  final double grandTotal;
  final double outstandingAmount;
  final String status;
  final int docstatus;
  final String currency;

  PurchaseInvoiceData({
    required this.name,
    required this.supplier,
    required this.supplierName,
    required this.company,
    required this.postingDate,
    required this.dueDate,
    this.billNo,
    required this.billDate,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.status,
    required this.docstatus,
    required this.currency,
  });

  factory PurchaseInvoiceData.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceData(
      name: json['name'] ?? '',
      supplier: json['supplier'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      company: json['company'] ?? '',
      postingDate: json['posting_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      billNo: json['bill_no'],
      billDate: json['bill_date'] ?? '',
      grandTotal: (json['grand_total'] as num).toDouble(),
      outstandingAmount: (json['outstanding_amount'] as num).toDouble(),
      status: json['status'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      currency: json['currency'] ?? '',
    );
  }
}

class Meta {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  Meta({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
