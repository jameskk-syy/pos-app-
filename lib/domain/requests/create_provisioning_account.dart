class ProvisionalAccountRequest {
  final String company;
  final bool createAccountIfMissing;

  ProvisionalAccountRequest({
    required this.company,
    required this.createAccountIfMissing,
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'create_account_if_missing': createAccountIfMissing,
    };
  }

  @override
  String toString() {
    return 'ProvisionalAccountRequest(company: $company, createAccountIfMissing: $createAccountIfMissing)';
  }
}