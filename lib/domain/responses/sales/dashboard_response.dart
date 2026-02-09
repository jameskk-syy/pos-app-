class DashboardResponse {
  final bool success;
  final DashboardData? data;
  final String? error;

  DashboardResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'error': error,
    };
  }
}
class DashboardData {
  final DashboardStats? stats;
  final List<DailySales>? salesLast30Days;
  final List<MonthlySales>? monthlySales;
  final List<SalesDue>? salesDue;
  final List<PurchasesDue>? purchasesDue;
  final List<StockAlert>? stockAlerts;
  final List<PendingShipment>? pendingShipments;
  final DashboardFilters? filters;

  DashboardData({
    this.stats,
    this.salesLast30Days,
    this.monthlySales,
    this.salesDue,
    this.purchasesDue,
    this.stockAlerts,
    this.pendingShipments,
    this.filters,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: json['stats'] != null 
          ? DashboardStats.fromJson(json['stats']) 
          : null,
      salesLast30Days: json['salesLast30Days'] != null
          ? (json['salesLast30Days'] as List)
              .map((e) => DailySales.fromJson(e))
              .toList()
          : null,
      monthlySales: json['monthlySales'] != null
          ? (json['monthlySales'] as List)
              .map((e) => MonthlySales.fromJson(e))
              .toList()
          : null,
      salesDue: json['salesDue'] != null
          ? (json['salesDue'] as List)
              .map((e) => SalesDue.fromJson(e))
              .toList()
          : null,
      purchasesDue: json['purchasesDue'] != null
          ? (json['purchasesDue'] as List)
              .map((e) => PurchasesDue.fromJson(e))
              .toList()
          : null,
      stockAlerts: json['stockAlerts'] != null
          ? (json['stockAlerts'] as List)
              .map((e) => StockAlert.fromJson(e))
              .toList()
          : null,
      pendingShipments: json['pendingShipments'] != null
          ? (json['pendingShipments'] as List)
              .map((e) => PendingShipment.fromJson(e))
              .toList()
          : null,
      filters: json['filters'] != null
          ? DashboardFilters.fromJson(json['filters'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats?.toJson(),
      'salesLast30Days': salesLast30Days?.map((e) => e.toJson()).toList(),
      'monthlySales': monthlySales?.map((e) => e.toJson()).toList(),
      'salesDue': salesDue?.map((e) => e.toJson()).toList(),
      'purchasesDue': purchasesDue?.map((e) => e.toJson()).toList(),
      'stockAlerts': stockAlerts?.map((e) => e.toJson()).toList(),
      'pendingShipments': pendingShipments?.map((e) => e.toJson()).toList(),
      'filters': filters?.toJson(),
    };
  }
}

// Dashboard Stats Model
class DashboardStats {
  final double? totalSales;
  final double? netSales;
  final double? salesReturns;
  final int? salesReturnsCount;
  final double? totalPurchases;
  final double? netPurchases;
  final double? purchaseReturns;
  final int? purchaseReturnsCount;
  final double? invoicesDue;
  final int? invoicesDueCount;
  final double? totalExpense;
  final double? profitMargin;
  final double? averageTransaction;

  DashboardStats({
    this.totalSales,
    this.netSales,
    this.salesReturns,
    this.salesReturnsCount,
    this.totalPurchases,
    this.netPurchases,
    this.purchaseReturns,
    this.purchaseReturnsCount,
    this.invoicesDue,
    this.invoicesDueCount,
    this.totalExpense,
    this.profitMargin,
    this.averageTransaction,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSales: json['totalSales']?.toDouble(),
      netSales: json['netSales']?.toDouble(),
      salesReturns: json['salesReturns']?.toDouble(),
      salesReturnsCount: json['salesReturnsCount'],
      totalPurchases: json['totalPurchases']?.toDouble(),
      netPurchases: json['netPurchases']?.toDouble(),
      purchaseReturns: json['purchaseReturns']?.toDouble(),
      purchaseReturnsCount: json['purchaseReturnsCount'],
      invoicesDue: json['invoicesDue']?.toDouble(),
      invoicesDueCount: json['invoicesDueCount'],
      totalExpense: json['totalExpense']?.toDouble(),
      profitMargin: json['profitMargin']?.toDouble(),
      averageTransaction: json['averageTransaction']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'netSales': netSales,
      'salesReturns': salesReturns,
      'salesReturnsCount': salesReturnsCount,
      'totalPurchases': totalPurchases,
      'netPurchases': netPurchases,
      'purchaseReturns': purchaseReturns,
      'purchaseReturnsCount': purchaseReturnsCount,
      'invoicesDue': invoicesDue,
      'invoicesDueCount': invoicesDueCount,
      'totalExpense': totalExpense,
      'profitMargin': profitMargin,
      'averageTransaction': averageTransaction,
    };
  }
}

// Daily Sales Model
class DailySales {
  final String? date;
  final double? sales;
  final double? returns;

  DailySales({
    this.date,
    this.sales,
    this.returns,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'],
      sales: json['sales']?.toDouble(),
      returns: json['returns']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sales': sales,
      'returns': returns,
    };
  }
}

// Monthly Sales Model
class MonthlySales {
  final String? month;
  final double? sales;
  final double? returns;
  final double? net;

  MonthlySales({
    this.month,
    this.sales,
    this.returns,
    this.net,
  });

  factory MonthlySales.fromJson(Map<String, dynamic> json) {
    return MonthlySales(
      month: json['month'],
      sales: json['sales']?.toDouble(),
      returns: json['returns']?.toDouble(),
      net: json['net']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'sales': sales,
      'returns': returns,
      'net': net,
    };
  }
}

// Sales Due Model
class SalesDue {
  final String? id;
  final String? customer;
  final double? amount;
  final String? dueDate;
  final String? status;

  SalesDue({
    this.id,
    this.customer,
    this.amount,
    this.dueDate,
    this.status,
  });

  factory SalesDue.fromJson(Map<String, dynamic> json) {
    return SalesDue(
      id: json['id'],
      customer: json['customer'],
      amount: json['amount']?.toDouble(),
      dueDate: json['dueDate'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'amount': amount,
      'dueDate': dueDate,
      'status': status,
    };
  }
}

// Purchases Due Model
class PurchasesDue {
  final String? id;
  final String? supplier;
  final double? amount;
  final String? dueDate;
  final String? status;

  PurchasesDue({
    this.id,
    this.supplier,
    this.amount,
    this.dueDate,
    this.status,
  });

  factory PurchasesDue.fromJson(Map<String, dynamic> json) {
    return PurchasesDue(
      id: json['id'],
      supplier: json['supplier'],
      amount: json['amount']?.toDouble(),
      dueDate: json['dueDate'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier': supplier,
      'amount': amount,
      'dueDate': dueDate,
      'status': status,
    };
  }
}

// Stock Alert Model
class StockAlert {
  final String? id;
  final String? product;
  final double? currentStock;
  final double? minStock;
  final String? status;

  StockAlert({
    this.id,
    this.product,
    this.currentStock,
    this.minStock,
    this.status,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      id: json['id'],
      product: json['product'],
      currentStock: json['currentStock']?.toDouble(),
      minStock: json['minStock']?.toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'currentStock': currentStock,
      'minStock': minStock,
      'status': status,
    };
  }
}

// Pending Shipment Model
class PendingShipment {
  final String? id;
  final String? orderId;
  final String? customer;
  final int? items;
  final String? status;
  final String? estDelivery;

  PendingShipment({
    this.id,
    this.orderId,
    this.customer,
    this.items,
    this.status,
    this.estDelivery,
  });

  factory PendingShipment.fromJson(Map<String, dynamic> json) {
    return PendingShipment(
      id: json['id'],
      orderId: json['orderId'],
      customer: json['customer'],
      items: json['items'],
      status: json['status'],
      estDelivery: json['estDelivery'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'customer': customer,
      'items': items,
      'status': status,
      'estDelivery': estDelivery,
    };
  }
}

// Dashboard Filters Model
class DashboardFilters {
  final String? company;
  final String? warehouse;
  final String? staff;
  final String? fromDate;
  final String? toDate;
  final String? period;

  DashboardFilters({
    this.company,
    this.warehouse,
    this.staff,
    this.fromDate,
    this.toDate,
    this.period,
  });

  factory DashboardFilters.fromJson(Map<String, dynamic> json) {
    return DashboardFilters(
      company: json['company'],
      warehouse: json['warehouse'],
      staff: json['staff'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
      period: json['period'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'warehouse': warehouse,
      'staff': staff,
      'from_date': fromDate,
      'to_date': toDate,
      'period': period,
    };
  }
}
