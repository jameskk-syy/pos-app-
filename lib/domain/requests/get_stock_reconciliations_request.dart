// lib/domain/requests/get_stock_reconciliations_request.dart
class GetStockReconciliationsRequest {
  final String? workflowStatus;
  final String? warehouse;
  final String company;
  final int limit;
  final int offset;

  GetStockReconciliationsRequest({
    this.workflowStatus,
    this.warehouse,
    required this.company,
    this.limit = 20,
    this.offset = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      if (workflowStatus != null) 'workflow_status': workflowStatus,
      if (warehouse != null) 'warehouse': warehouse,
      'company': company,
      'limit': limit,
      'offset': offset,
    };
  }
}