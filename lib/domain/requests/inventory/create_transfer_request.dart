class CreateMaterialTransferRequest {
  final String? sourceWarehouse;
  final String? targetWarehouse;
  final String postingDate;
  final bool doNotSubmit;
  final String company;
  final List<TransferItem> items;

  CreateMaterialTransferRequest({
    this.sourceWarehouse,
    this.targetWarehouse,
    required this.postingDate,
    this.doNotSubmit = false,
    required this.company,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'source_warehouse': sourceWarehouse,
      'target_warehouse': targetWarehouse,
      'posting_date': postingDate,
      'do_not_submit': doNotSubmit,
      'company': company,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class TransferItem {
  final String itemCode;
  final double qty;
  final String sWarehouse;
  final String tWarehouse;

  TransferItem({
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