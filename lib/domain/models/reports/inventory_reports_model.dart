class InventoryValueByCategoryResponse {
  final bool success;
  final List<InventoryCategoryValue> data;

  InventoryValueByCategoryResponse({required this.success, required this.data});

  factory InventoryValueByCategoryResponse.fromJson(Map<String, dynamic> json) {
    // Check if the response is wrapped in a "message" object
    final Map<String, dynamic> dataMap =
        (json['message'] is Map<String, dynamic>) ? json['message'] : json;

    return InventoryValueByCategoryResponse(
      success: dataMap['success'] ?? false,
      data:
          (dataMap['data'] as List?)
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

class InventoryCostMethodResponse {
  final bool success;
  final Map<String, CostMethodData> data;
  final String? message;

  InventoryCostMethodResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory InventoryCostMethodResponse.fromJson(Map<String, dynamic> json) {
    // Check if the response is wrapped in a "message" object
    final Map<String, dynamic> rootMap =
        (json['message'] is Map<String, dynamic> &&
            json['message'].containsKey('data'))
        ? json['message']
        : json;

    final Map<String, dynamic> dataMap = rootMap['data'] ?? {};

    String? msg;
    if (rootMap['message'] is String) {
      msg = rootMap['message'];
    } else if (rootMap['message'] is Map) {
      msg =
          rootMap['message']['message']?.toString() ??
          rootMap['message'].toString();
    } else {
      msg = rootMap['message']?.toString();
    }

    return InventoryCostMethodResponse(
      success: rootMap['success'] ?? false,
      message: msg,
      data: dataMap.map(
        (key, value) => MapEntry(key, CostMethodData.fromJson(value)),
      ),
    );
  }
}

class CostMethodData {
  final double totalValue;
  final int itemCount;
  final String? note;

  CostMethodData({
    required this.totalValue,
    required this.itemCount,
    this.note,
  });

  factory CostMethodData.fromJson(Map<String, dynamic> json) {
    return CostMethodData(
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      note: json['note'],
    );
  }
}

class InventoryValueTrendsResponse {
  final bool success;
  final List<InventoryTrendData> data;

  InventoryValueTrendsResponse({required this.success, required this.data});

  factory InventoryValueTrendsResponse.fromJson(Map<String, dynamic> json) {
    // Check if the response is wrapped in a "message" object
    final Map<String, dynamic> dataMap =
        (json['message'] is Map<String, dynamic>) ? json['message'] : json;

    return InventoryValueTrendsResponse(
      success: dataMap['success'] ?? false,
      data:
          (dataMap['data'] as List?)
              ?.map((e) => InventoryTrendData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class InventoryTrendData {
  final String period;
  final double totalValue;
  final double change;
  final double changePercentage;

  InventoryTrendData({
    required this.period,
    required this.totalValue,
    required this.change,
    required this.changePercentage,
  });

  factory InventoryTrendData.fromJson(Map<String, dynamic> json) {
    return InventoryTrendData(
      period: json['period'] ?? '',
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercentage: (json['change_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
