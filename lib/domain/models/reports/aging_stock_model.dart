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
  final List<AgingItemData> data;

  AgingStockDetailsResponse({required this.success, required this.data});

  factory AgingStockDetailsResponse.fromJson(Map<String, dynamic> json) {
    return AgingStockDetailsResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => AgingItemData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AgingItemData {
  final String itemCode;
  final String itemName;
  final String receivedDate;
  final int ageDays;
  final double quantity;
  final double value;
  final String ageRange;

  AgingItemData({
    required this.itemCode,
    required this.itemName,
    required this.receivedDate,
    required this.ageDays,
    required this.quantity,
    required this.value,
    required this.ageRange,
  });

  factory AgingItemData.fromJson(Map<String, dynamic> json) {
    return AgingItemData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      receivedDate: json['received_date'] ?? '',
      ageDays: (json['age_days'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      ageRange: json['age_range'] ?? '',
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
