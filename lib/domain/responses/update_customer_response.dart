import 'dart:convert';

UpdateCustomerResponse updateCustomerResponseFromJson(String str) =>
    UpdateCustomerResponse.fromJson(json.decode(str));

String updateCustomerResponseToJson(UpdateCustomerResponse data) =>
    json.encode(data.toJson());

class UpdateCustomerResponse {
  final UpdateCustomerMessage message;

  UpdateCustomerResponse({required this.message});

  factory UpdateCustomerResponse.fromJson(Map<String, dynamic> json) =>
      UpdateCustomerResponse(
        message: UpdateCustomerMessage.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class UpdateCustomerMessage {
  final bool success;
  final String message;
  final UpdateCustomerData? data;

  UpdateCustomerMessage({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateCustomerMessage.fromJson(Map<String, dynamic> json) =>
      UpdateCustomerMessage(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? UpdateCustomerData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class UpdateCustomerData {
  final String name;
  final String customerName;

  UpdateCustomerData({required this.name, required this.customerName});

  factory UpdateCustomerData.fromJson(Map<String, dynamic> json) =>
      UpdateCustomerData(
        name: json["name"],
        customerName: json["customer_name"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "customer_name": customerName,
  };
}
