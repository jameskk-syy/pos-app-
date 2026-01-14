// lib/domain/models/stock_ledger_entry.dart
class StockLedgerEntry {
  final String name;
  final String itemCode;
  final String warehouse;
  final String postingDate;
  final String postingTime;
  final String voucherType;
  final String voucherNo;
  final double actualQty;
  final double qtyAfterTransaction;
  final double incomingRate;
  final double valuationRate;
  final double stockValue;
  final double stockValueDifference;
  final int isCancelled;

  StockLedgerEntry({
    required this.name,
    required this.itemCode,
    required this.warehouse,
    required this.postingDate,
    required this.postingTime,
    required this.voucherType,
    required this.voucherNo,
    required this.actualQty,
    required this.qtyAfterTransaction,
    required this.incomingRate,
    required this.valuationRate,
    required this.stockValue,
    required this.stockValueDifference,
    required this.isCancelled,
  });

  factory StockLedgerEntry.fromJson(Map<String, dynamic> json) {
    return StockLedgerEntry(
      name: json['name'] ?? '',
      itemCode: json['item_code'] ?? '',
      warehouse: json['warehouse'] ?? '',
      postingDate: json['posting_date'] ?? '',
      postingTime: json['posting_time'] ?? '',
      voucherType: json['voucher_type'] ?? '',
      voucherNo: json['voucher_no'] ?? '',
      actualQty: (json['actual_qty'] as num?)?.toDouble() ?? 0.0,
      qtyAfterTransaction: (json['qty_after_transaction'] as num?)?.toDouble() ?? 0.0,
      incomingRate: (json['incoming_rate'] as num?)?.toDouble() ?? 0.0,
      valuationRate: (json['valuation_rate'] as num?)?.toDouble() ?? 0.0,
      stockValue: (json['stock_value'] as num?)?.toDouble() ?? 0.0,
      stockValueDifference: (json['stock_value_difference'] as num?)?.toDouble() ?? 0.0,
      isCancelled: json['is_cancelled'] ?? 0,
    );
  }
}

// lib/domain/responses/stock_ledger_response.dart
class StockLedgerResponse {
  final bool success;
  final List<StockLedgerEntry> data;
  final int count;

  StockLedgerResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  factory StockLedgerResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>? ?? {};
    
    return StockLedgerResponse(
      success: message['success'] ?? false,
      count: message['count'] ?? 0,
      data: (message['data'] as List<dynamic>?)
          ?.map((item) => StockLedgerEntry.fromJson(item))
          .toList() ?? [],
    );
  }
}