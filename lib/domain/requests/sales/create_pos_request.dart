import 'dart:convert';

class CompanyProfileRequest {
  String company;
  String profileName;
  bool updateStock;
  bool allowDiscountChange;
  bool allowRateChange;
  bool allowPartialPayment;

  CompanyProfileRequest({
    required this.company,
    required this.profileName,
    required this.updateStock,
    required this.allowDiscountChange,
    required this.allowRateChange,
    required this.allowPartialPayment,
  });

  // Factory constructor for creating from JSON
  factory CompanyProfileRequest.fromJson(Map<String, dynamic> json) {
    return CompanyProfileRequest(
      company: json['company'] as String,
      profileName: json['profile_name'] as String,
      updateStock: json['update_stock'] as bool,
      allowDiscountChange: json['allow_discount_change'] as bool,
      allowRateChange: json['allow_rate_change'] as bool,
      allowPartialPayment: json['allow_partial_payment'] as bool,
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'profile_name': profileName,
      'update_stock': updateStock,
      'allow_discount_change': allowDiscountChange,
      'allow_rate_change': allowRateChange,
      'allow_partial_payment': allowPartialPayment,
    };
  }

  // Convert to JSON string
  String toJsonString() {
    return json.encode(toJson());
  }

  // Copy with method for immutability
  CompanyProfileRequest copyWith({
    String? company,
    String? profileName,
    bool? updateStock,
    bool? allowDiscountChange,
    bool? allowRateChange,
    bool? allowPartialPayment,
  }) {
    return CompanyProfileRequest(
      company: company ?? this.company,
      profileName: profileName ?? this.profileName,
      updateStock: updateStock ?? this.updateStock,
      allowDiscountChange: allowDiscountChange ?? this.allowDiscountChange,
      allowRateChange: allowRateChange ?? this.allowRateChange,
      allowPartialPayment: allowPartialPayment ?? this.allowPartialPayment,
    );
  }

  @override
  String toString() {
    return 'CompanyProfileRequest(company: $company, profileName: $profileName, updateStock: $updateStock, allowDiscountChange: $allowDiscountChange, allowRateChange: $allowRateChange, allowPartialPayment: $allowPartialPayment)';
  }
}