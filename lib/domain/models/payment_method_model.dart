class PaymentMethod {
  final String name;
  final String type;
  final bool enabled;
  final List<PaymentAccount> accounts;

  PaymentMethod({
    required this.name,
    required this.type,
    required this.enabled,
    required this.accounts,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      enabled: (json['enabled'] is int ? json['enabled'] : 0) == 1,
      accounts:
          (json['accounts'] as List<dynamic>?)
              ?.map((e) => PaymentAccount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'enabled': enabled ? 1 : 0,
      'accounts': accounts.map((e) => e.toJson()).toList(),
    };
  }
}

class PaymentAccount {
  final String company;
  final String defaultAccount;

  PaymentAccount({required this.company, required this.defaultAccount});

  factory PaymentAccount.fromJson(Map<String, dynamic> json) {
    return PaymentAccount(
      company: json['company']?.toString() ?? '',
      defaultAccount: json['default_account']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'company': company, 'default_account': defaultAccount};
  }
}
