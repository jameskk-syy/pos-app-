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
    // Check if the response is wrapped in a "message" object
    final Map<String, dynamic> dataMap =
        (json['message'] is Map<String, dynamic>) ? json['message'] : json;

    return InventoryDaysOnHandResponse(
      success: dataMap['success'] ?? false,
      data:
          (dataMap['data'] as List?)
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

class InventoryMovementPatternsResponse {
  final bool success;
  final MovementPatternsData data;

  InventoryMovementPatternsResponse({
    required this.success,
    required this.data,
  });

  factory InventoryMovementPatternsResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final Map<String, dynamic> dataMap =
        (json['message'] is Map<String, dynamic>) ? json['message'] : json;

    return InventoryMovementPatternsResponse(
      success: dataMap['success'] ?? false,
      data: MovementPatternsData.fromJson(dataMap['data'] ?? {}),
    );
  }
}

class MovementPatternsData {
  final List<MovementTrend> trends;
  final List<MovementTimeSeries> timeSeries;

  MovementPatternsData({required this.trends, required this.timeSeries});

  factory MovementPatternsData.fromJson(Map<String, dynamic> json) {
    return MovementPatternsData(
      trends:
          (json['trends'] as List?)
              ?.map((e) => MovementTrend.fromJson(e))
              .toList() ??
          [],
      timeSeries:
          (json['time_series'] as List?)
              ?.map((e) => MovementTimeSeries.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MovementTrend {
  final String itemCode;
  final String itemName;
  final String trend;
  final double changePercentage;
  final String status;

  MovementTrend({
    required this.itemCode,
    required this.itemName,
    required this.trend,
    required this.changePercentage,
    required this.status,
  });

  factory MovementTrend.fromJson(Map<String, dynamic> json) {
    return MovementTrend(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      trend: json['trend'] ?? 'stable',
      changePercentage: (json['change_percentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? (json['trend'] ?? 'stable'),
    );
  }
}

class MovementTimeSeries {
  final String date;
  final double received;
  final double issued;
  final double netMovement;

  MovementTimeSeries({
    required this.date,
    required this.received,
    required this.issued,
    required this.netMovement,
  });

  factory MovementTimeSeries.fromJson(Map<String, dynamic> json) {
    return MovementTimeSeries(
      date: json['date'] ?? '',
      received: (json['received'] as num?)?.toDouble() ?? 0.0,
      issued: (json['issued'] as num?)?.toDouble() ?? 0.0,
      netMovement: (json['net_movement'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InventoryTransferEfficiencyResponse {
  final bool success;
  final TransferEfficiencyData data;

  InventoryTransferEfficiencyResponse({
    required this.success,
    required this.data,
  });

  factory InventoryTransferEfficiencyResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventoryTransferEfficiencyResponse(
      success: json['success'] ?? false,
      data: TransferEfficiencyData.fromJson(json['data'] ?? {}),
    );
  }
}

class TransferEfficiencyData {
  final int totalTransfers;
  final int completedTransfers;
  final int pendingTransfers;
  final int cancelledTransfers;
  final double averageCompletionTimeHours;
  final double transferAccuracy;
  final double onTimeRate;

  TransferEfficiencyData({
    required this.totalTransfers,
    required this.completedTransfers,
    required this.pendingTransfers,
    required this.cancelledTransfers,
    required this.averageCompletionTimeHours,
    required this.transferAccuracy,
    required this.onTimeRate,
  });

  factory TransferEfficiencyData.fromJson(Map<String, dynamic> json) {
    return TransferEfficiencyData(
      totalTransfers: (json['total_transfers'] as num?)?.toInt() ?? 0,
      completedTransfers: (json['completed_transfers'] as num?)?.toInt() ?? 0,
      pendingTransfers: (json['pending_transfers'] as num?)?.toInt() ?? 0,
      cancelledTransfers: (json['cancelled_transfers'] as num?)?.toInt() ?? 0,
      averageCompletionTimeHours:
          (json['average_completion_time_hours'] as num?)?.toDouble() ?? 0.0,
      transferAccuracy: (json['transfer_accuracy'] as num?)?.toDouble() ?? 0.0,
      onTimeRate: (json['on_time_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
