
class StockEntriesRequest {
  final String company;
  final int page;
  final int pageSize;
  final String? stockEntryType;
  final String? warehouse;
  final int? docstatus;
  final String? fromDate;
  final String? toDate;
  final String? itemCode;

  StockEntriesRequest({
    required this.company,
    this.page = 1,
    this.pageSize = 20,
    this.stockEntryType,
    this.warehouse,
    this.docstatus,
    this.fromDate,
    this.toDate,
    this.itemCode,
  });

  Map<String, dynamic> toJson() => {
        "company": company,
        "page": page,
        "page_size": pageSize,
        if (stockEntryType != null) "stock_entry_type": stockEntryType,
        if (warehouse != null) "warehouse": warehouse,
        if (docstatus != null) "docstatus": docstatus,
        if (fromDate != null) "from_date": fromDate,
        if (toDate != null) "to_date": toDate,
        if (itemCode != null) "item_code": itemCode,
      };
}