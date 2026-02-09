import 'dart:convert';

class DispatchStockTransferRequest {
  final String requestId;
  final String originWarehouse;
  final List<DispatchItem> items;
  final String dispatchedBy;
  final String dispatchNotes;

  DispatchStockTransferRequest({
    required this.requestId,
    required this.originWarehouse,
    required this.items,
    required this.dispatchedBy,
    this.dispatchNotes = "",
  });

  factory DispatchStockTransferRequest.fromJson(Map<String, dynamic> json) {
    return DispatchStockTransferRequest(
      requestId: json['request_id'],
      originWarehouse: json['origin_warehouse'],
      items: (json['items'] as List)
          .map((item) => DispatchItem.fromJson(item))
          .toList(),
      dispatchedBy: json['dispatched_by'],
      dispatchNotes: json['dispatch_notes'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'origin_warehouse': originWarehouse,
      'items': items.map((item) => item.toJson()).toList(),
      'dispatched_by': dispatchedBy,
      'dispatch_notes': dispatchNotes,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}

class DispatchItem {
  final String itemCode;
  final double dispatchedQty;

  DispatchItem({
    required this.itemCode,
    required this.dispatchedQty,
  });

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    return DispatchItem(
      itemCode: json['item_code'],
      dispatchedQty: json['dispatched_qty'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'dispatched_qty': dispatchedQty,
    };
  }
}