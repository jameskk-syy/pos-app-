// lib/domain/requests/create_grn_request.dart

class CreateGrnRequest {
  final String lpoNo;
  final String warehouse;
  final List<GrnItem> items;

  CreateGrnRequest({
    required this.lpoNo,
    required this.warehouse,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'lpo_no': lpoNo,
      'warehouse': warehouse,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory CreateGrnRequest.fromJson(Map<String, dynamic> json) {
    return CreateGrnRequest(
      lpoNo: json['lpo_no'] as String,
      warehouse: json['warehouse'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => GrnItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  CreateGrnRequest copyWith({
    String? lpoNo,
    String? warehouse,
    List<GrnItem>? items,
  }) {
    return CreateGrnRequest(
      lpoNo: lpoNo ?? this.lpoNo,
      warehouse: warehouse ?? this.warehouse,
      items: items ?? this.items,
    );
  }
}

class GrnItem {
  final String itemCode;
  final double qty;

  GrnItem({
    required this.itemCode,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
    };
  }

  factory GrnItem.fromJson(Map<String, dynamic> json) {
    return GrnItem(
      itemCode: json['item_code'] as String,
      qty: (json['qty'] as num).toDouble(),
    );
  }

  GrnItem copyWith({
    String? itemCode,
    double? qty,
  }) {
    return GrnItem(
      itemCode: itemCode ?? this.itemCode,
      qty: qty ?? this.qty,
    );
  }
}