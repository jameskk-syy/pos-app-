class ApproveStockTransferRequest {
  final String requestId;
  final String approvedBy;
  final String approvalNotes;
  final bool isApproved;

  ApproveStockTransferRequest({
    required this.requestId,
    required this.approvedBy,
    this.approvalNotes = '',
    required this.isApproved,
  });

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'approved_by': approvedBy,
      'approval_notes': approvalNotes,
      'is_approved': isApproved,
    };
  }
}