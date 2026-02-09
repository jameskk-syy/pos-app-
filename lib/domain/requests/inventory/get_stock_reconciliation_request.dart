class GetStockReconciliationRequest {
  final String reconciliationName;

  GetStockReconciliationRequest({
    required this.reconciliationName,
  });

  Map<String, dynamic> toQueryParams() => {
        "reconciliation_name": reconciliationName,
      };
}