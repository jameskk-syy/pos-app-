class CreateMaterialTransferRequest {
  final List<MaterialTransferItem> items;
  final String sourceWarehouse;
  final String targetWarehouse;
  final String postingDate;
  final bool doNotSubmit;
  final String company;

  CreateMaterialTransferRequest({
    required this.items,
    required this.sourceWarehouse,
    required this.targetWarehouse,
    required this.postingDate,
    required this.doNotSubmit,
    required this.company,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'source_warehouse': sourceWarehouse,
      'target_warehouse': targetWarehouse,
      'posting_date': postingDate,
      'do_not_submit': doNotSubmit,
      'company': company,
    };
  }
}

class MaterialTransferItem {
  final String itemCode;
  final double qty;
  final String sWarehouse;
  final String tWarehouse;

  MaterialTransferItem({
    required this.itemCode,
    required this.qty,
    required this.sWarehouse,
    required this.tWarehouse,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
      's_warehouse': sWarehouse,
      't_warehouse': tWarehouse,
    };
  }
}