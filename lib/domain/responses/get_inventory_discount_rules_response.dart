class GetInventoryDiscountRulesResponse {
  final InventoryDiscountRulesMessage message;

  GetInventoryDiscountRulesResponse({
    required this.message,
  });

  factory GetInventoryDiscountRulesResponse.fromJson(Map<String, dynamic> json) =>
      GetInventoryDiscountRulesResponse(
        message: InventoryDiscountRulesMessage.fromJson(json["message"]),
      );
}

class InventoryDiscountRulesMessage {
  final bool success;
  final InventoryDiscountRulesData data;

  InventoryDiscountRulesMessage({
    required this.success,
    required this.data,
  });

  factory InventoryDiscountRulesMessage.fromJson(Map<String, dynamic> json) =>
      InventoryDiscountRulesMessage(
        success: json["success"],
        data: InventoryDiscountRulesData.fromJson(json["data"]),
      );
}

class InventoryDiscountRulesData {
  final List<InventoryDiscountRule> rules;
  final PaginationData pagination;

  InventoryDiscountRulesData({
    required this.rules,
    required this.pagination,
  });

  factory InventoryDiscountRulesData.fromJson(Map<String, dynamic> json) =>
      InventoryDiscountRulesData(
        rules: (json["rules"] as List)
            .map((item) => InventoryDiscountRule.fromJson(item))
            .toList(),
        pagination: PaginationData.fromJson(json["pagination"]),
      );
}

class InventoryDiscountRule {
  final String name;
  final String ruleType;
  final String itemCode;
  final String? batchNo;
  final String? itemGroup;
  final String warehouse;
  final String company;
  final String discountType;
  final double discountValue;
  final int priority;
  final int isActive;
  final String? validFrom;
  final String? validUpto;
  final String? description;

  InventoryDiscountRule({
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

  factory InventoryDiscountRule.fromJson(Map<String, dynamic> json) =>
      InventoryDiscountRule(
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

class PaginationData {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  PaginationData({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) => PaginationData(
        page: json["page"],
        pageSize: json["page_size"],
        total: json["total"],
        totalPages: json["total_pages"],
      );
}