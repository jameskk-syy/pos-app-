import 'dart:convert';

class PayPurchaseInvoiceRequest {
  final String invoiceNo;
  final double paidAmount;
  final String modeOfPayment;
  final String postingDate;
  final String referenceNo;
  final String referenceDate;
  final String remarks;
  final bool submit;

  PayPurchaseInvoiceRequest({
    required this.invoiceNo,
    required this.paidAmount,
    required this.modeOfPayment,
    required this.postingDate,
    required this.referenceNo,
    required this.referenceDate,
    required this.remarks,
    this.submit = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'invoice_no': invoiceNo,
      'paid_amount': paidAmount,
      'mode_of_payment': modeOfPayment,
      'posting_date': postingDate,
      'reference_no': referenceNo,
      'reference_date': referenceDate,
      'remarks': remarks,
      'submit': submit,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
