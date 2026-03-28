class ListPurchaseReturnsResponse {
  final String status;
  final String? code;
  final String message;
  final PurchaseReturnsData data;

  ListPurchaseReturnsResponse({
    required this.status,
    this.code,
    required this.message,
    required this.data,
  });

  factory ListPurchaseReturnsResponse.fromJson(Map<String, dynamic> json) {
    // API wraps everything in a 'message' key
    final inner = json['message'] is Map<String, dynamic>
        ? json['message'] as Map<String, dynamic>
        : json;
    return ListPurchaseReturnsResponse(
      status: inner['status'] ?? 'success',
      code: inner['code'],
      message: inner['message'] is String ? inner['message'] : '',
      data: PurchaseReturnsData.fromJson(inner['data'] ?? {}),
    );
  }
}

class PurchaseReturnsData {
  final List<PurchaseReturnListItem> returns;
  final Meta meta;

  PurchaseReturnsData({
    required this.returns,
    required this.meta,
  });

  factory PurchaseReturnsData.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnsData(
      returns: (json['returns'] as List? ?? [])
          .map((i) => PurchaseReturnListItem.fromJson(i))
          .toList(),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}

class PurchaseReturnListItem {
  final String name;
  final String supplier;
  final String postingDate;
  final double grandTotal;
  final String status;
  final int docstatus;
  final String returnAgainst;

  PurchaseReturnListItem({
    required this.name,
    required this.supplier,
    required this.postingDate,
    required this.grandTotal,
    required this.status,
    required this.docstatus,
    required this.returnAgainst,
  });

  factory PurchaseReturnListItem.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnListItem(
      name: json['name'] ?? '',
      supplier: json['supplier'] ?? '',
      postingDate: json['posting_date'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      returnAgainst: json['return_against'] ?? '',
    );
  }
}

class Meta {
  final int page;
  final int pageSize;
  final int total;

  Meta({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
