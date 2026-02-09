import 'package:pos/domain/responses/create_discount_rule_response.dart';

class EnableDiscountRuleResponse {
  final EnableDiscountRuleMessage message;

  EnableDiscountRuleResponse({required this.message});

  factory EnableDiscountRuleResponse.fromJson(Map<String, dynamic> json) =>
      EnableDiscountRuleResponse(
        message: EnableDiscountRuleMessage.fromJson(json["message"]),
      );
}

class EnableDiscountRuleMessage {
  final bool success;
  final String message;
  final DiscountRuleData data;

  EnableDiscountRuleMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EnableDiscountRuleMessage.fromJson(Map<String, dynamic> json) =>
      EnableDiscountRuleMessage(
        success: json["success"],
        message: json["message"],
        data: DiscountRuleData.fromJson(json["data"]),
      );
}
