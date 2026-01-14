class InventoryAccuracyResponse {
  final bool success;
  final InventoryAccuracyData data;

  InventoryAccuracyResponse({required this.success, required this.data});

  factory InventoryAccuracyResponse.fromJson(Map<String, dynamic> json) {
    return InventoryAccuracyResponse(
      success: json['success'] ?? false,
      data: InventoryAccuracyData.fromJson(json['data'] ?? {}),
    );
  }
}

class InventoryAccuracyData {
  final String warehouse;
  final int totalItemsCounted;
  final int itemsWithVariance;
  final double accuracyRate;
  final int varianceCount;
  final double totalVarianceValue;

  InventoryAccuracyData({
    required this.warehouse,
    required this.totalItemsCounted,
    required this.itemsWithVariance,
    required this.accuracyRate,
    required this.varianceCount,
    required this.totalVarianceValue,
  });

  factory InventoryAccuracyData.fromJson(Map<String, dynamic> json) {
    return InventoryAccuracyData(
      warehouse: json['warehouse'] ?? '',
      totalItemsCounted: (json['total_items_counted'] as num?)?.toInt() ?? 0,
      itemsWithVariance: (json['items_with_variance'] as num?)?.toInt() ?? 0,
      accuracyRate: (json['accuracy_rate'] as num?)?.toDouble() ?? 0.0,
      varianceCount: (json['variance_count'] as num?)?.toInt() ?? 0,
      totalVarianceValue:
          (json['total_variance_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InventoryVarianceResponse {
  final bool success;
  final List<InventoryVarianceData> data;

  InventoryVarianceResponse({required this.success, required this.data});

  factory InventoryVarianceResponse.fromJson(Map<String, dynamic> json) {
    return InventoryVarianceResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => InventoryVarianceData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class InventoryVarianceData {
  final String itemCode;
  final String itemName;
  final double bookQty;
  final double countedQty;
  final double varianceQty;
  final double varianceValue;
  final double variancePercentage;
  final String reconciliationDate;

  InventoryVarianceData({
    required this.itemCode,
    required this.itemName,
    required this.bookQty,
    required this.countedQty,
    required this.varianceQty,
    required this.varianceValue,
    required this.variancePercentage,
    required this.reconciliationDate,
  });

  factory InventoryVarianceData.fromJson(Map<String, dynamic> json) {
    return InventoryVarianceData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      bookQty: (json['book_qty'] as num?)?.toDouble() ?? 0.0,
      countedQty: (json['counted_qty'] as num?)?.toDouble() ?? 0.0,
      varianceQty: (json['variance_qty'] as num?)?.toDouble() ?? 0.0,
      varianceValue: (json['variance_value'] as num?)?.toDouble() ?? 0.0,
      variancePercentage:
          (json['variance_percentage'] as num?)?.toDouble() ?? 0.0,
      reconciliationDate: json['reconciliation_date'] ?? '',
    );
  }
}

class InventoryAdjustmentTrendsResponse {
  final bool success;
  final List<AdjustmentTrendData> data;

  InventoryAdjustmentTrendsResponse({
    required this.success,
    required this.data,
  });

  factory InventoryAdjustmentTrendsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventoryAdjustmentTrendsResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => AdjustmentTrendData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AdjustmentTrendData {
  final String period;
  final int adjustmentCount;
  final double totalAdjustedQty;
  final double totalAdjustedValue;
  final int increaseCount;
  final int decreaseCount;

  AdjustmentTrendData({
    required this.period,
    required this.adjustmentCount,
    required this.totalAdjustedQty,
    required this.totalAdjustedValue,
    required this.increaseCount,
    required this.decreaseCount,
  });

  factory AdjustmentTrendData.fromJson(Map<String, dynamic> json) {
    return AdjustmentTrendData(
      period: json['period'] ?? '',
      adjustmentCount: (json['adjustment_count'] as num?)?.toInt() ?? 0,
      totalAdjustedQty: (json['total_adjusted_qty'] as num?)?.toDouble() ?? 0.0,
      totalAdjustedValue:
          (json['total_adjusted_value'] as num?)?.toDouble() ?? 0.0,
      increaseCount: (json['increase_count'] as num?)?.toInt() ?? 0,
      decreaseCount: (json['decrease_count'] as num?)?.toInt() ?? 0,
    );
  }
}
