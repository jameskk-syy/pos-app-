class AgingStockSummaryResponse {
  final bool success;
  final List<AgingSummaryData> data;

  AgingStockSummaryResponse({required this.success, required this.data});

  factory AgingStockSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AgingStockSummaryResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => AgingSummaryData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AgingSummaryData {
  final String ageRange;
  final double totalValue;
  final int itemCount;
  final double percentage;

  AgingSummaryData({
    required this.ageRange,
    required this.totalValue,
    required this.itemCount,
    required this.percentage,
  });

  factory AgingSummaryData.fromJson(Map<String, dynamic> json) {
    return AgingSummaryData(
      ageRange: json['age_range'] ?? '',
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AgingStockDetailsResponse {
  final bool success;
  final Map<String, List<AgingItemData>> data;

  AgingStockDetailsResponse({required this.success, required this.data});

  factory AgingStockDetailsResponse.fromJson(Map<String, dynamic> json) {
    // Check if the response is wrapped in a 'message' object
    Map<String, dynamic> source = json;
    if (json.containsKey('message') &&
        json['message'] is Map<String, dynamic>) {
      source = json['message'];
    }

    final Map<String, dynamic> rawData = source['data'] ?? {};
    final Map<String, List<AgingItemData>> formattedData = {};

    rawData.forEach((key, value) {
      if (value is List) {
        formattedData[key] = value
            .map((item) => AgingItemData.fromJson(item))
            .toList();
      }
    });

    return AgingStockDetailsResponse(
      success:
          source['success'] ?? true, // Default to true if parsed from message
      data: formattedData,
    );
  }
}

class AgingItemData {
  final String itemCode;
  final String? itemName;
  final String? warehouse;
  final double actualQty;
  final int ageDays;
  final double movementRate;
  final bool isSlowMoving;

  AgingItemData({
    required this.itemCode,
    this.itemName,
    this.warehouse,
    required this.actualQty,
    required this.ageDays,
    required this.movementRate,
    required this.isSlowMoving,
  });

  factory AgingItemData.fromJson(Map<String, dynamic> json) {
    return AgingItemData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'],
      warehouse: json['warehouse'],
      actualQty: (json['actual_qty'] as num?)?.toDouble() ?? 0.0,
      ageDays: (json['age_days'] as num?)?.toInt() ?? 0,
      movementRate: (json['movement_rate'] as num?)?.toDouble() ?? 0.0,
      isSlowMoving: json['is_slow_moving'] ?? false,
    );
  }
}

class InventoryExpiryResponse {
  final bool success;
  final List<ExpiryItemData> data;

  InventoryExpiryResponse({required this.success, required this.data});

  factory InventoryExpiryResponse.fromJson(Map<String, dynamic> json) {
    return InventoryExpiryResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => ExpiryItemData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ExpiryItemData {
  final String itemCode;
  final String itemName;
  final String batchNo;
  final String expiryDate;
  final int daysToExpiry;
  final double quantity;
  final String status;

  ExpiryItemData({
    required this.itemCode,
    required this.itemName,
    required this.batchNo,
    required this.expiryDate,
    required this.daysToExpiry,
    required this.quantity,
    required this.status,
  });

  factory ExpiryItemData.fromJson(Map<String, dynamic> json) {
    return ExpiryItemData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      batchNo: json['batch_no'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      daysToExpiry: (json['days_to_expiry'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'ok',
    );
  }
}

class InventoryObsolescenceRiskResponse {
  final bool success;
  final List<ObsolescenceRiskData> data;

  InventoryObsolescenceRiskResponse({
    required this.success,
    required this.data,
  });

  factory InventoryObsolescenceRiskResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventoryObsolescenceRiskResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => ObsolescenceRiskData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ObsolescenceRiskData {
  final String itemCode;
  final String itemName;
  final String warehouse;
  final int ageDays;
  final String lastMovementDate;
  final double currentStock;
  final double stockValue;
  final double riskScore;
  final String riskLevel;
  final List<String> riskFactors;

  ObsolescenceRiskData({
    required this.itemCode,
    required this.itemName,
    required this.warehouse,
    required this.ageDays,
    required this.lastMovementDate,
    required this.currentStock,
    required this.stockValue,
    required this.riskScore,
    required this.riskLevel,
    required this.riskFactors,
  });

  factory ObsolescenceRiskData.fromJson(Map<String, dynamic> json) {
    return ObsolescenceRiskData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      warehouse: json['warehouse'] ?? '',
      ageDays: (json['age_days'] as num?)?.toInt() ?? 0,
      lastMovementDate: json['last_movement_date'] ?? '',
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0.0,
      stockValue: (json['stock_value'] as num?)?.toDouble() ?? 0.0,
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] ?? 'low',
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
    );
  }
}

class InventoryAgingRecommendationResponse {
  final bool success;
  final List<AgingRecommendationData> data;

  InventoryAgingRecommendationResponse({
    required this.success,
    required this.data,
  });

  factory InventoryAgingRecommendationResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    // Check if the response is wrapped in a 'message' object
    Map<String, dynamic> source = json;
    if (json.containsKey('message') &&
        json['message'] is Map<String, dynamic>) {
      source = json['message'];
    }

    return InventoryAgingRecommendationResponse(
      success: source['success'] ?? true,
      data:
          (source['data'] as List?)
              ?.map((e) => AgingRecommendationData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AgingRecommendationData {
  final String itemCode;
  final String itemName;
  final String warehouse;
  final String ageBracket;
  final int ageDays;
  final double currentStock;
  final String recommendedAction;
  final String priority;
  final String reason;

  AgingRecommendationData({
    required this.itemCode,
    required this.itemName,
    required this.warehouse,
    required this.ageBracket,
    required this.ageDays,
    required this.currentStock,
    required this.recommendedAction,
    required this.priority,
    required this.reason,
  });

  factory AgingRecommendationData.fromJson(Map<String, dynamic> json) {
    return AgingRecommendationData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      warehouse: json['warehouse'] ?? '',
      ageBracket: json['age_bracket'] ?? '',
      ageDays: (json['age_days'] as num?)?.toInt() ?? 0,
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0.0,
      recommendedAction: json['recommended_action'] ?? '',
      priority: json['priority'] ?? 'low',
      reason: json['reason'] ?? '',
    );
  }
}
