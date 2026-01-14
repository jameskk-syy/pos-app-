import 'dart:convert';

class UpdateCustomerRequest {
  final String name;
  final String customerName;
  final String customerType;
  final String? customerGroup;
  final String? territory;
  final String? taxId;
  final String? mobileNo;
  final String? emailId;
  final String? defaultCurrency;
  final String? defaultPriceList;
  final bool disabled;

  UpdateCustomerRequest({
    required this.name,
    required this.customerName,
    required this.customerType,
    this.customerGroup,
    this.territory,
    this.taxId,
    this.mobileNo,
    this.emailId,
    this.defaultCurrency,
    this.defaultPriceList,
    required this.disabled,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['customer_name'] = customerName;
    map['customer_type'] = customerType;

    if (customerGroup != null && customerGroup!.isNotEmpty) {
      map['customer_group'] = customerGroup;
    }

    if (territory != null && territory!.isNotEmpty) {
      map['territory'] = territory;
    }

    if (taxId != null && taxId!.isNotEmpty) {
      map['tax_id'] = taxId;
    }

    if (mobileNo != null && mobileNo!.isNotEmpty) {
      map['mobile_no'] = mobileNo;
    }

    if (emailId != null && emailId!.isNotEmpty) {
      map['email_id'] = emailId;
    }

    if (defaultCurrency != null && defaultCurrency!.isNotEmpty) {
      map['default_currency'] = defaultCurrency;
    }

    if (defaultPriceList != null && defaultPriceList!.isNotEmpty) {
      map['default_price_list'] = defaultPriceList;
    }

    map['disabled'] = disabled ? 1 : 0;

    return map;
  }

  String toRawJson() => json.encode(toJson());
}
