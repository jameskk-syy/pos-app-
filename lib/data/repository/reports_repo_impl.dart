import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/repository/reports_repo.dart';
import 'package:pos/domain/requests/report_request.dart';

class ReportsRepoImpl implements ReportsRepo {
  final RemoteDataSource remoteDataSource;

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
}
