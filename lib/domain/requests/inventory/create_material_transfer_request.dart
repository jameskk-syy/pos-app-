class CreateMaterialTransferRequest {
  final List<MaterialTransferItem> items;
  final String fromWarehouse;
  final String toWarehouse;
  final String transactionDate;
  final bool submit;
  final String company;

  CreateMaterialTransferRequest({
    required this.items,
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.transactionDate,
    required this.submit,
    required this.company,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'from_warehouse': fromWarehouse,
      'to_warehouse': toWarehouse,
      'transaction_date': transactionDate,
      'submit': submit,
      'company': company,
    };
  }
}

class MaterialTransferItem {
  final String itemCode;
  final double qty;

  MaterialTransferItem({
    required this.itemCode,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
    };
  }
}