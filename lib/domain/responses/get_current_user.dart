class CurrentUserResponse {
  final CurrentUserMessage message;

  CurrentUserResponse({required this.message});

  factory CurrentUserResponse.fromJson(Map<String, dynamic> json) {
    return CurrentUserResponse(
      message: CurrentUserMessage.fromJson(
        json['message'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class CurrentUserMessage {
  final User user;
  final Company company;
  final PosProfile posProfile;
  final PosIndustry posIndustry;
  final List<String> roles;
  final Map<String, List<Permission>> permissions;
  final String defaultWarehouse;

  CurrentUserMessage({
    required this.user,
    required this.company,
    required this.posProfile,
    required this.posIndustry,
    required this.roles,
    required this.permissions,
    required this.defaultWarehouse,
  });

  factory CurrentUserMessage.fromJson(Map<String, dynamic> json) {
    final Map<String, List<Permission>> perms = {};

    final permissionsJson = json['permissions'] as Map<String, dynamic>?;

    if (permissionsJson != null && permissionsJson.isNotEmpty) {
      permissionsJson.forEach((key, value) {
        if (value is List) {
          perms[key] = value
              .map((e) => Permission.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      });
    }

    return CurrentUserMessage(
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      company: Company.fromJson(json['company'] as Map<String, dynamic>? ?? {}),
      posProfile: PosProfile.fromJson(
          json['pos_profile'] as Map<String, dynamic>? ?? {}),
      posIndustry: PosIndustry.fromJson(
          json['pos_industry'] as Map<String, dynamic>? ?? {}),
      roles: List<String>.from(json['roles'] ?? []),
      permissions: perms,
      defaultWarehouse: json['default_warehouse']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'company': company.toJson(),
      'pos_profile': posProfile.toJson(),
      'pos_industry': posIndustry.toJson(),
      'roles': roles,
      'permissions': permissions.map(
        (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
      ),
      'default_warehouse': defaultWarehouse,
    };
  }
}

class User {
  final String name;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? mobileNo;

  User({
    required this.name,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.mobileNo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'mobile_no': mobileNo,
    };
  }
}

class Company {
  final String name;
  final String companyName;
  final String abbr;
  final String defaultCurrency;
  final String country;
  final String? taxId;
  final String? phoneNo;
  final String? email;
  final String? website;
  final Address? address;

  Company({
    required this.name,
    required this.companyName,
    required this.abbr,
    required this.defaultCurrency,
    required this.country,
    this.taxId,
    this.phoneNo,
    this.email,
    this.website,
    this.address,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      abbr: json['abbr']?.toString() ?? '',
      defaultCurrency: json['default_currency']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      taxId: json['tax_id']?.toString(),
      phoneNo: json['phone_no']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      address: json['address'] != null && json['address'] is Map
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company_name': companyName,
      'abbr': abbr,
      'default_currency': defaultCurrency,
      'country': country,
      'tax_id': taxId,
      'phone_no': phoneNo,
      'email': email,
      'website': website,
      'address': address?.toJson(),
    };
  }
}

class Address {
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String phone;
  final String emailId;

  Address({
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.phone,
    required this.emailId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'phone': phone,
      'email_id': emailId,
    };
  }
}

class PosProfile {
  final String name;
  final String company;
  final String warehouse;
  final String currency;
  final String customer;

  PosProfile({
    required this.name,
    required this.company,
    required this.warehouse,
    required this.currency,
    required this.customer,
  });

  factory PosProfile.fromJson(Map<String, dynamic> json) {
    return PosProfile(
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      warehouse: json['warehouse']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'warehouse': warehouse,
      'currency': currency,
      'customer': customer,
    };
  }
}

class PosIndustry {
  final String name;
  final String industryCode;
  final String industryName;
  final String description;
  final String servingLocation;

  PosIndustry({
    required this.name,
    required this.industryCode,
    required this.industryName,
    required this.description,
    required this.servingLocation,
  });

  factory PosIndustry.fromJson(Map<String, dynamic> json) {
    return PosIndustry(
      name: json['name']?.toString() ?? '',
      industryCode: json['industry_code']?.toString() ?? '',
      industryName: json['industry_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      servingLocation: json['serving_location']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'industry_code': industryCode,
      'industry_name': industryName,
      'description': description,
      'serving_location': servingLocation,
    };
  }
}

class Permission {
  final String doc;
  final String? applicableFor;
  final int isDefault;
  final String? hideDescendants;

  Permission({
    required this.doc,
    this.applicableFor,
    required this.isDefault,
    this.hideDescendants,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      doc: json['doc']?.toString() ?? '',
      applicableFor: json['applicable_for']?.toString(),
      isDefault: _parseToInt(json['is_default']),
      hideDescendants: json['hide_descendants']?.toString(),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      final doubleParsed = double.tryParse(value);
      if (doubleParsed != null) return doubleParsed.toInt();
    }
    if (value is bool) return value ? 1 : 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'doc': doc,
      'applicable_for': applicableFor,
      'is_default': isDefault,
      'hide_descendants': hideDescendants,
    };
  }
}