class CompanyResponse {
  final MessageData message;

  CompanyResponse({required this.message});

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(message: MessageData.fromJson(json['message']));
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class MessageData {
  final Company company;
  final String message;

  MessageData({required this.company, required this.message});

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      company: Company.fromJson(json['company']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'company': company.toJson(), 'message': message};
  }
}

class Company {
  final String name;
  final String companyName;
  final String abbr;
  final String country;
  final String defaultCurrency;
  final String? taxId;

  Company({
    required this.name,
    required this.companyName,
    required this.abbr,
    required this.country,
    required this.defaultCurrency,
    this.taxId,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      companyName: json['company_name'],
      abbr: json['abbr'],
      country: json['country'],
      defaultCurrency: json['default_currency'],
      taxId: json['tax_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company_name': companyName,
      'abbr': abbr,
      'country': country,
      'default_currency': defaultCurrency,
      'tax_id': taxId,
    };
  }
}
