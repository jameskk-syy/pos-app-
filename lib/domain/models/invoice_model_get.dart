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

class SalesInvoicePayment {
  final String modeOfPayment;
  final double amount;

  SalesInvoicePayment({
    required this.modeOfPayment,
    required this.amount,
  });

  factory SalesInvoicePayment.fromJson(Map<String, dynamic> json) {
    return SalesInvoicePayment(
      modeOfPayment: json['mode_of_payment'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
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
  final String? postingTime;
  final String? setWarehouse;
  final String? owner;
  final List<SalesInvoicePayment>? payments;

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
    this.postingTime,
    this.setWarehouse,
    this.owner,
    this.payments,
  });

  factory SalesInvoiceData.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceData(
      name: json['name'] as String? ?? '',
      customer: json['customer'] as String? ?? '',
      company: json['company'] as String? ?? '',
      postingDate: json['posting_date'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => SalesInvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      docstatus: (json['docstatus'] as num?)?.toInt() ?? 0,
      postingTime: json['posting_time'] as String?,
      setWarehouse: json['set_warehouse'] as String?,
      owner: json['owner'] as String?,
      payments: (json['payments'] as List<dynamic>?)
          ?.map((payment) => SalesInvoicePayment.fromJson(payment as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SalesInvoiceItem {
  final String itemCode;
  final String? itemName;
  final int qty;
  final double rate;
  final double amount;

  SalesInvoiceItem({
    required this.itemCode,
    this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory SalesInvoiceItem.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceItem(
      itemCode: json['item_code'] as String? ?? '',
      itemName: json['item_name'] as String?,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}