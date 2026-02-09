import 'dart:convert';

class CompleteCustomerRequest {
  final String name;
  final String customerName;
  final String customerType;
  final String customerGroup;
  final String territory;
  final String taxId;
  final String mobileNo;
  final String emailId;
  final String defaultCurrency;
  final bool disabled;
  final String company;

  CompleteCustomerRequest({
    String? name,  // Make name nullable
    required this.customerName,
    this.customerType = 'Individual',
    this.customerGroup = '',
    this.territory = '',
    required this.taxId,
    this.mobileNo = '',
    required this.emailId,
    this.defaultCurrency = 'KES',
    this.disabled = false,
    this.company = '', String? defaultPriceList,
  }) : name = name ?? customerName;  // Initialize in initializer list only

  factory CompleteCustomerRequest.fromJson(Map<String, dynamic> json) {
    return CompleteCustomerRequest(
      name: json['name'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerType: json['customer_type'] ?? 'Individual',
      customerGroup: json['customer_group'] ?? '',
      territory: json['territory'] ?? '',
      taxId: json['tax_id'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      emailId: json['email_id'] ?? '',
      defaultCurrency: json['default_currency'] ?? 'KES',
      disabled: json['disabled'] ?? false,
      company: json['company'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name.isNotEmpty) 'name': name,
      'customer_name': customerName,
      'customer_type': customerType,
      if (customerGroup.isNotEmpty) 'customer_group': customerGroup,
      if (territory.isNotEmpty) 'territory': territory,
      'tax_id': taxId,
      if (mobileNo.isNotEmpty) 'mobile_no': mobileNo,
      'email_id': emailId,
      'default_currency': defaultCurrency,
      'disabled': disabled,
      if (company.isNotEmpty) 'company': company,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}