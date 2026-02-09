enum StockTakeRole { salesPerson, stockController, stockManager }

class AddStockTakeRequest {
  final String reconciliationName;
  final List<StockTakeItem> items;
  final String? comment;

  AddStockTakeRequest({
    required this.reconciliationName,
    required this.items,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    "reconciliation_name": reconciliationName,
    "items": items.map((item) => item.toJson()).toList(),
    if (comment != null && comment!.isNotEmpty) "comment": comment,
  };
}

class StockTakeItem {
  final String itemCode;
  final double qty;
  final String? comment;

  StockTakeItem({required this.itemCode, required this.qty, this.comment});

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    "qty": qty,
    if (comment != null && comment!.isNotEmpty) "comment": comment,
  };
}
