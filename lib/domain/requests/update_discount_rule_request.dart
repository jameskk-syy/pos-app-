class UpdateDiscountRuleRequest {
  final String name;
  final String ruleType;
  final String company;
  final String discountType;
  final double discountValue;
  final int priority;
  final int isActive;
  final String? warehouse;
  final String? validFrom;
  final String? validUpto;
  final String? itemCode;
  final String? batchNo;
  final String? itemGroup;
  final String? description;

  UpdateDiscountRuleRequest({
    required this.name,
    required this.ruleType,
    required this.company,
    required this.discountType,
    required this.discountValue,
    required this.priority,
    required this.isActive,
    this.warehouse,
    this.validFrom,
    this.validUpto,
    this.itemCode,
    this.batchNo,
    this.itemGroup,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "rule_type": ruleType,
    "company": company,
    "discount_type": discountType,
    "discount_value": discountValue,
    "priority": priority,
    "is_active": isActive,
    if (warehouse != null && warehouse!.isNotEmpty) "warehouse": warehouse,
    if (validFrom != null && validFrom!.isNotEmpty) "valid_from": validFrom,
    if (validUpto != null && validUpto!.isNotEmpty) "valid_upto": validUpto,
    if (itemCode != null && itemCode!.isNotEmpty) "item_code": itemCode,
    if (batchNo != null && batchNo!.isNotEmpty) "batch_no": batchNo,
    if (itemGroup != null && itemGroup!.isNotEmpty) "item_group": itemGroup,
    if (description != null && description!.isNotEmpty)
      "description": description,
  };
}
