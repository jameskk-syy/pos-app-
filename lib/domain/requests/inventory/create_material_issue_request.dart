// lib/domain/requests/create_material_issue_request.dart
class CreateMaterialIssueRequest {
  final List<MaterialIssueItem> items;
  final String sourceWarehouse;
  final String postingDate;
  final bool doNotSubmit;
  final String company;

  CreateMaterialIssueRequest({
    required this.items,
    required this.sourceWarehouse,
    required this.postingDate,
    required this.doNotSubmit,
    required this.company,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'source_warehouse': sourceWarehouse,
      'posting_date': postingDate,
      'do_not_submit': doNotSubmit,
      'company': company,
    };
  }
}

class MaterialIssueItem {
  final String itemCode;
  final double qty;
  final String sWarehouse;
  final String purpose;

  MaterialIssueItem({
    required this.itemCode,
    required this.qty,
    required this.sWarehouse,
    required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
      's_warehouse': sWarehouse,
      'purpose': purpose,
    };
  }
}