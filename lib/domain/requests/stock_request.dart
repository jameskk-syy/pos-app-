class StockRequest {
  final String itemCode;
  final String warehouse;
  final String company;

  StockRequest({
    required this.itemCode,
    required this.warehouse,
    required this.company,
  });

  factory StockRequest.fromJson(Map<String, dynamic> json) {
    return StockRequest(
      itemCode: json['item_code'] ?? '',
      warehouse: json['warehouse'] ?? '',
      company: json['company'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'warehouse': warehouse,
      'company': company,
    };
  }

  StockRequest copyWith({
    String? itemCode,
    String? warehouse,
    String? company,
  }) {
    return StockRequest(
      itemCode: itemCode ?? this.itemCode,
      warehouse: warehouse ?? this.warehouse,
      company: company ?? this.company,
    );
  }

  @override
  String toString() {
    return 'StockRequest(itemCode: $itemCode, warehouse: $warehouse, company: $company)';
  }
}