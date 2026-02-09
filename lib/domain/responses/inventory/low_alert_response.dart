class StockResponses {
  final bool success;
  final List<StockItem>? data;
  final int? count;
  final double? threshold;

  StockResponses({
    required this.success,
    this.data,
    this.count,
    this.threshold,
  });

  factory StockResponses.fromJson(Map<String, dynamic> json) {
    return StockResponses(
      success: json['success'] ?? false,
      data: (json['data'] ?? json['items']) != null
          ? ((json['data'] ?? json['items']) as List)
                .map((item) => StockItem.fromJson(item))
                .toList()
          : [],
      count: json['count'],
      threshold: json['threshold']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.map((item) => item.toJson()).toList(),
    'count': count,
    'threshold': threshold,
  };
}

class StockItem {
  final String? itemCode;
  final String? warehouse;
  final double? actualQty;
  final double? reservedQty;
  final double? projectedQty;
  final String? itemName;
  final String? itemGroup;
  final String? stockUom;

  StockItem({
    this.itemCode,
    this.warehouse,
    this.actualQty,
    this.reservedQty,
    this.projectedQty,
    this.itemName,
    this.itemGroup,
    this.stockUom,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      itemCode: json['item_code']?.toString(),
      warehouse: json['warehouse']?.toString(),
      actualQty: _parseDouble(json['actual_qty']),
      reservedQty: _parseDouble(json['reserved_qty']),
      projectedQty: _parseDouble(json['projected_qty']),
      itemName: json['item_name']?.toString(),
      itemGroup: json['item_group']?.toString(),
      stockUom: json['stock_uom']?.toString(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'item_code': itemCode,
    'warehouse': warehouse,
    'actual_qty': actualQty,
    'reserved_qty': reservedQty,
    'projected_qty': projectedQty,
    'item_name': itemName,
    'item_group': itemGroup,
    'stock_uom': stockUom,
  };

  // Helper methods with null safety
  bool isBelowThreshold(double threshold) {
    return (actualQty ?? 0) < threshold;
  }

  double get availableQty {
    return (actualQty ?? 0) - (reservedQty ?? 0);
  }

  bool get hasLowStock {
    return (actualQty ?? 0) <= 0;
  }
}
