import 'package:pos/data/datasource/reports_remote_datasource.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/inventory_summary_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/models/reports/accounting_reports_model.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/repository/reports_repo.dart';
import 'package:pos/domain/requests/report_request.dart';

class ReportsRepoImpl implements ReportsRepo {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepoImpl({required this.remoteDataSource});

  @override
  Future<SalesAnalyticsResponse> getSalesAnalyticsReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getSalesAnalyticsReport(request);
  }

  @override
  Future<InventoryValueByCategoryResponse> getInventoryValueByCategoryReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryValueByCategoryReport(request);
  }

  @override
  Future<InventoryTurnoverResponse> getInventoryTurnoverReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryTurnoverReport(request);
  }

  @override
  Future<InventoryDaysOnHandResponse> getInventoryDaysOnHandReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryDaysOnHandReport(request);
  }

  @override
  Future<InventoryAccuracyResponse> getInventoryAccuracyReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryAccuracyReport(request);
  }

  @override
  Future<InventoryVarianceResponse> getInventoryVarianceReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryVarianceReport(request);
  }

  @override
  Future<InventoryAdjustmentTrendsResponse> getInventoryAdjustmentTrendsReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryAdjustmentTrendsReport(request);
  }

  @override
  Future<AgingStockSummaryResponse> getAgingStockSummaryReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getAgingStockSummaryReport(request);
  }

  @override
  Future<AgingStockDetailsResponse> getAgingStockDetailsReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getAgingStockDetailsReport(request);
  }

  @override
  Future<InventoryExpiryResponse> getInventoryExpiryReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryExpiryReport(request);
  }

  @override
  Future<InventoryCostMethodResponse> getInventoryCostMethodComparisonReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryCostMethodComparisonReport(
      request,
    );
  }

  @override
  Future<InventoryValueTrendsResponse> getInventoryValueTrendsReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryValueTrendsReport(request);
  }

  @override
  Future<InventoryMovementPatternsResponse> getInventoryMovementPatternsReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryMovementPatternsReport(request);
  }

  @override
  Future<InventoryTransferEfficiencyResponse>
  getInventoryTransferEfficiencyReport(ReportRequest request) async {
    return await remoteDataSource.getInventoryTransferEfficiencyReport(request);
  }

  @override
  Future<InventoryObsolescenceRiskResponse> getInventoryObsolescenceRiskReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventoryObsolescenceRiskReport(request);
  }

  @override
  Future<InventoryAgingRecommendationResponse>
  getInventoryAgingRecommendationsReport(ReportRequest request) async {
    return await remoteDataSource.getInventoryAgingRecommendationsReport(
      request,
    );
  }

  @override
  Future<ProfitAndLossResponse> getProfitAndLossReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getProfitAndLossReport(request);
  }

  @override
  Future<InventorySummaryResponse> getInventorySummaryReport(
    ReportRequest request,
  ) async {
    return await remoteDataSource.getInventorySummaryReport(request);
  }
}
