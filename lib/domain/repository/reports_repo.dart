import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/models/reports/accounting_reports_model.dart';
import 'package:pos/domain/models/reports/inventory_summary_model.dart';
import 'package:pos/domain/requests/report_request.dart';

abstract class ReportsRepo {
  Future<SalesAnalyticsResponse> getSalesAnalyticsReport(ReportRequest request);

  // Inventory Valuation
  Future<InventoryValueByCategoryResponse> getInventoryValueByCategoryReport(
    ReportRequest request,
  );
  Future<InventoryCostMethodResponse> getInventoryCostMethodComparisonReport(
    ReportRequest request,
  );
  Future<InventoryValueTrendsResponse> getInventoryValueTrendsReport(
    ReportRequest request,
  );

  // Stock Movement
  Future<InventoryTurnoverResponse> getInventoryTurnoverReport(
    ReportRequest request,
  );
  Future<InventoryDaysOnHandResponse> getInventoryDaysOnHandReport(
    ReportRequest request,
  );
  Future<InventoryMovementPatternsResponse> getInventoryMovementPatternsReport(
    ReportRequest request,
  );
  Future<InventoryTransferEfficiencyResponse>
  getInventoryTransferEfficiencyReport(ReportRequest request);

  // Aging Stock
  Future<AgingStockSummaryResponse> getAgingStockSummaryReport(
    ReportRequest request,
  );
  Future<AgingStockDetailsResponse> getAgingStockDetailsReport(
    ReportRequest request,
  );
  Future<InventoryExpiryResponse> getInventoryExpiryReport(
    ReportRequest request,
  );
  Future<InventoryObsolescenceRiskResponse> getInventoryObsolescenceRiskReport(
    ReportRequest request,
  );
  Future<InventoryAgingRecommendationResponse>
  getInventoryAgingRecommendationsReport(ReportRequest request);

  // Performance Metrics
  Future<InventoryAccuracyResponse> getInventoryAccuracyReport(
    ReportRequest request,
  );
  Future<InventoryVarianceResponse> getInventoryVarianceReport(
    ReportRequest request,
  );
  Future<InventoryAdjustmentTrendsResponse> getInventoryAdjustmentTrendsReport(
    ReportRequest request,
  );

  // Accounting Reports
  Future<ProfitAndLossResponse> getProfitAndLossReport(ReportRequest request);

  Future<InventorySummaryResponse> getInventorySummaryReport(
    ReportRequest request,
  );
}
