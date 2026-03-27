class BillerProfile {
  final String name;
  final String industry;
  final String company;

  BillerProfile({
    required this.name,
    required this.industry,
    required this.company,
  });

  factory BillerProfile.fromJson(Map<String, dynamic> json) {
    return BillerProfile(
      name: json['name'] ?? '',
      industry: json['industry'] ?? '',
      company: json['company'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'industry': industry,
        'company': company,
      };
}

class UserContextData {
  final BillerProfile? activeBiller;
  final List<BillerProfile> allowedBillers;
  final bool hasGlobalAccess;

  UserContextData({
    this.activeBiller,
    required this.allowedBillers,
    required this.hasGlobalAccess,
  });

  factory UserContextData.fromJson(Map<String, dynamic> json) {
    return UserContextData(
      activeBiller: json['active_biller'] != null
          ? BillerProfile.fromJson(json['active_biller'])
          : null,
      allowedBillers: (json['allowed_billers'] as List<dynamic>?)
              ?.map((e) => BillerProfile.fromJson(e))
              .toList() ??
          [],
      hasGlobalAccess: json['has_global_access'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (activeBiller != null) 'active_biller': activeBiller!.toJson(),
      'allowed_billers': allowedBillers.map((b) => b.toJson()).toList(),
      'has_global_access': hasGlobalAccess,
    };
  }
}

class BillerWarehouse {
  final String name;
  final String? location;

  BillerWarehouse({required this.name, this.location});

  factory BillerWarehouse.fromJson(Map<String, dynamic> json) {
    return BillerWarehouse(
      name: json['name'] ?? '',
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (location != null) 'location': location,
      };
}

class BillerPosProfile {
  final String name;

  BillerPosProfile({required this.name});

  factory BillerPosProfile.fromJson(Map<String, dynamic> json) {
    return BillerPosProfile(name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() => {'name': name};
}

class BillerDetailsData {
  final String billerName;
  final String industry;
  final String company;
  final String? defaultCostCenter;
  final String? defaultPriceList;
  final String? defaultTaxTemplate;
  final bool isDefault;
  final List<BillerWarehouse> warehouses;
  final List<BillerPosProfile> posProfiles;

  BillerDetailsData({
    required this.billerName,
    required this.industry,
    required this.company,
    this.defaultCostCenter,
    this.defaultPriceList,
    this.defaultTaxTemplate,
    required this.isDefault,
    required this.warehouses,
    required this.posProfiles,
  });

  factory BillerDetailsData.fromJson(Map<String, dynamic> json) {
    return BillerDetailsData(
      billerName: json['biller_name'] ?? '',
      industry: json['industry'] ?? '',
      company: json['company'] ?? '',
      defaultCostCenter: json['default_cost_center'],
      defaultPriceList: json['default_price_list'],
      defaultTaxTemplate: json['default_tax_template'],
      isDefault: json['is_default'] ?? false,
      warehouses: (json['warehouses'] as List<dynamic>?)
              ?.map((e) => BillerWarehouse.fromJson(e))
              .toList() ??
          [],
      posProfiles: (json['pos_profiles'] as List<dynamic>?)
              ?.map((e) => BillerPosProfile.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'biller_name': billerName,
        'industry': industry,
        'company': company,
        if (defaultCostCenter != null) 'default_cost_center': defaultCostCenter,
        if (defaultPriceList != null) 'default_price_list': defaultPriceList,
        if (defaultTaxTemplate != null)
          'default_tax_template': defaultTaxTemplate,
        'is_default': isDefault,
        'warehouses': warehouses.map((w) => w.toJson()).toList(),
        'pos_profiles': posProfiles.map((p) => p.toJson()).toList(),
      };
}
