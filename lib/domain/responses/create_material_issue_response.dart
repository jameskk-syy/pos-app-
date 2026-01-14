// lib/domain/responses/create_material_issue_response.dart
class CreateMaterialIssueResponse {
  final bool success;
  final String message;
  final MaterialIssueData? data;

  CreateMaterialIssueResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateMaterialIssueResponse.fromJson(Map<String, dynamic> json) {
    return CreateMaterialIssueResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? MaterialIssueData.fromJson(json['data']) 
          : null,
    );
  }
}

class MaterialIssueData {
  final String name;
  final String stockEntryType;
  final String company;
  final String postingDate;
  final int docstatus;
  final int itemsCount;

  MaterialIssueData({
    required this.name,
    required this.stockEntryType,
    required this.company,
    required this.postingDate,
    required this.docstatus,
    required this.itemsCount,
  });

  factory MaterialIssueData.fromJson(Map<String, dynamic> json) {
    return MaterialIssueData(
      name: json['name'] ?? '',
      stockEntryType: json['stock_entry_type'] ?? '',
      company: json['company'] ?? '',
      postingDate: json['posting_date'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      itemsCount: json['items_count'] ?? 0,
    );
  }
}