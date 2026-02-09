class PayPurchaseInvoiceResponse {
  final bool success;
  final String status;
  final String message;
  final PayPurchaseInvoiceData? data;

  PayPurchaseInvoiceResponse({
    required this.success,
    required this.status,
    required this.message,
    this.data,
  });

  factory PayPurchaseInvoiceResponse.fromJson(Map<String, dynamic> json) {
    final messageObj = json['message'] as Map<String, dynamic>;
    return PayPurchaseInvoiceResponse(
      success: messageObj['status'] == 'success',
      status: messageObj['status'] ?? '',
      message: messageObj['message'] ?? '',
      data: messageObj['data'] != null
          ? PayPurchaseInvoiceData.fromJson(
              messageObj['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class PayPurchaseInvoiceData {
  final PaymentEntry? paymentEntry;
  final PurchaseInvoiceSummary? purchaseInvoice;

  PayPurchaseInvoiceData({this.paymentEntry, this.purchaseInvoice});

  factory PayPurchaseInvoiceData.fromJson(Map<String, dynamic> json) {
    return PayPurchaseInvoiceData(
      paymentEntry: json['payment_entry'] != null
          ? PaymentEntry.fromJson(json['payment_entry'] as Map<String, dynamic>)
          : null,
      purchaseInvoice: json['purchase_invoice'] != null
          ? PurchaseInvoiceSummary.fromJson(
              json['purchase_invoice'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class PaymentEntry {
  final String name;
  final String paymentType;
  final String party;
  final String partyType;
  final double paidAmount;
  final double receivedAmount;
  final String postingDate;
  final String modeOfPayment;
  final int docstatus;
  final bool submitted;

  PaymentEntry({
    required this.name,
    required this.paymentType,
    required this.party,
    required this.partyType,
    required this.paidAmount,
    required this.receivedAmount,
    required this.postingDate,
    required this.modeOfPayment,
    required this.docstatus,
    required this.submitted,
  });

  factory PaymentEntry.fromJson(Map<String, dynamic> json) {
    return PaymentEntry(
      name: json['name'] ?? '',
      paymentType: json['payment_type'] ?? '',
      party: json['party'] ?? '',
      partyType: json['party_type'] ?? '',
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      receivedAmount: (json['received_amount'] as num?)?.toDouble() ?? 0.0,
      postingDate: json['posting_date'] ?? '',
      modeOfPayment: json['mode_of_payment'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      submitted: json['submitted'] ?? false,
    );
  }
}

class PurchaseInvoiceSummary {
  final String name;
  final double outstandingAmount;
  final String status;
  final double paidAmount;
  final double grandTotal;

  PurchaseInvoiceSummary({
    required this.name,
    required this.outstandingAmount,
    required this.status,
    required this.paidAmount,
    required this.grandTotal,
  });

  factory PurchaseInvoiceSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceSummary(
      name: json['name'] ?? '',
      outstandingAmount:
          (json['outstanding_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
