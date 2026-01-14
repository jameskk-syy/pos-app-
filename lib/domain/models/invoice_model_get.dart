// Add this to your invoice_model.dart

class GetSalesInvoiceResponse {
  final bool success;
  final SalesInvoiceData? data;
  final String? error;

  GetSalesInvoiceResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory GetSalesInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return GetSalesInvoiceResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null 
          ? SalesInvoiceData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }
}

class SalesInvoiceData {
  final String name;
  final String customer;
  final String company;
  final String postingDate;
  final String dueDate;
  final List<SalesInvoiceItem> items;
  final double grandTotal;
  final String status;
  final int docstatus;

  SalesInvoiceData({
    required this.name,
    required this.customer,
    required this.company,
    required this.postingDate,
    required this.dueDate,
    required this.items,
    required this.grandTotal,
    required this.status,
    required this.docstatus,
  });

  factory SalesInvoiceData.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceData(
      name: json['name'] as String,
      customer: json['customer'] as String,
      company: json['company'] as String,
      postingDate: json['posting_date'] as String,
      dueDate: json['due_date'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => SalesInvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      grandTotal: (json['grand_total'] as num).toDouble(),
      status: json['status'] as String,
      docstatus: json['docstatus'] as int,
    );
  }
}

class SalesInvoiceItem {
  final String itemCode;
  final int qty;
  final double rate;
  final double amount;

  SalesInvoiceItem({
    required this.itemCode,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory SalesInvoiceItem.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceItem(
      itemCode: json['item_code'] as String,
      qty: json['qty'] as int,
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}