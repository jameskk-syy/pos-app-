class CreateDiscountRuleRequest {
  final String ruleType;
  final String discountType;
  final double discountValue;
  final int priority;
  final String? warehouse;
  final String? validFrom;
  final String? validUpto;
  final String? description;
  final int isActive;
  final String company;
  
  final String? itemCode;
  final String? batchNo;
  final String? itemGroup;

  CreateDiscountRuleRequest({
    required this.ruleType,
    required this.discountType,
    required this.discountValue,
    required this.priority,
    this.warehouse,
    this.validFrom,
    this.validUpto,
    this.description,
    this.isActive = 1,
    required this.company,
    this.itemCode,
    this.batchNo,
    this.itemGroup,
  });

  Map<String, dynamic> toJson() => {
        "rule_type": ruleType,
        "company": company,
        "discount_type": discountType,
        "discount_value": discountValue,
        "priority": priority,
        "is_active": isActive,
        if (warehouse != null && warehouse!.isNotEmpty) "warehouse": warehouse,
        if (validFrom != null && validFrom!.isNotEmpty) "valid_from": validFrom,
        if (validUpto != null && validUpto!.isNotEmpty) "valid_upto": validUpto,
        if (description != null && description!.isNotEmpty) "description": description,
        if (itemCode != null && itemCode!.isNotEmpty) "item_code": itemCode,
        if (batchNo != null && batchNo!.isNotEmpty) "batch_no": batchNo,
        if (itemGroup != null && itemGroup!.isNotEmpty) "item_group": itemGroup,
      };
}