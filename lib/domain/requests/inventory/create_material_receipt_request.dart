class CreateMaterialReceiptRequest {
  final List<MaterialReceiptItem> items;
  final String targetWarehouse;
  final String postingDate;
  final bool doNotSubmit;
  final String company;

  CreateMaterialReceiptRequest({
    required this.items,
    required this.targetWarehouse,
    required this.postingDate,
    required this.doNotSubmit,
    required this.company,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'target_warehouse': targetWarehouse,
      'posting_date': postingDate,
      'do_not_submit': doNotSubmit,
      'company': company,
    };
  }

  factory CreateMaterialReceiptRequest.fromJson(Map<String, dynamic> json) {
    return CreateMaterialReceiptRequest(
      items: (json['items'] as List)
          .map((item) => MaterialReceiptItem.fromJson(item))
          .toList(),
      targetWarehouse: json['target_warehouse'] ?? '',
      postingDate: json['posting_date'] ?? '',
      doNotSubmit: json['do_not_submit'] ?? false,
      company: json['company'] ?? '',
    );
  }
}

class MaterialReceiptItem {
  final String itemCode;
  final double qty;
  final String tWarehouse;

  MaterialReceiptItem({
    required this.itemCode,
    required this.qty,
    required this.tWarehouse,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
      't_warehouse': tWarehouse,
    };
  }

  factory MaterialReceiptItem.fromJson(Map<String, dynamic> json) {
    return MaterialReceiptItem(
      itemCode: json['item_code'] ?? '',
      qty: (json['qty'] ?? 0).toDouble(),
      tWarehouse: json['t_warehouse'] ?? '',
    );
  }
}