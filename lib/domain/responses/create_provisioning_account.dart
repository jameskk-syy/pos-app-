class ProvisionalAccountResponse {
  final ProvisionalMessage message;

  ProvisionalAccountResponse({required this.message});

  factory ProvisionalAccountResponse.fromJson(Map<String, dynamic> json) {
    return ProvisionalAccountResponse(
      message: ProvisionalMessage.fromJson(json['message']),
    );
  }
}

class ProvisionalMessage {
  final bool success;
  final String message;
  final ProvisionalData data;
  final bool autoConfigured;
  final bool accountCreated;

  ProvisionalMessage({
    required this.success,
    required this.message,
    required this.data,
    required this.autoConfigured,
    required this.accountCreated,
  });

  factory ProvisionalMessage.fromJson(Map<String, dynamic> json) {
    return ProvisionalMessage(
      success: json['success'],
      message: json['message'],
      data: ProvisionalData.fromJson(json['data']),
      autoConfigured: json['auto_configured'],
      accountCreated: json['account_created'],
    );
  }
}

class ProvisionalData {
  final String company;
  final String account;
  final String accountName;
  final String accountType;
  final String rootType;
  final int provisionalAccountingEnabled;

  ProvisionalData({
    required this.company,
    required this.account,
    required this.accountName,
    required this.accountType,
    required this.rootType,
    required this.provisionalAccountingEnabled,
  });

  factory ProvisionalData.fromJson(Map<String, dynamic> json) {
    return ProvisionalData(
      company: json['company'],
      account: json['account'],
      accountName: json['account_name'],
      accountType: json['account_type'],
      rootType: json['root_type'],
      provisionalAccountingEnabled:
          json['provisional_accounting_enabled'],
    );
  }
}
