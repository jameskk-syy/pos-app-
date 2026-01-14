class InventoryValueByCategoryResponse {
  final bool success;
  final List<InventoryCategoryValue> data;

  InventoryValueByCategoryResponse({required this.success, required this.data});

  factory InventoryValueByCategoryResponse.fromJson(Map<String, dynamic> json) {
    return InventoryValueByCategoryResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => InventoryCategoryValue.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class InventoryCategoryValue {
  final String itemGroup;
  final double totalValue;
  final double totalQty;
  final int itemCount;
  final double percentage;

  InventoryCategoryValue({
    required this.itemGroup,
    required this.totalValue,
    required this.totalQty,
    required this.itemCount,
    required this.percentage,
  });

  factory InventoryCategoryValue.fromJson(Map<String, dynamic> json) {
    return InventoryCategoryValue(
      itemGroup: json['item_group'] ?? 'Unknown',
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      totalQty: (json['total_qty'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
