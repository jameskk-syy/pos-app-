import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/requests/report_request.dart';

abstract class ReportsRepo {
  Future<SalesAnalyticsResponse> getSalesAnalyticsReport(ReportRequest request);
  Future<InventoryValueByCategoryResponse> getInventoryValueByCategoryReport(
    ReportRequest request,
  );
  Future<InventoryTurnoverResponse> getInventoryTurnoverReport(
    ReportRequest request,
  );
  Future<InventoryDaysOnHandResponse> getInventoryDaysOnHandReport(
    ReportRequest request,
  );
  Future<InventoryAccuracyResponse> getInventoryAccuracyReport(
    ReportRequest request,
  );
  Future<InventoryVarianceResponse> getInventoryVarianceReport(
    ReportRequest request,
  );
  Future<InventoryAdjustmentTrendsResponse> getInventoryAdjustmentTrendsReport(
    ReportRequest request,
  );
  Future<AgingStockSummaryResponse> getAgingStockSummaryReport(
    ReportRequest request,
  );
  Future<AgingStockDetailsResponse> getAgingStockDetailsReport(
    ReportRequest request,
  );
  Future<InventoryExpiryResponse> getInventoryExpiryReport(
    ReportRequest request,
  );
}
