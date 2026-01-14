import 'dart:convert';

class CreateStockTransferRequest {
  final String company;
  final String fromWarehouse;
  final String toWarehouse;
  final List<StockTransferItem> items;
  final String transactionDate;
  final String scheduleDate;
  final bool submit;

  CreateStockTransferRequest({
    required this.company,
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.items,
    required this.transactionDate,
    required this.scheduleDate,
    this.submit = false,
  });

  Map<String, dynamic> toJson() => {
        "company": company,
        "from_warehouse": fromWarehouse,
        "to_warehouse": toWarehouse,
        "items": items.map((item) => item.toJson()).toList(),
        "transaction_date": transactionDate,
        "schedule_date": scheduleDate,
        "submit": submit,
      };

  String toJsonString() => json.encode(toJson());
}

class StockTransferItem {
  final String itemCode;
  final double qty;

  StockTransferItem({
    required this.itemCode,
    required this.qty,
  });

  Map<String, dynamic> toJson() => {
        "item_code": itemCode,
        "qty": qty,
      };
}