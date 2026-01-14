class CreateMaterialReceiptResponse {
  final bool success;
  final String message;
  final MaterialReceiptData? data;

  CreateMaterialReceiptResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateMaterialReceiptResponse.fromJson(Map<String, dynamic> json) {
    final messageData = json['message'] as Map<String, dynamic>?;
    
    if (messageData == null) {
      return CreateMaterialReceiptResponse(
        success: false,
        message: 'Invalid response format',
        data: null,
      );
    }

    return CreateMaterialReceiptResponse(
      success: messageData['success'] ?? false,
      message: messageData['message'] ?? '',
      data: messageData['data'] != null
          ? MaterialReceiptData.fromJson(messageData['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      }
    };
  }
}

class MaterialReceiptData {
  final String name;
  final String stockEntryType;
  final String company;
  final String postingDate;
  final int docstatus;
  final int itemsCount;

  MaterialReceiptData({
    required this.name,
    required this.stockEntryType,
    required this.company,
    required this.postingDate,
    required this.docstatus,
    required this.itemsCount,
  });

  factory MaterialReceiptData.fromJson(Map<String, dynamic> json) {
    return MaterialReceiptData(
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