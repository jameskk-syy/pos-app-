import 'purchase_invoice_response.dart';

class GrnListResponse {
  final bool success;
  final List<GrnData> data;
  final Meta meta;

  GrnListResponse({
    required this.success,
    required this.data,
    required this.meta,
  });

  factory GrnListResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    return GrnListResponse(
      success: message['success'] ?? false,
      data: (message['data'] as List<dynamic>)
          .map((e) => GrnData.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: Meta.fromJson(message['meta'] as Map<String, dynamic>),
    );
  }
}

class GrnData {
  final String name;
  final String supplier;
  final String supplierName;
  final String company;
  final String postingDate;
  final String postingTime;
  final String setWarehouse;
  final double grandTotal;
  final String status;
  final int docstatus;
  final int isReturn;
  final double perBilled;
  final double perReturned;
  final int itemsCount;
  final double totalQty;
  final double totalAmount;
  final String purchaseOrder;

  GrnData({
    required this.name,
    required this.supplier,
    required this.supplierName,
    required this.company,
    required this.postingDate,
    required this.postingTime,
    required this.setWarehouse,
    required this.grandTotal,
    required this.status,
    required this.docstatus,
    required this.isReturn,
    required this.perBilled,
    required this.perReturned,
    required this.itemsCount,
    required this.totalQty,
    required this.totalAmount,
    required this.purchaseOrder,
  });

  factory GrnData.fromJson(Map<String, dynamic> json) {
    return GrnData(
      name: json['name'] ?? '',
      supplier: json['supplier'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      company: json['company'] ?? '',
      postingDate: json['posting_date'] ?? '',
      postingTime: json['posting_time'] ?? '',
      setWarehouse: json['set_warehouse'] ?? '',
      grandTotal: (json['grand_total'] as num).toDouble(),
      status: json['status'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      isReturn: json['is_return'] ?? 0,
      perBilled: (json['per_billed'] as num).toDouble(),
      perReturned: (json['per_returned'] as num).toDouble(),
      itemsCount: json['items_count'] ?? 0,
      totalQty: (json['total_qty'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      purchaseOrder: json['purchase_order'] ?? '',
    );
  }
}
