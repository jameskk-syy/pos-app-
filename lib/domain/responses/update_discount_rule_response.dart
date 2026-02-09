import 'package:pos/domain/responses/create_discount_rule_response.dart';

class UpdateDiscountRuleResponse {
  final UpdateDiscountRuleMessage message;

  UpdateDiscountRuleResponse({required this.message});

  factory UpdateDiscountRuleResponse.fromJson(Map<String, dynamic> json) =>
      UpdateDiscountRuleResponse(
        message: UpdateDiscountRuleMessage.fromJson(json["message"]),
      );
}

class UpdateDiscountRuleMessage {
  final bool success;
  final String message;
  final DiscountRuleData data;

  UpdateDiscountRuleMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UpdateDiscountRuleMessage.fromJson(Map<String, dynamic> json) =>
      UpdateDiscountRuleMessage(
        success: json["success"],
        message: json["message"],
        data: DiscountRuleData.fromJson(json["data"]),
      );
}
