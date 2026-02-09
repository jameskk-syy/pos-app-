class ApproveStockTransferResponse {
  final bool success;
  final String message;
  final ApprovalData data;

  ApproveStockTransferResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApproveStockTransferResponse.fromJson(Map<String, dynamic> json) {
    return ApproveStockTransferResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ApprovalData.fromJson(json['data'] ?? {}),
    );
  }
}

class ApprovalData {
  final String requestId;
  final String status;
  final String approvedBy;
  final bool isApproved;
  final String approvalStatus;
  final String customApprovalStatus;

  ApprovalData({
    required this.requestId,
    required this.status,
    required this.approvedBy,
    required this.isApproved,
    required this.approvalStatus,
    required this.customApprovalStatus,
  });

  factory ApprovalData.fromJson(Map<String, dynamic> json) {
    return ApprovalData(
      requestId: json['request_id'] ?? '',
      status: json['status'] ?? '',
      approvedBy: json['approved_by'] ?? '',
      isApproved: json['is_approved'] ?? false,
      approvalStatus: json['approval_status'] ?? '',
      customApprovalStatus: json['custom_approval_status'] ?? '',
    );
  }
}