part of 'reports_bloc.dart';

@immutable
abstract class ReportsEvent {}

class FetchSalesAnalytics extends ReportsEvent {
  final ReportRequest request;
  FetchSalesAnalytics(this.request);
}

class FetchInventoryValue extends ReportsEvent {
  final ReportRequest request;
  FetchInventoryValue(this.request);
}

class FetchStockMovement extends ReportsEvent {
  final ReportRequest request;
  FetchStockMovement(this.request);
}

class FetchPerformanceMetrics extends ReportsEvent {
  final ReportRequest request;
  FetchPerformanceMetrics(this.request);
}

class FetchAgingStock extends ReportsEvent {
  final ReportRequest request;
  FetchAgingStock(this.request);
}
