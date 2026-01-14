// domain/requests/update_credit_limit_request.dart
class UpdateCreditLimitRequest {
  final String customer;
  final String company;
  final double creditLimit;
  final bool bypassCreditLimitCheck;

  UpdateCreditLimitRequest({
    required this.customer,
    required this.company,
    required this.creditLimit,
    required this.bypassCreditLimitCheck,
  });

  Map<String, dynamic> toJson() {
    return {
      "customer": customer,
      "company": company,
      "credit_limit": creditLimit,
      "bypass_credit_limit_check": bypassCreditLimitCheck,
    };
  }
}
