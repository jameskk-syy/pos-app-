import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/inventory_summary_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/models/reports/accounting_reports_model.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/requests/report_request.dart';

class ReportsRemoteDataSource extends BaseRemoteDataSource {
  ReportsRemoteDataSource(super.dio);

  Future<SalesAnalyticsResponse> getSalesAnalyticsReport(
    ReportRequest request,
  ) async {
    return _getReport<SalesAnalyticsResponse>(
      'techsavanna_pos.api.reports.sales_analytics_report',
      request,
      SalesAnalyticsResponse.fromJson,
    );
  }

  Future<InventoryValueByCategoryResponse> getInventoryValueByCategoryReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryValueByCategoryResponse>(
      'techsavanna_pos.api.reports.inventory_value_by_category_report',
      request,
      InventoryValueByCategoryResponse.fromJson,
    );
  }

  Future<InventoryTurnoverResponse> getInventoryTurnoverReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryTurnoverResponse>(
      'techsavanna_pos.api.reports.inventory_turnover_report',
      request,
      InventoryTurnoverResponse.fromJson,
    );
  }

  Future<InventoryDaysOnHandResponse> getInventoryDaysOnHandReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryDaysOnHandResponse>(
      'techsavanna_pos.api.reports.inventory_days_on_hand_report',
      request,
      InventoryDaysOnHandResponse.fromJson,
    );
  }

  Future<InventoryAccuracyResponse> getInventoryAccuracyReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryAccuracyResponse>(
      'techsavanna_pos.api.reports.inventory_accuracy_report',
      request,
      InventoryAccuracyResponse.fromJson,
    );
  }

  Future<InventoryVarianceResponse> getInventoryVarianceReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryVarianceResponse>(
      'techsavanna_pos.api.reports.inventory_variance_report',
      request,
      InventoryVarianceResponse.fromJson,
    );
  }

  Future<InventoryAdjustmentTrendsResponse> getInventoryAdjustmentTrendsReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryAdjustmentTrendsResponse>(
      'techsavanna_pos.api.reports.inventory_adjustment_trends_report',
      request,
      InventoryAdjustmentTrendsResponse.fromJson,
    );
  }

  Future<AgingStockSummaryResponse> getAgingStockSummaryReport(
    ReportRequest request,
  ) async {
    return _getReport<AgingStockSummaryResponse>(
      'techsavanna_pos.api.reports.stock_aging_report',
      request,
      AgingStockSummaryResponse.fromJson,
    );
  }

  Future<AgingStockDetailsResponse> getAgingStockDetailsReport(
    ReportRequest request,
  ) async {
    return _getReport<AgingStockDetailsResponse>(
      'techsavanna_pos.api.reports.stock_aging_report',
      request,
      AgingStockDetailsResponse.fromJson,
    );
  }

  Future<InventoryExpiryResponse> getInventoryExpiryReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryExpiryResponse>(
      'techsavanna_pos.api.reports.inventory_expiry_report',
      request,
      InventoryExpiryResponse.fromJson,
    );
  }

  Future<InventoryCostMethodResponse> getInventoryCostMethodComparisonReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryCostMethodResponse>(
      'techsavanna_pos.api.reports.inventory_cost_method_comparison_report',
      request,
      InventoryCostMethodResponse.fromJson,
    );
  }

  Future<InventoryValueTrendsResponse> getInventoryValueTrendsReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryValueTrendsResponse>(
      'techsavanna_pos.api.reports.inventory_value_trends_report',
      request,
      InventoryValueTrendsResponse.fromJson,
    );
  }

  Future<InventoryMovementPatternsResponse> getInventoryMovementPatternsReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryMovementPatternsResponse>(
      'techsavanna_pos.api.reports.inventory_movement_patterns_report',
      request,
      InventoryMovementPatternsResponse.fromJson,
    );
  }

  Future<InventoryTransferEfficiencyResponse>
  getInventoryTransferEfficiencyReport(ReportRequest request) async {
    return _getReport<InventoryTransferEfficiencyResponse>(
      'techsavanna_pos.api.reports.inventory_transfer_efficiency_report',
      request,
      InventoryTransferEfficiencyResponse.fromJson,
    );
  }

  Future<InventoryObsolescenceRiskResponse> getInventoryObsolescenceRiskReport(
    ReportRequest request,
  ) async {
    return _getReport<InventoryObsolescenceRiskResponse>(
      'techsavanna_pos.api.reports.stock_aging_ report',
      request,
      InventoryObsolescenceRiskResponse.fromJson,
    );
  }

  Future<InventoryAgingRecommendationResponse>
  getInventoryAgingRecommendationsReport(ReportRequest request) async {
    return _getReport<InventoryAgingRecommendationResponse>(
      'techsavanna_pos.api.reports.stock_aging_report',
      request,
      InventoryAgingRecommendationResponse.fromJson,
    );
  }

  Future<ProfitAndLossResponse> getProfitAndLossReport(
    ReportRequest request,
  ) async {
    return _getReport<ProfitAndLossResponse>(
      'techsavanna_pos.api.reports.get_profit_and_loss',
      request,
      ProfitAndLossResponse.fromJson,
    );
  }

  Future<InventorySummaryResponse> getInventorySummaryReport(
    ReportRequest request,
  ) async {
    return _getReport<InventorySummaryResponse>(
      'techsavanna_pos.api.reports.inventory_summary_report',
      request,
      InventorySummaryResponse.fromJson,
    );
  }

  Future<T> _getReport<T>(
    String endpoint,
    ReportRequest request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await dio.post(endpoint, data: request.toJson());
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      // debugPrint(response.data.toString());

      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey('message') &&
            response.data['message'] is Map<String, dynamic>) {
          final message = response.data['message'] as Map<String, dynamic>;
          return fromJson(message);
        }
      }

      return fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {}
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }
}
