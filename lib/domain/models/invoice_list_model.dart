class InvoiceListItem {
  final String name;
  final String customer;
  final String postingDate;
  final String company;
  final double grandTotal;
  final double roundedTotal;
  final double outstandingAmount;
  final double paidAmount;
  final String status;
  final String? posProfile;
  final int docstatus;
  final bool isPartiallyPaid;
  final double creditAmount;
  final double creditOutstanding;

  InvoiceListItem({
    required this.name,
    required this.customer,
    required this.postingDate,
    required this.company,
    required this.grandTotal,
    required this.roundedTotal,
    required this.outstandingAmount,
    required this.paidAmount,
    required this.status,
    this.posProfile,
    required this.docstatus,
    required this.isPartiallyPaid,
    required this.creditAmount,
    required this.creditOutstanding,
  });

  factory InvoiceListItem.fromJson(Map<String, dynamic> json) {
    return InvoiceListItem(
      name: json['name'] ?? '',
      customer: json['customer'] ?? '',
      postingDate: json['posting_date'] ?? '',
      company: json['company'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      roundedTotal: (json['rounded_total'] as num?)?.toDouble() ?? 0.0,
      outstandingAmount:
          (json['outstanding_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      posProfile: json['pos_profile'],
      docstatus: (json['docstatus'] as num?)?.toInt() ?? 0,
      isPartiallyPaid:
          json['is_partially_paid'] == 1 || json['is_partially_paid'] == true,
      creditAmount: (json['credit_amount'] as num?)?.toDouble() ?? 0.0,
      creditOutstanding:
          (json['credit_outstanding'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'customer': customer,
      'posting_date': postingDate,
      'company': company,
      'grand_total': grandTotal,
      'rounded_total': roundedTotal,
      'outstanding_amount': outstandingAmount,
      'paid_amount': paidAmount,
      'status': status,
      'pos_profile': posProfile,
      'docstatus': docstatus,
      'is_partially_paid': isPartiallyPaid,
      'credit_amount': creditAmount,
      'credit_outstanding': creditOutstanding,
    };
  }
}

class InvoiceListResponse {
  final bool success;
  final List<InvoiceListItem> data;
  final int count;

  InvoiceListResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) {
    // Some responses might wrap data in 'message'
    final messageData = json['message'] as Map<String, dynamic>? ?? json;

    final List<dynamic> listData = messageData['data'] as List<dynamic>? ?? [];
    return InvoiceListResponse(
      success: messageData['success'] as bool? ?? true,
      data: listData
          .map((e) => InvoiceListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (messageData['count'] as num?)?.toInt() ?? listData.length,
    );
  }
}
