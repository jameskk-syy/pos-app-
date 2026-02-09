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
  final InventoryValueByCategoryResponse categoryResponse;
  final InventoryCostMethodResponse costMethodResponse;
  final InventoryValueTrendsResponse trendsResponse;

  InventoryValueLoaded({
    required this.categoryResponse,
    required this.costMethodResponse,
    required this.trendsResponse,
  });
}

class StockMovementLoaded extends ReportsState {
  final InventoryTurnoverResponse turnoverResponse;
  final InventoryDaysOnHandResponse daysOnHandResponse;
  final InventoryMovementPatternsResponse patternResponse;
  final InventoryTransferEfficiencyResponse efficiencyResponse;

  StockMovementLoaded({
    required this.turnoverResponse,
    required this.daysOnHandResponse,
    required this.patternResponse,
    required this.efficiencyResponse,
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
  final InventoryObsolescenceRiskResponse riskResponse;
  final InventoryAgingRecommendationResponse recommendationResponse;

  AgingStockLoaded({
    required this.summaryResponse,
    required this.detailsResponse,
    required this.expiryResponse,
    required this.riskResponse,
    required this.recommendationResponse,
  });
}

class ProfitAndLossLoaded extends ReportsState {
  final ProfitAndLossResponse response;
  ProfitAndLossLoaded(this.response);
}

class InventorySummaryLoaded extends ReportsState {
  final InventorySummaryResponse response;
  InventorySummaryLoaded(this.response);
}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}
