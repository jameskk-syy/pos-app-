// domain/responses/update_credit_limit_response.dart
class UpdateCreditLimitResponse {
  final bool success;
  final String message;
  final CreditLimitData data;

  UpdateCreditLimitResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UpdateCreditLimitResponse.fromJson(Map<String, dynamic> json) {
    final msg = json['message'];

    return UpdateCreditLimitResponse(
      success: msg['success'] ?? false,
      message: msg['message'] ?? '',
      data: CreditLimitData.fromJson(msg['data']),
    );
  }
}

class CreditLimitData {
  final String customer;
  final String company;
  final double creditLimit;
  final bool bypassCreditLimitCheck;
  final double effectiveCreditLimit;
  final double outstandingAmount;
  final double availableCredit;
  final double creditUtilizationPercent;

  CreditLimitData({
    required this.customer,
    required this.company,
    required this.creditLimit,
    required this.bypassCreditLimitCheck,
    required this.effectiveCreditLimit,
    required this.outstandingAmount,
    required this.availableCredit,
    required this.creditUtilizationPercent,
  });

  factory CreditLimitData.fromJson(Map<String, dynamic> json) {
    return CreditLimitData(
      customer: json['customer'],
      company: json['company'],
      creditLimit: (json['credit_limit'] as num).toDouble(),
      bypassCreditLimitCheck: json['bypass_credit_limit_check'],
      effectiveCreditLimit:
          (json['effective_credit_limit'] as num).toDouble(),
      outstandingAmount:
          (json['outstanding_amount'] as num).toDouble(),
      availableCredit:
          (json['available_credit'] as num).toDouble(),
      creditUtilizationPercent:
          (json['credit_utilization_percent'] as num).toDouble(),
    );
  }
}
