class SalesAnalyticsResponse {
  final bool success;
  final SalesAnalyticsData data;

  SalesAnalyticsResponse({required this.success, required this.data});

  factory SalesAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return SalesAnalyticsResponse(
      success: json['success'] ?? false,
      data: SalesAnalyticsData.fromJson(json['data'] ?? {}),
    );
  }
}

class SalesAnalyticsData {
  final List<DailySales> dailySales;
  final List<RevenueByItemGroup> revenueByItemGroup;
  final SalesSummary summary;

  SalesAnalyticsData({
    required this.dailySales,
    required this.revenueByItemGroup,
    required this.summary,
  });

  factory SalesAnalyticsData.fromJson(Map<String, dynamic> json) {
    return SalesAnalyticsData(
      dailySales:
          (json['daily_sales'] as List?)
              ?.map((e) => DailySales.fromJson(e))
              .toList() ??
          [],
      revenueByItemGroup:
          (json['revenue_by_item_group'] as List?)
              ?.map((e) => RevenueByItemGroup.fromJson(e))
              .toList() ??
          [],
      summary: SalesSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class DailySales {
  final String date;
  final double totalAmount;
  final double totalQty;
  final int invoiceCount;
  final double averageOrderValue;

  DailySales({
    required this.date,
    required this.totalAmount,
    required this.totalQty,
    required this.invoiceCount,
    required this.averageOrderValue,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalQty: (json['total_qty'] as num?)?.toDouble() ?? 0.0,
      invoiceCount: (json['invoice_count'] as num?)?.toInt() ?? 0,
      averageOrderValue:
          (json['average_order_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RevenueByItemGroup {
  final String itemGroup;
  final double totalRevenue;
  final double totalQty;
  final int itemCount;
  final double percentage;

  RevenueByItemGroup({
    required this.itemGroup,
    required this.totalRevenue,
    required this.totalQty,
    required this.itemCount,
    required this.percentage,
  });

  factory RevenueByItemGroup.fromJson(Map<String, dynamic> json) {
    return RevenueByItemGroup(
      itemGroup: json['item_group'] ?? '',
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalQty: (json['total_qty'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SalesSummary {
  final double totalRevenue;
  final double totalQuantity;
  final int totalInvoices;
  final double averageOrderValue;

  SalesSummary({
    required this.totalRevenue,
    required this.totalQuantity,
    required this.totalInvoices,
    required this.averageOrderValue,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalQuantity: (json['total_quantity'] as num?)?.toDouble() ?? 0.0,
      totalInvoices: (json['total_invoices'] as num?)?.toInt() ?? 0,
      averageOrderValue:
          (json['average_order_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
