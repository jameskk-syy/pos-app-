class ZReportResponse {
  final bool success;
  final ZReportData? data;

  ZReportResponse({required this.success, this.data});

  factory ZReportResponse.fromJson(Map<String, dynamic> json) {
    return ZReportResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? ZReportData.fromJson(json['data']) : null,
    );
  }
}

class ZReportData {
  final String posOpeningEntry;
  final String posProfile;
  final String company;
  final String user;
  final String status;
  final String periodStartDate;
  final String periodEndDate;
  final double grandTotal;
  final double netTotal;
  final double totalQuantity;
  final double totalTaxesAndCharges;
  final List<PaymentReconciliation> paymentReconciliation;
  final List<ZReportTax> taxes;
  final int invoicesCount;
  final List<PosTransaction> posTransactions;

  ZReportData({
    required this.posOpeningEntry,
    required this.posProfile,
    required this.company,
    required this.user,
    required this.status,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.grandTotal,
    required this.netTotal,
    required this.totalQuantity,
    required this.totalTaxesAndCharges,
    required this.paymentReconciliation,
    required this.taxes,
    required this.invoicesCount,
    required this.posTransactions,
  });

  factory ZReportData.fromJson(Map<String, dynamic> json) {
    return ZReportData(
      posOpeningEntry: json['pos_opening_entry'] ?? '',
      posProfile: json['pos_profile'] ?? '',
      company: json['company'] ?? '',
      user: json['user'] ?? '',
      status: json['status'] ?? '',
      periodStartDate: json['period_start_date'] ?? '',
      periodEndDate: json['period_end_date'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      netTotal: (json['net_total'] as num?)?.toDouble() ?? 0.0,
      totalQuantity: (json['total_quantity'] as num?)?.toDouble() ?? 0.0,
      totalTaxesAndCharges: (json['total_taxes_and_charges'] as num?)?.toDouble() ?? 0.0,
      paymentReconciliation: (json['payment_reconciliation'] as List?)
              ?.map((e) => PaymentReconciliation.fromJson(e))
              .toList() ??
          [],
      taxes: (json['taxes'] as List?)
              ?.map((e) => ZReportTax.fromJson(e))
              .toList() ??
          [],
      invoicesCount: json['invoices_count'] ?? 0,
      posTransactions: (json['pos_transactions'] as List?)
              ?.map((e) => PosTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PaymentReconciliation {
  final String modeOfPayment;
  final double openingAmount;
  final double expectedAmount;

  PaymentReconciliation({
    required this.modeOfPayment,
    required this.openingAmount,
    required this.expectedAmount,
  });

  factory PaymentReconciliation.fromJson(Map<String, dynamic> json) {
    return PaymentReconciliation(
      modeOfPayment: json['mode_of_payment'] ?? '',
      openingAmount: (json['opening_amount'] as num?)?.toDouble() ?? 0.0,
      expectedAmount: (json['expected_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ZReportTax {
  final String accountHead;
  final double rate;
  final double amount;

  ZReportTax({
    required this.accountHead,
    required this.rate,
    required this.amount,
  });

  factory ZReportTax.fromJson(Map<String, dynamic> json) {
    return ZReportTax(
      accountHead: json['account_head'] ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PosTransaction {
  final String posInvoice;
  final String postingDate;
  final double grandTotal;
  final String customer;

  PosTransaction({
    required this.posInvoice,
    required this.postingDate,
    required this.grandTotal,
    required this.customer,
  });

  factory PosTransaction.fromJson(Map<String, dynamic> json) {
    return PosTransaction(
      posInvoice: json['pos_invoice'] ?? '',
      postingDate: json['posting_date'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      customer: json['customer'] ?? '',
    );
  }
}
