class SubmitPurchaseOrderRequest {
  final String lpoNo;

  SubmitPurchaseOrderRequest({
    required this.lpoNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'lpo_no': lpoNo,
    };
  }
}