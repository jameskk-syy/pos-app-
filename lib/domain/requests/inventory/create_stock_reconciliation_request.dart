class CreateStockReconciliationRequest {
  final String warehouse;
  final String postingDate;
  final String postingTime;
  final String purpose;
  final String expenseAccount;
  final String costCenter;
  final List<StockReconciliationItem> items;
  final String company;
  final bool doNotSubmit;

  CreateStockReconciliationRequest({
    required this.warehouse,
    required this.postingDate,
    required this.postingTime,
    required this.purpose,
    required this.expenseAccount,
    required this.costCenter,
    required this.items,
    required this.company,
    this.doNotSubmit = false,
  });

  Map<String, dynamic> toJson() => {
    "warehouse": warehouse,
    "posting_date": postingDate,
    "posting_time": postingTime,
    "purpose": purpose,
    "expense_account": expenseAccount,
    "cost_center": costCenter,
    "items": items.map((item) => item.toJson()).toList(),
    "company": company,
    "do_not_submit": doNotSubmit,
  };
}

class StockReconciliationItem {
  final String itemCode;
  double? qty;
  String? warehouse;
  double? valuationRate;
  double? buyingPrice;
  double? sellingPrice;
  String? unitOfMeasure;
  String? sku;
  String? expiryDate;
  String? batchNo;

  StockReconciliationItem({
    required this.itemCode,
    this.qty,
    this.warehouse,
    this.valuationRate,
    this.buyingPrice,
    this.sellingPrice,
    this.unitOfMeasure,
    this.sku,
    this.expiryDate,
    this.batchNo,
  });

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    if (qty != null) "qty": qty,
    if (warehouse != null) "warehouse": warehouse,
    if (valuationRate != null) "valuation_rate": valuationRate,
    if (buyingPrice != null) "buying_price": buyingPrice,
    if (sellingPrice != null) "selling_price": sellingPrice,
    if (unitOfMeasure != null) "unit_of_measure": unitOfMeasure,
    if (sku != null) "sku": sku,
    if (expiryDate != null) "expiry_date": expiryDate,
    if (batchNo != null) "batch_no": batchNo,
  };
}
