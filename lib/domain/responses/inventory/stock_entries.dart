import 'package:pos/domain/models/stock_ledger_entry.dart';

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