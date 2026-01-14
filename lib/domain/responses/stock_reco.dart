class StockResponse {
  final MessageData message;

  StockResponse({required this.message});

  factory StockResponse.fromJson(Map<String, dynamic> json) {
    return StockResponse(
      message: MessageData.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class MessageData {
  final bool success;
  final StockData data;

  MessageData({
    required this.success,
    required this.data,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      success: json['success'] ?? false,
      data: StockData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class StockData {
  final String itemCode;
  final String warehouse;
  final double balance;
  final double actualQty;
  final double reservedQty;
  final double orderedQty;
  final double projectedQty;
  final double stockValue;
  final double valuationRate;
  final String postingDate;

  StockData({
    required this.itemCode,
    required this.warehouse,
    required this.balance,
    required this.actualQty,
    required this.reservedQty,
    required this.orderedQty,
    required this.projectedQty,
    required this.stockValue,
    required this.valuationRate,
    required this.postingDate,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      itemCode: json['item_code'] ?? '',
      warehouse: json['warehouse'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      actualQty: (json['actual_qty'] ?? 0).toDouble(),
      reservedQty: (json['reserved_qty'] ?? 0).toDouble(),
      orderedQty: (json['ordered_qty'] ?? 0).toDouble(),
      projectedQty: (json['projected_qty'] ?? 0).toDouble(),
      stockValue: (json['stock_value'] ?? 0).toDouble(),
      valuationRate: (json['valuation_rate'] ?? 0).toDouble(),
      postingDate: json['posting_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'warehouse': warehouse,
      'balance': balance,
      'actual_qty': actualQty,
      'reserved_qty': reservedQty,
      'ordered_qty': orderedQty,
      'projected_qty': projectedQty,
      'stock_value': stockValue,
      'valuation_rate': valuationRate,
      'posting_date': postingDate,
    };
  }
}