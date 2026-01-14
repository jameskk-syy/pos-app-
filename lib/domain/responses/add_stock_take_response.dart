class AddStockTakeResponse {
  final AddStockTakeMessage message;
  final String? serverMessages;

  AddStockTakeResponse({required this.message, this.serverMessages});

  factory AddStockTakeResponse.fromJson(Map<String, dynamic> json) =>
      AddStockTakeResponse(
        message: AddStockTakeMessage.fromJson(json["message"]),
        serverMessages: json["_server_messages"],
      );
}

class AddStockTakeMessage {
  final bool success;
  final String message;
  final StockTakeData data;

  AddStockTakeMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddStockTakeMessage.fromJson(Map<String, dynamic> json) =>
      AddStockTakeMessage(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: StockTakeData.fromJson(json["data"] ?? {}),
      );
}

class StockTakeData {
  final String reconciliationName;
  final int itemsCounted;
  final String workflowStatus;
  final SubmissionData? submission;
  final int? docstatus;

  StockTakeData({
    required this.reconciliationName,
    required this.itemsCounted,
    required this.workflowStatus,
    this.submission,
    this.docstatus,
  });

  factory StockTakeData.fromJson(Map<String, dynamic> json) => StockTakeData(
    reconciliationName: json["reconciliation_name"] ?? '',
    itemsCounted: json["items_counted"] ?? 0,
    workflowStatus: json["workflow_state"] ?? json["workflow_status"] ?? '',
    submission: json["submission"] != null
        ? SubmissionData.fromJson(json["submission"])
        : null,
    docstatus: json["docstatus"],
  );
}

class SubmissionData {
  final bool submitted;
  final String? error;

  SubmissionData({required this.submitted, this.error});

  factory SubmissionData.fromJson(Map<String, dynamic> json) => SubmissionData(
    submitted: json["submitted"] ?? false,
    error: json["error"],
  );
}
