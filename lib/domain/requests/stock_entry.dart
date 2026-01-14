class CreateStockEntryRequest {
  final String stockEntryType;
  final List<StockEntryItem> items;
  final String postingDate;
  final String postingTime;
  final String? toWarehouse;
  final String company;
  final String? purpose;

  CreateStockEntryRequest({
    required this.stockEntryType,
    required this.items,
    required this.postingDate,
    required this.postingTime,
    this.toWarehouse,
    required this.company,
    this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'stock_entry_type': stockEntryType,
      'items': items.map((item) => item.toJson()).toList(),
      'posting_date': postingDate,
      'posting_time': postingTime,
      if (toWarehouse != null) 'to_warehouse': toWarehouse,
      'company': company,
      if (purpose != null && purpose!.isNotEmpty) 'purpose': purpose,
    };
  }
}

class StockEntryItem {
  final String itemCode;
  final int qty;
  final String tWarehouse;
  final double basicRate;

  StockEntryItem({
    required this.itemCode,
    required this.qty,
    required this.tWarehouse,
    required this.basicRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
      't_warehouse': tWarehouse,
      'basic_rate': basicRate,
    };
  }
}