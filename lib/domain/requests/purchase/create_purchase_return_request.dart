class CreatePurchaseReturnRequest {
  final String returnAgainst;
  final String postingDate;
  final String company;
  final String? supplier;
  final List<PurchaseReturnItemRequest> items;

  CreatePurchaseReturnRequest({
    required this.returnAgainst,
    required this.postingDate,
    required this.company,
    this.supplier,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'return_against': returnAgainst,
      'posting_date': postingDate,
      'company': company,
      if (supplier != null) 'supplier': supplier,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class PurchaseReturnItemRequest {
  final String itemCode;
  final double qty;
  final double rate;
  final String warehouse;

  PurchaseReturnItemRequest({
    required this.itemCode,
    required this.qty,
    required this.rate,
    required this.warehouse,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
      'rate': rate,
      'warehouse': warehouse,
    };
  }
}
