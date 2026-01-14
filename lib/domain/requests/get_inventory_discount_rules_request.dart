class GetInventoryDiscountRulesRequest {
  final String ruleType;
  final String company;
  final String? itemCode;
  final String? batchNo;
  final String? itemGroup;
  final String? warehouse;
  final int isActive;
  final String? searchTerm;
  final int page;
  final int pageSize;

  GetInventoryDiscountRulesRequest({
    required this.ruleType,
    required this.company,
    this.itemCode,
    this.batchNo,
    this.itemGroup,
    this.warehouse,
    this.isActive = 1,
    this.searchTerm,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() => {
        "rule_type": ruleType,
        "company": company,
        if (itemCode != null && itemCode!.isNotEmpty) "item_code": itemCode,
        if (batchNo != null && batchNo!.isNotEmpty) "batch_no": batchNo,
        if (itemGroup != null && itemGroup!.isNotEmpty) "item_group": itemGroup,
        if (warehouse != null && warehouse!.isNotEmpty) "warehouse": warehouse,
        "is_active": isActive,
        if (searchTerm != null && searchTerm!.isNotEmpty)
          "search_term": searchTerm,
        "page": page,
        "page_size": pageSize,
      };
}