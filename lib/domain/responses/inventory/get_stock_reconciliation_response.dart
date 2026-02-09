class GetStockReconciliationResponse {
  final GetStockReconciliationMessage message;

  GetStockReconciliationResponse({required this.message});

  factory GetStockReconciliationResponse.fromJson(Map<String, dynamic> json) =>
      GetStockReconciliationResponse(
        message: GetStockReconciliationMessage.fromJson(json["message"]),
      );
}

class GetStockReconciliationMessage {
  final bool success;
  final StockReconciliationDetail data;

  GetStockReconciliationMessage({required this.success, required this.data});

  factory GetStockReconciliationMessage.fromJson(Map<String, dynamic> json) =>
      GetStockReconciliationMessage(
        success: json["success"],
        data: StockReconciliationDetail.fromJson(json["data"]),
      );
}

class StockReconciliationDetail {
  final String name;
  final String company;
  final String? warehouse;
  final String postingDate;
  final String postingTime;
  final String purpose;
  final int docstatus;
  final String workflowStatus;
  final List<StockTakingRecord> stockTakingRecords;
  final List<ReconciliationItem> items;

  StockReconciliationDetail({
    required this.name,
    required this.company,
    required this.warehouse,
    required this.postingDate,
    required this.postingTime,
    required this.purpose,
    required this.docstatus,
    required this.workflowStatus,
    required this.stockTakingRecords,
    required this.items,
  });

  factory StockReconciliationDetail.fromJson(Map<String, dynamic> json) =>
      StockReconciliationDetail(
        name: json["name"],
        company: json["company"],
        warehouse: json["warehouse"],
        postingDate: json["posting_date"],
        postingTime: json["posting_time"],
        purpose: json["purpose"],
        docstatus: json["docstatus"],
        workflowStatus: json["workflow_state"] ?? json["workflow_status"] ?? '',
        stockTakingRecords: (json["stock_taking_records"] as List)
            .map((item) => StockTakingRecord.fromJson(item))
            .toList(),
        items: (json["items"] as List)
            .map((item) => ReconciliationItem.fromJson(item))
            .toList(),
      );
}

class StockTakingRecord {
  final String itemCode;
  final String warehouse;
  final double finalQty;
  final double currentQty;
  final double salesPersonQty;
  final String? salesPersonComment;
  final String? salesPersonName;
  final String? salesPersonDate;
  final double stockControllerQty;
  final String? stockControllerComment;
  final String? stockControllerName;
  final String? stockControllerDate;
  final double stockManagerQty;
  final String? stockManagerComment;
  final String? stockManagerName;
  final String? stockManagerDate;

  StockTakingRecord({
    required this.itemCode,
    required this.warehouse,
    required this.finalQty,
    required this.currentQty,
    required this.salesPersonQty,
    required this.salesPersonComment,
    required this.salesPersonName,
    required this.salesPersonDate,
    required this.stockControllerQty,
    required this.stockControllerComment,
    required this.stockControllerName,
    required this.stockControllerDate,
    required this.stockManagerQty,
    required this.stockManagerComment,
    required this.stockManagerName,
    required this.stockManagerDate,
  });

  factory StockTakingRecord.fromJson(Map<String, dynamic> json) =>
      StockTakingRecord(
        itemCode: json["item_code"],
        warehouse: json["warehouse"],
        finalQty: (json["final_qty"] as num).toDouble(),
        currentQty: (json["current_qty"] as num).toDouble(),
        salesPersonQty: (json["sales_person_qty"] as num).toDouble(),
        salesPersonComment: json["sales_person_comment"],
        salesPersonName: json["sales_person_name"],
        salesPersonDate: json["sales_person_date"],
        stockControllerQty: (json["stock_controller_qty"] as num).toDouble(),
        stockControllerComment: json["stock_controller_comment"],
        stockControllerName: json["stock_controller_name"],
        stockControllerDate: json["stock_controller_date"],
        stockManagerQty: (json["stock_manager_qty"] as num).toDouble(),
        stockManagerComment: json["stock_manager_comment"],
        stockManagerName: json["stock_manager_name"],
        stockManagerDate: json["stock_manager_date"],
      );
}

class ReconciliationItem {
  final String itemCode;
  final String warehouse;
  final double qty;
  final double currentQty;

  ReconciliationItem({
    required this.itemCode,
    required this.warehouse,
    required this.qty,
    required this.currentQty,
  });

  factory ReconciliationItem.fromJson(Map<String, dynamic> json) =>
      ReconciliationItem(
        itemCode: json["item_code"],
        warehouse: json["warehouse"],
        qty: (json["qty"] as num).toDouble(),
        currentQty: (json["current_qty"] as num).toDouble(),
      );
}
