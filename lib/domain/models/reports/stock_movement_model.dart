class InventoryTurnoverResponse {
  final bool success;
  final List<InventoryTurnoverData> data;

  InventoryTurnoverResponse({required this.success, required this.data});

  factory InventoryTurnoverResponse.fromJson(Map<String, dynamic> json) {
    return InventoryTurnoverResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => InventoryTurnoverData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class InventoryTurnoverData {
  final String itemCode;
  final String itemName;
  final double averageStock;
  final double costOfSales;
  final double turnoverRate;
  final double turnoverDays;

  InventoryTurnoverData({
    required this.itemCode,
    required this.itemName,
    required this.averageStock,
    required this.costOfSales,
    required this.turnoverRate,
    required this.turnoverDays,
  });

  factory InventoryTurnoverData.fromJson(Map<String, dynamic> json) {
    return InventoryTurnoverData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      averageStock: (json['average_stock'] as num?)?.toDouble() ?? 0.0,
      costOfSales: (json['cost_of_sales'] as num?)?.toDouble() ?? 0.0,
      turnoverRate: (json['turnover_rate'] as num?)?.toDouble() ?? 0.0,
      turnoverDays: (json['turnover_days'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InventoryDaysOnHandResponse {
  final bool success;
  final List<DaysOnHandData> data;

  InventoryDaysOnHandResponse({required this.success, required this.data});

  factory InventoryDaysOnHandResponse.fromJson(Map<String, dynamic> json) {
    return InventoryDaysOnHandResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => DaysOnHandData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DaysOnHandData {
  final String itemCode;
  final String itemName;
  final String warehouse;
  final double currentStock;
  final double avgDailySales;
  final double daysOnHand;
  final String status;

  DaysOnHandData({
    required this.itemCode,
    required this.itemName,
    required this.warehouse,
    required this.currentStock,
    required this.avgDailySales,
    required this.daysOnHand,
    required this.status,
  });

  factory DaysOnHandData.fromJson(Map<String, dynamic> json) {
    return DaysOnHandData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      warehouse: json['warehouse'] ?? '',
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0.0,
      avgDailySales: (json['avg_daily_sales'] as num?)?.toDouble() ?? 0.0,
      daysOnHand: (json['days_on_hand'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'normal',
    );
  }
}
