class CreateDiscountRuleResponse {
  final CreateDiscountRuleMessage message;

  CreateDiscountRuleResponse({
    required this.message,
  });

  factory CreateDiscountRuleResponse.fromJson(Map<String, dynamic> json) =>
      CreateDiscountRuleResponse(
        message: CreateDiscountRuleMessage.fromJson(json["message"]),
      );
}

class CreateDiscountRuleMessage {
  final bool success;
  final String message;
  final DiscountRuleData data;

  CreateDiscountRuleMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateDiscountRuleMessage.fromJson(Map<String, dynamic> json) =>
      CreateDiscountRuleMessage(
        success: json["success"],
        message: json["message"],
        data: DiscountRuleData.fromJson(json["data"]),
      );
}

class DiscountRuleData {
  final String name;
  final String ruleType;
  final String? itemCode;
  final String? batchNo;
  final String? itemGroup;
  final String? warehouse;
  final String company;
  final String discountType;
  final double discountValue;
  final int priority;
  final int isActive;
  final String? validFrom;
  final String? validUpto;
  final String? description;

  DiscountRuleData({
    required this.name,
    required this.ruleType,
    required this.itemCode,
    required this.batchNo,
    required this.itemGroup,
    required this.warehouse,
    required this.company,
    required this.discountType,
    required this.discountValue,
    required this.priority,
    required this.isActive,
    required this.validFrom,
    required this.validUpto,
    required this.description,
  });

  factory DiscountRuleData.fromJson(Map<String, dynamic> json) =>
      DiscountRuleData(
        name: json["name"],
        ruleType: json["rule_type"],
        itemCode: json["item_code"],
        batchNo: json["batch_no"],
        itemGroup: json["item_group"],
        warehouse: json["warehouse"],
        company: json["company"],
        discountType: json["discount_type"],
        discountValue: (json["discount_value"] as num).toDouble(),
        priority: json["priority"],
        isActive: json["is_active"],
        validFrom: json["valid_from"],
        validUpto: json["valid_upto"],
        description: json["description"],
      );
}