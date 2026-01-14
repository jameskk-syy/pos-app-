// lib/domain/responses/stock_entries_response.dart

class StockEntryItem {
  final String itemCode;
  final double qty;
  final String? sWarehouse;
  String? tWarehouse;
  final double basicRate;
  final double amount;

  StockEntryItem(
    {
    required this.itemCode,
    required this.qty,
    this.sWarehouse,
    this.tWarehouse,
    required this.basicRate,
    required this.amount,
  });

  factory StockEntryItem.fromJson(Map<String, dynamic> json) => StockEntryItem(
        itemCode: json['item_code'] as String,
        qty: (json['qty'] as num).toDouble(),
        sWarehouse: json['s_warehouse'] as String?,
        tWarehouse: json['t_warehouse']?.toString(),
        basicRate: (json['basic_rate'] as num).toDouble(),
        amount: (json['amount'] as num).toDouble(),
      );
}

class StockEntry {
  final String name;
  final String stockEntryType;
  final String purpose;
  final String company;
  final String postingDate;
  final String postingTime;
  final int docstatus;
  final double totalOutgoingValue;
  final double totalIncomingValue;
  final double totalAdditionalCosts;
  final double totalAmount;
  final List<StockEntryItem> items;
  final int itemsCount;

  StockEntry({
    required this.name,
    required this.stockEntryType,
    required this.purpose,
    required this.company,
    required this.postingDate,
    required this.postingTime,
    required this.docstatus,
    required this.totalOutgoingValue,
    required this.totalIncomingValue,
    required this.totalAdditionalCosts,
    required this.totalAmount,
    required this.items,
    required this.itemsCount,
  });

  factory StockEntry.fromJson(Map<String, dynamic> json) => StockEntry(
        name: json['name'] as String,
        stockEntryType: json['stock_entry_type'] as String,
        purpose: json['purpose'] as String,
        company: json['company'] as String,
        postingDate: json['posting_date'] as String,
        postingTime: json['posting_time'] as String,
        docstatus: json['docstatus'] as int,
        totalOutgoingValue: (json['total_outgoing_value'] as num).toDouble(),
        totalIncomingValue: (json['total_incoming_value'] as num).toDouble(),
        totalAdditionalCosts:
            (json['total_additional_costs'] as num).toDouble(),
        totalAmount: (json['total_amount'] as num).toDouble(),
        items: (json['items'] as List<dynamic>)
            .map((item) => StockEntryItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        itemsCount: json['items_count'] as int,
      );
}

class Pagination {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json['page'] as int,
        pageSize: json['page_size'] as int,
        total: json['total'] as int,
        totalPages: json['total_pages'] as int,
      );
}

class StockEntriesData {
  final List<StockEntry> entries;
  final Pagination pagination;

  StockEntriesData({
    required this.entries,
    required this.pagination,
  });

  factory StockEntriesData.fromJson(Map<String, dynamic> json) => StockEntriesData(
        entries: (json['entries'] as List<dynamic>)
            .map((entry) => StockEntry.fromJson(entry as Map<String, dynamic>))
            .toList(),
        pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
      );
}

class StockEntriesResponse {
  final bool success;
  final StockEntriesData data;

  StockEntriesResponse({
    required this.success,
    required this.data,
  });

  factory StockEntriesResponse.fromJson(Map<String, dynamic> json) => StockEntriesResponse(
        success: json['success'] as bool,
        data: StockEntriesData.fromJson(json['data'] as Map<String, dynamic>),
      );
}