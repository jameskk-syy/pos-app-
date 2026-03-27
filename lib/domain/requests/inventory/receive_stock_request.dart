class ReceiveStockRequest {
  final String requestId;
  final String sourceWarehouse;
  final String destinationWarehouse;
  final List<ReceiveStockItem> items;
  final String receivedBy;
  final String? receiveNotes;
  final String? goodsReceivedNote;

  ReceiveStockRequest({
    required this.requestId,
    required this.sourceWarehouse,
    required this.destinationWarehouse,
    required this.items,
    required this.receivedBy,
    this.receiveNotes,
    this.goodsReceivedNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'source_warehouse': sourceWarehouse,
      'destination_warehouse': destinationWarehouse,
      'items': items.map((item) => item.toJson()).toList(),
      'received_by': receivedBy,
      'receive_notes': receiveNotes ?? '',
      'goods_received_note': goodsReceivedNote ?? '',
    };
  }
}

class ReceiveStockItem {
  final String itemCode;
  final double receivedQty;
  final String sWarehouse;

  ReceiveStockItem({
    required this.itemCode,
    required this.receivedQty,
    required this.sWarehouse,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'received_qty': receivedQty,
      's_warehouse': sWarehouse,
    };
  }
}