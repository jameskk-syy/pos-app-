class CreateMaterialTransferResponse {
  final bool success;
  final String message;
  final StockEntryData data;

  CreateMaterialTransferResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateMaterialTransferResponse.fromJson(Map<String, dynamic> json) {
    return CreateMaterialTransferResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StockEntryData.fromJson(json['data'] ?? {}),
    );
  }
}

class StockEntryData {
  final String name;
  final String stockEntryType;
  final String company;
  final String postingDate;
  final int docstatus;
  final int itemsCount;

  StockEntryData({
    required this.name,
    required this.stockEntryType,
    required this.company,
    required this.postingDate,
    required this.docstatus,
    required this.itemsCount,
  });

  factory StockEntryData.fromJson(Map<String, dynamic> json) {
    return StockEntryData(
      name: json['name'] ?? '',
      stockEntryType: json['stock_entry_type'] ?? '',
      company: json['company'] ?? '',
      postingDate: json['posting_date'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      itemsCount: json['items_count'] ?? 0,
    );
  }
}