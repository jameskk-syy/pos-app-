// lib/domain/requests/stock_entries_request.dart
class StockEntriesRequest {
  final String company;
  final int page;
  final int pageSize;
  final String? stockEntryType;
  final String? warehouse;
  final int? docstatus;

  StockEntriesRequest({
    required this.company,
    this.page = 1,
    this.pageSize = 20,
    this.stockEntryType,
    this.warehouse,
    this.docstatus,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'company': company,
      'page': page,
      'page_size': pageSize,
    };

    if (stockEntryType != null && stockEntryType!.isNotEmpty) {
      map['stock_entry_type'] = stockEntryType;
    }

    if (warehouse != null && warehouse!.isNotEmpty) {
      map['warehouse'] = warehouse;
    }

    if (docstatus != null) {
      map['docstatus'] = docstatus;
    }

    return map;
  }
}