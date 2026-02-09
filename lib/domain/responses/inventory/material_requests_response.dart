// lib/domain/responses/material_requests_response.dart

class MaterialRequestsResponse {
  final bool success;
  final String message;
  final MaterialRequestsData data;

  MaterialRequestsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MaterialRequestsResponse.fromJson(Map<String, dynamic> json) {
    return MaterialRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: MaterialRequestsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class MaterialRequestsData {
  final List<MaterialRequest> requests;

  MaterialRequestsData({required this.requests});

  factory MaterialRequestsData.fromJson(Map<String, dynamic> json) {
    return MaterialRequestsData(
      requests: (json['requests'] as List<dynamic>?)
              ?.map((e) => MaterialRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requests': requests.map((e) => e.toJson()).toList(),
    };
  }
}

class MaterialRequest {
  final String name;
  final String requestedBy;
  final String requestedOn;
  final String status;
  final String approvalStatus;
  final String approvedBy;
  final bool isApproved;
  final String originWarehouse;
  final String destinationWarehouse;
  final String dispatchedBy;
  final String receivedBy;
  final String goodsReceivedNote;
  final String customApprovalStatus;

  MaterialRequest({
    required this.name,
    required this.requestedBy,
    required this.requestedOn,
    required this.status,
    required this.approvalStatus,
    required this.approvedBy,
    required this.isApproved,
    required this.originWarehouse,
    required this.destinationWarehouse,
    required this.dispatchedBy,
    required this.receivedBy,
    required this.goodsReceivedNote,
    required this.customApprovalStatus,
  });

  factory MaterialRequest.fromJson(Map<String, dynamic> json) {
    return MaterialRequest(
      name: json['name'] ?? '',
      requestedBy: json['requested_by'] ?? '',
      requestedOn: json['requested_on'] ?? '',
      status: json['status'] ?? '',
      approvalStatus: json['approval_status'] ?? '',
      approvedBy: json['approved_by'] ?? '',
      isApproved: json['is_approved'] ?? false,
      originWarehouse: json['origin_warehouse'] ?? '',
      destinationWarehouse: json['destination_warehouse'] ?? '',
      dispatchedBy: json['dispatched_by'] ?? '',
      receivedBy: json['received_by'] ?? '',
      goodsReceivedNote: json['goods_received_note'] ?? '',
      customApprovalStatus: json['custom_approval_status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'requested_by': requestedBy,
      'requested_on': requestedOn,
      'status': status,
      'approval_status': approvalStatus,
      'approved_by': approvedBy,
      'is_approved': isApproved,
      'origin_warehouse': originWarehouse,
      'destination_warehouse': destinationWarehouse,
      'dispatched_by': dispatchedBy,
      'received_by': receivedBy,
      'goods_received_note': goodsReceivedNote,
      'custom_approval_status': customApprovalStatus,
    };
  }
}