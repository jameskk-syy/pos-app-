class StockReconciliationsResponse {
  final StockReconciliationsMessage message;

  StockReconciliationsResponse({required this.message});

  factory StockReconciliationsResponse.fromJson(Map<String, dynamic> json) {
    return StockReconciliationsResponse(
      message: StockReconciliationsMessage.fromJson(json['message'] ?? {}),
    );
  }
}

class StockReconciliationsMessage {
  final bool success;
  final ReconciliationData data;

  StockReconciliationsMessage({required this.success, required this.data});

  factory StockReconciliationsMessage.fromJson(Map<String, dynamic> json) {
    return StockReconciliationsMessage(
      success: json['success'] ?? false,
      data: ReconciliationData.fromJson(json['data'] ?? {}),
    );
  }
}

class ReconciliationData {
  final List<StockReconciliation> reconciliations;
  final int totalCount;
  final int limit;
  final int offset;
  final bool hasMore;

  ReconciliationData({
    required this.reconciliations,
    required this.totalCount,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory ReconciliationData.fromJson(Map<String, dynamic> json) {
    return ReconciliationData(
      reconciliations:
          (json['reconciliations'] as List?)
              ?.map((item) => StockReconciliation.fromJson(item))
              .toList() ??
          [],
      totalCount: json['total_count'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }
}

class StockReconciliation {
  final String name;
  final String company;
  final String warehouse;
  final String postingDate;
  final String postingTime;
  final String purpose;
  final int docstatus;
  final String workflowStatus;
  final String creation;
  final String modified;
  final String owner;
  final int itemsCount;
  final List<String> warehouses;

  StockReconciliation({
    required this.name,
    required this.company,
    required this.warehouse,
    required this.postingDate,
    required this.postingTime,
    required this.purpose,
    required this.docstatus,
    required this.workflowStatus,
    required this.creation,
    required this.modified,
    required this.owner,
    required this.itemsCount,
    required this.warehouses,
  });

  factory StockReconciliation.fromJson(Map<String, dynamic> json) {
    return StockReconciliation(
      name: json['name'] ?? "",
      company: json['company'] ?? "",
      warehouse: json['warehouse'] ?? "",
      postingDate: json['posting_date'] ?? "",
      postingTime: json['posting_time'] ?? "",
      purpose: json['purpose'] ?? "",
      docstatus: json['docstatus'] ?? 0,
      workflowStatus: json['workflow_state'] ?? json['workflow_status'] ?? "",
      creation: json['creation'] ?? "",
      modified: json['modified'] ?? "",
      owner: json['owner'] ?? "",
      itemsCount: json['items_count'] ?? 0,
      warehouses: json['warehouses'] != null
          ? List<String>.from(json['warehouses'])
          : [],
    );
  }
}
