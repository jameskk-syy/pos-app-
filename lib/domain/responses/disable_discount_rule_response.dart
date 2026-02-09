import 'package:pos/domain/responses/create_discount_rule_response.dart';

class DisableDiscountRuleResponse {
  final DisableDiscountRuleMessage message;

  DisableDiscountRuleResponse({required this.message});

  factory DisableDiscountRuleResponse.fromJson(Map<String, dynamic> json) =>
      DisableDiscountRuleResponse(
        message: DisableDiscountRuleMessage.fromJson(json["message"]),
      );
}

class DisableDiscountRuleMessage {
  final bool success;
  final String message;
  final DiscountRuleData data;

  DisableDiscountRuleMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DisableDiscountRuleMessage.fromJson(Map<String, dynamic> json) =>
      DisableDiscountRuleMessage(
        success: json["success"],
        message: json["message"],
        data: DiscountRuleData.fromJson(json["data"]),
      );
}
