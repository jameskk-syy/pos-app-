class CreateMaterialTransferResponse {
  final bool success;
  final String message;
  final MaterialTransferData? data;

  CreateMaterialTransferResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateMaterialTransferResponse.fromJson(Map<String, dynamic> json) {
    return CreateMaterialTransferResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? MaterialTransferData.fromJson(json['data']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class MaterialTransferData {
  final String name;
  final String stockEntryType;
  final String company;
  final String postingDate;
  final int docstatus;
  final int itemsCount;

  MaterialTransferData({
    required this.name,
    required this.stockEntryType,
    required this.company,
    required this.postingDate,
    required this.docstatus,
    required this.itemsCount,
  });

  factory MaterialTransferData.fromJson(Map<String, dynamic> json) {
    return MaterialTransferData(
      name: json['name'] ?? '',
      stockEntryType: json['stock_entry_type'] ?? '',
      company: json['company'] ?? '',
      postingDate: json['posting_date'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      itemsCount: json['items_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'stock_entry_type': stockEntryType,
      'company': company,
      'posting_date': postingDate,
      'docstatus': docstatus,
      'items_count': itemsCount,
    };
  }
}