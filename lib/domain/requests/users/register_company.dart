import 'dart:convert';

class CompanyAddress {
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String phone;
  final String emailId;

  CompanyAddress({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.phone,
    required this.emailId,
  });

  Map<String, dynamic> toJson() => {
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'phone': phone,
        'email_id': emailId,
      };

  factory CompanyAddress.fromJson(Map<String, dynamic> json) => CompanyAddress(
        addressLine1: json['address_line1'] ?? '',
        addressLine2: json['address_line2'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        country: json['country'] ?? '',
        pincode: json['pincode'] ?? '',
        phone: json['phone'] ?? '',
        emailId: json['email_id'] ?? '',
      );
}

class CompanyContact {
  final String firstName;
  final String lastName;
  final String email;

  CompanyContact({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

  factory CompanyContact.fromJson(Map<String, dynamic> json) => CompanyContact(
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        email: json['email'] ?? '',
      );
}

class CompanyRequest {
  final String companyName;
  final String abbr;
  final String country;
  final String defaultCurrency;
  final CompanyAddress companyAddress;
  final CompanyContact companyContact;

  CompanyRequest({
    required this.companyName,
    required this.abbr,
    required this.country,
    required this.defaultCurrency,
    required this.companyAddress,
    required this.companyContact,
  });

  Map<String, dynamic> toJson() => {
        'company_name': companyName,
        'abbr': abbr,
        'country': country,
        'default_currency': defaultCurrency,
        'company_address': companyAddress.toJson(),
        'company_contact': companyContact.toJson(),
      };

  factory CompanyRequest.fromJson(Map<String, dynamic> json) => CompanyRequest(
        companyName: json['company_name'] ?? '',
        abbr: json['abbr'] ?? '',
        country: json['country'] ?? '',
        defaultCurrency: json['default_currency'] ?? '',
        companyAddress: CompanyAddress.fromJson(json['company_address'] ?? {}),
        companyContact: CompanyContact.fromJson(json['company_contact'] ?? {}),
      );

  String toJsonString() => jsonEncode(toJson());

  factory CompanyRequest.fromJsonString(String str) =>
      CompanyRequest.fromJson(jsonDecode(str));
}