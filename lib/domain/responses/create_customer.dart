import 'dart:convert';

class CreateCustomerResponse {
  final CreateCustomerMessage message;

  CreateCustomerResponse({
    required this.message,
  });

  factory CreateCustomerResponse.fromJson(Map<String, dynamic> json) {
    return CreateCustomerResponse(
      message: CreateCustomerMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }

  static CreateCustomerResponse fromJsonString(String jsonString) {
    final jsonData = json.decode(jsonString);
    return CreateCustomerResponse.fromJson(jsonData);
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}

class CreateCustomerMessage {
  final bool success;
  final String message;
  final CustomerData data;

  CreateCustomerMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateCustomerMessage.fromJson(Map<String, dynamic> json) {
    return CreateCustomerMessage(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CustomerData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class CustomerData {
  final String name;
  final String customerName;
  final String customerType;
  final String customerGroup;
  final String territory;
  final String taxId;
  final String mobileNo;
  final String emailId;
  final bool disabled;

  CustomerData({
    required this.name,
    required this.customerName,
    required this.customerType,
    required this.customerGroup,
    required this.territory,
    required this.taxId,
    required this.mobileNo,
    required this.emailId,
    required this.disabled,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      name: json['name'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerType: json['customer_type'] ?? '',
      customerGroup: json['customer_group'] ?? '',
      territory: json['territory'] ?? '',
      taxId: json['tax_id'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      emailId: json['email_id'] ?? '',
      disabled: json['disabled'] ?? false,
    );
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
    };
  }

  @override
  String toString() {
    return 'CustomerData: $customerName ($emailId)';
  }
}