class CreateStockReconciliationResponse {
  final CreateStockReconciliationMessage message;

  CreateStockReconciliationResponse({required this.message});

  factory CreateStockReconciliationResponse.fromJson(
    Map<String, dynamic> json,
  ) => CreateStockReconciliationResponse(
    message: CreateStockReconciliationMessage.fromJson(json["message"]),
  );
}

class CreateStockReconciliationMessage {
  final bool success;
  final String message;
  final StockReconciliationData data;

  CreateStockReconciliationMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateStockReconciliationMessage.fromJson(
    Map<String, dynamic> json,
  ) => CreateStockReconciliationMessage(
    success: json["success"],
    message: json["message"],
    data: StockReconciliationData.fromJson(json["data"]),
  );
}

class StockReconciliationData {
  final String name;
  final String company;
  final String warehouse;
  final String postingDate;
  final int docstatus;
  final String workflowStatus;

  StockReconciliationData({
    required this.name,
    required this.company,
    required this.warehouse,
    required this.postingDate,
    required this.docstatus,
    required this.workflowStatus,
  });

  factory StockReconciliationData.fromJson(Map<String, dynamic> json) =>
      StockReconciliationData(
        name: json["name"],
        company: json["company"],
        warehouse: json["warehouse"],
        postingDate: json["posting_date"],
        docstatus: json["docstatus"],
        workflowStatus:
            json["workflow_state"] ?? json["workflow_status"] ?? 'Unknown',
      );
}
