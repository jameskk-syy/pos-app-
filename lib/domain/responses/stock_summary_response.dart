class StockSummaryResponse {
  final bool success;
  final String? errorMessage;
  final List<StockSummaryItem> data;
  final int count;

  StockSummaryResponse({
    required this.success,
    this.errorMessage,
    required this.data,
    required this.count,
  });

  factory StockSummaryResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] is Map<String, dynamic>) {
      final message = json['message'] as Map<String, dynamic>;
      
      if (message.containsKey('success') && message['success'] == false) {
        return StockSummaryResponse(
          success: false,
          errorMessage: message['message'] as String?,
          data: [],
          count: 0,
        );
      }
      
      if (message.containsKey('data') && message['data'] is List) {
        final List<dynamic> rawData = message['data'] as List;
        final dataList = rawData.map((item) {
          return StockSummaryItem.fromJson(item as Map<String, dynamic>);
        }).toList();

        return StockSummaryResponse(
          success: message['success'] as bool,
          data: dataList,
          count: (message['count'] as int?) ?? dataList.length,
        );
      }
    }
    
    return StockSummaryResponse(
      success: json['success'] as bool? ?? false,
      errorMessage: json['message'] as String?,
      data: [],
      count: 0,
    );
  }
}

class StockSummaryItem {
  final String itemCode;
  final String warehouse;
  final double actualQty;
  final double reservedQty;
  final double orderedQty;
  final double projectedQty;
  final double stockValue;
  final double valuationRate;
  final String itemName;
  final String itemGroup;
  final String stockUom;
  final int isStockItem;

  StockSummaryItem({
    required this.itemCode,
    required this.warehouse,
    required this.actualQty,
    required this.reservedQty,
    required this.orderedQty,
    required this.projectedQty,
    required this.stockValue,
    required this.valuationRate,
    required this.itemName,
    required this.itemGroup,
    required this.stockUom,
    required this.isStockItem,
  });

  factory StockSummaryItem.fromJson(Map<String, dynamic> json) {
    return StockSummaryItem(
      itemCode: json['item_code']?.toString() ?? '',
      warehouse: json['warehouse']?.toString() ?? '',
      actualQty: (json['actual_qty'] as num?)?.toDouble() ?? 0.0,
      reservedQty: (json['reserved_qty'] as num?)?.toDouble() ?? 0.0,
      orderedQty: (json['ordered_qty'] as num?)?.toDouble() ?? 0.0,
      projectedQty: (json['projected_qty'] as num?)?.toDouble() ?? 0.0,
      stockValue: (json['stock_value'] as num?)?.toDouble() ?? 0.0,
      valuationRate: (json['valuation_rate'] as num?)?.toDouble() ?? 0.0,
      itemName: json['item_name']?.toString() ?? '',
      itemGroup: json['item_group']?.toString() ?? '',
      stockUom: json['stock_uom']?.toString() ?? '',
      isStockItem: (json['is_stock_item'] as int?) ?? 0,
    );
  }
}