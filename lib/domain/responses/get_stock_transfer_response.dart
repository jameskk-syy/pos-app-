class GetStockTransferResponse {
  final StockTransferMessage message;

  GetStockTransferResponse({
    required this.message,
  });

  factory GetStockTransferResponse.fromJson(Map<String, dynamic> json) {
    return GetStockTransferResponse(
      message: StockTransferMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class StockTransferMessage {
  final bool success;
  final String message;
  final StockTransferData data;

  StockTransferMessage({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StockTransferMessage.fromJson(Map<String, dynamic> json) {
    return StockTransferMessage(
      success: json['success'],
      message: json['message'],
      data: StockTransferData.fromJson(json['data']),
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

class StockTransferData {
  final String name;
  final String status;
  final String approvalStatus;
  final String approvedBy;
  final bool isApproved;
  final String requestedBy;
  final String requestedOn;
  final String originWarehouse;
  final String destinationWarehouse;
  final String dispatchedBy;
  final String receivedBy;
  final String goodsReceivedNote;
  final List<StockTransferItem> items;
  final String customApprovalStatus;

  StockTransferData({
    required this.name,
    required this.status,
    required this.approvalStatus,
    required this.approvedBy,
    required this.isApproved,
    required this.requestedBy,
    required this.requestedOn,
    required this.originWarehouse,
    required this.destinationWarehouse,
    required this.dispatchedBy,
    required this.receivedBy,
    required this.goodsReceivedNote,
    required this.items,
    required this.customApprovalStatus,
  });

  factory StockTransferData.fromJson(Map<String, dynamic> json) {
    return StockTransferData(
      name: json['name'],
      status: json['status'],
      approvalStatus: json['approval_status'],
      approvedBy: json['approved_by'] ?? "",
      isApproved: json['is_approved'],
      requestedBy: json['requested_by'],
      requestedOn: json['requested_on'],
      originWarehouse: json['origin_warehouse'],
      destinationWarehouse: json['destination_warehouse'],
      dispatchedBy: json['dispatched_by'] ?? "",
      receivedBy: json['received_by'] ?? "",
      goodsReceivedNote: json['goods_received_note'] ?? "",
      items: (json['items'] as List)
          .map((item) => StockTransferItem.fromJson(item))
          .toList(),
      customApprovalStatus: json['custom_approval_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'approval_status': approvalStatus,
      'approved_by': approvedBy,
      'is_approved': isApproved,
      'requested_by': requestedBy,
      'requested_on': requestedOn,
      'origin_warehouse': originWarehouse,
      'destination_warehouse': destinationWarehouse,
      'dispatched_by': dispatchedBy,
      'received_by': receivedBy,
      'goods_received_note': goodsReceivedNote,
      'items': items.map((item) => item.toJson()).toList(),
      'custom_approval_status': customApprovalStatus,
    };
  }
}

class StockTransferItem {
  final String itemCode;
  final double requestedQty;
  final double dispatchedQty;
  final double receivedQty;

  StockTransferItem({
    required this.itemCode,
    required this.requestedQty,
    required this.dispatchedQty,
    required this.receivedQty,
  });

  factory StockTransferItem.fromJson(Map<String, dynamic> json) {
    return StockTransferItem(
      itemCode: json['item_code'],
      requestedQty: json['requested_qty']?.toDouble() ?? 0.0,
      dispatchedQty: json['dispatched_qty']?.toDouble() ?? 0.0,
      receivedQty: json['received_qty']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'requested_qty': requestedQty,
      'dispatched_qty': dispatchedQty,
      'received_qty': receivedQty,
    };
  }
}