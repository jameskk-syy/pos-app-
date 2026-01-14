// Main Response Model
class CustomerResponse {
  final CrmMessage message;

  CustomerResponse({required this.message});

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      message: CrmMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

// Message Model
class CrmMessage {
  final bool success;
  final List<Customer> data;
  final int count;

  CrmMessage({
    required this.success,
    required this.data,
    required this.count,
  });

  factory CrmMessage.fromJson(Map<String, dynamic> json) {
    return CrmMessage(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Customer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

// Customer Model
class Customer {
  final String name;
  final String customerName;
  final String customerType;
  final String? customerGroup;
  final String? territory;
  final String? taxId;
  final String? mobileNo;
  final String? emailId;
  final int disabled;
  final String? defaultCurrency;
  final String? defaultPriceList;
  final double creditLimit;
  final double outstandingAmount;
  final double availableCredit;
  final double creditUtilizationPercent; // Changed to double
  final bool isOverLimit;

  Customer({
    required this.name,
    required this.customerName,
    required this.customerType,
    this.customerGroup,
    this.territory,
    this.taxId,
    this.mobileNo,
    this.emailId,
    required this.disabled,
    this.defaultCurrency,
    this.defaultPriceList,
    required this.creditLimit,
    required this.outstandingAmount,
    required this.availableCredit,
    required this.creditUtilizationPercent,
    required this.isOverLimit,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerType: json['customer_type'] ?? '',
      customerGroup: json['customer_group'],
      territory: json['territory'],
      taxId: json['tax_id'],
      mobileNo: json['mobile_no'],
      emailId: json['email_id'],
      disabled: json['disabled'] ?? 0,
      defaultCurrency: json['default_currency'],
      defaultPriceList: json['default_price_list'],
      creditLimit: _toDouble(json['credit_limit']),
      outstandingAmount: _toDouble(json['outstanding_amount']),
      availableCredit: _toDouble(json['available_credit']),
      creditUtilizationPercent: _toDouble(json['credit_utilization_percent']),
      isOverLimit: json['is_over_limit'] ?? false,
    );
  }

  // Helper method to safely convert any value to double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'customer_name': customerName,
      'customer_type': customerType,
      'customer_group': customerGroup,
      'territory': territory,
      'tax_id': taxId,
      'mobile_no': mobileNo,
      'email_id': emailId,
      'disabled': disabled,
      'default_currency': defaultCurrency,
      'default_price_list': defaultPriceList,
      'credit_limit': creditLimit,
      'outstanding_amount': outstandingAmount,
      'available_credit': availableCredit,
      'credit_utilization_percent': creditUtilizationPercent,
      'is_over_limit': isOverLimit,
    };
  }

  bool get isActive => disabled == 0;
  String get displayName => customerName.isNotEmpty ? customerName : name;

  String get formattedCreditUtilization => 
      '${creditUtilizationPercent.toStringAsFixed(1)}%';
}