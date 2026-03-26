class ProductSalesAnalyticsResponse {
  final bool success;
  final List<ProductSalesItem> data;

  ProductSalesAnalyticsResponse({required this.success, required this.data});

  factory ProductSalesAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return ProductSalesAnalyticsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
              ?.map((e) => ProductSalesItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ProductSalesItem {
  final String itemCode;
  final String itemName;
  final String itemGroup;
  final double totalQty;
  final double totalRevenue;
  final double averagePrice;
  final int invoiceCount;

  ProductSalesItem({
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.totalQty,
    required this.totalRevenue,
    required this.averagePrice,
    required this.invoiceCount,
  });

  factory ProductSalesItem.fromJson(Map<String, dynamic> json) {
    return ProductSalesItem(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      itemGroup: json['item_group'] ?? '',
      totalQty: (json['total_qty'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0.0,
      invoiceCount: json['invoice_count'] ?? 0,
    );
  }
}
