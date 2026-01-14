part of 'reports_bloc.dart';

@immutable
abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class SalesAnalyticsLoaded extends ReportsState {
  final SalesAnalyticsResponse response;
  SalesAnalyticsLoaded(this.response);
}

class InventoryValueLoaded extends ReportsState {
  final InventoryValueByCategoryResponse response;
  InventoryValueLoaded(this.response);
}

class StockMovementLoaded extends ReportsState {
  final InventoryTurnoverResponse turnoverResponse;
  final InventoryDaysOnHandResponse daysOnHandResponse;

  StockMovementLoaded({
    required this.turnoverResponse,
    required this.daysOnHandResponse,
  });
}

class PerformanceMetricsLoaded extends ReportsState {
  final InventoryAccuracyResponse accuracyResponse;
  final InventoryVarianceResponse varianceResponse;
  final InventoryAdjustmentTrendsResponse trendsResponse;

  PerformanceMetricsLoaded({
    required this.accuracyResponse,
    required this.varianceResponse,
    required this.trendsResponse,
  });
}

class AgingStockLoaded extends ReportsState {
  final AgingStockSummaryResponse summaryResponse;
  final AgingStockDetailsResponse detailsResponse;
  final InventoryExpiryResponse expiryResponse;

  AgingStockLoaded({
    required this.summaryResponse,
    required this.detailsResponse,
    required this.expiryResponse,
  });
}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}
