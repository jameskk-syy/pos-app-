import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/models/reports/accounting_reports_model.dart';
import 'package:pos/domain/repository/reports_repo.dart';
import 'package:pos/domain/requests/report_request.dart';

import 'package:pos/domain/models/reports/inventory_summary_model.dart';
part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepo reportsRepo;

  ReportsBloc({required this.reportsRepo}) : super(ReportsInitial()) {
    on<FetchSalesAnalytics>(_onFetchSalesAnalytics);
    on<FetchInventoryValue>(_onFetchInventoryValue);
    on<FetchStockMovement>(_onFetchStockMovement);
    on<FetchPerformanceMetrics>(_onFetchPerformanceMetrics);
    on<FetchAgingStock>(_onFetchAgingStock);
    on<FetchProfitAndLoss>(_onFetchProfitAndLoss);
    on<FetchInventorySummary>(_onFetchInventorySummary);
  }

  // ... existing handlers ...

  Future<void> _onFetchInventorySummary(
    FetchInventorySummary event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final response = await reportsRepo.getInventorySummaryReport(
        event.request,
      );
      emit(InventorySummaryLoaded(response));
    } catch (e) {
      debugPrint('ReportsBloc Error: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onFetchSalesAnalytics(
    FetchSalesAnalytics event,
    Emitter<ReportsState> emit,
  ) async {
    // ... rest of file
    debugPrint('ReportsBloc: Fetching sales analytics report ${event.request}');
    emit(ReportsLoading());
    try {
      final response = await reportsRepo.getSalesAnalyticsReport(event.request);
      emit(SalesAnalyticsLoaded(response));
    } catch (e) {
      debugPrint('ReportsBloc Error: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onFetchInventoryValue(
    FetchInventoryValue event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final results = await Future.wait([
        reportsRepo.getInventoryValueByCategoryReport(event.request),
        reportsRepo.getInventoryCostMethodComparisonReport(event.request),
        reportsRepo.getInventoryValueTrendsReport(event.request),
      ]);

      emit(
        InventoryValueLoaded(
          categoryResponse: results[0] as InventoryValueByCategoryResponse,
          costMethodResponse: results[1] as InventoryCostMethodResponse,
          trendsResponse: results[2] as InventoryValueTrendsResponse,
        ),
      );
    } catch (e) {
      debugPrint('ReportsBloc Error: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onFetchStockMovement(
    FetchStockMovement event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      var request = event.request;
      // Inject default dates if missing (backend requires them for some reports)
      if (request.startDate == null || request.endDate == null) {
        final now = DateTime.now();
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);

        String formatter(DateTime d) =>
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

        request = ReportRequest(
          company: request.company,
          startDate: request.startDate ?? formatter(firstDay),
          endDate: request.endDate ?? formatter(lastDay),
          warehouse: request.warehouse,
          itemGroup: request.itemGroup,
          periodDays: request.periodDays,
          analysisType: request.analysisType,
        );
      }

      final results = await Future.wait([
        reportsRepo.getInventoryTurnoverReport(request),
        reportsRepo.getInventoryDaysOnHandReport(request),
        reportsRepo.getInventoryMovementPatternsReport(request),
        reportsRepo.getInventoryTransferEfficiencyReport(request),
      ]);

      emit(
        StockMovementLoaded(
          turnoverResponse: results[0] as InventoryTurnoverResponse,
          daysOnHandResponse: results[1] as InventoryDaysOnHandResponse,
          patternResponse: results[2] as InventoryMovementPatternsResponse,
          efficiencyResponse: results[3] as InventoryTransferEfficiencyResponse,
        ),
      );
    } catch (e) {
      debugPrint('ReportsBloc Error: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onFetchPerformanceMetrics(
    FetchPerformanceMetrics event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final results = await Future.wait([
        reportsRepo.getInventoryAccuracyReport(event.request),
        reportsRepo.getInventoryVarianceReport(event.request),
        reportsRepo.getInventoryAdjustmentTrendsReport(event.request),
      ]);

      emit(
        PerformanceMetricsLoaded(
          accuracyResponse: results[0] as InventoryAccuracyResponse,
          varianceResponse: results[1] as InventoryVarianceResponse,
          trendsResponse: results[2] as InventoryAdjustmentTrendsResponse,
        ),
      );
    } catch (e) {
      debugPrint('ReportsBloc Error: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onFetchAgingStock(
    FetchAgingStock event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final summaryResult = await _safeReportCall(
        () => reportsRepo.getAgingStockSummaryReport(event.request),
        AgingStockSummaryResponse(success: false, data: []),
      );
      final detailsResult = await _safeReportCall(
        () => reportsRepo.getAgingStockDetailsReport(event.request),
        AgingStockDetailsResponse(success: false, data: {}),
      );
      final expiryResult = await _safeReportCall(
        () => reportsRepo.getInventoryExpiryReport(event.request),
        InventoryExpiryResponse(success: false, data: []),
      );
      final riskResult = await _safeReportCall(
        () => reportsRepo.getInventoryObsolescenceRiskReport(event.request),
        InventoryObsolescenceRiskResponse(success: false, data: []),
      );
      final recommendationResult = await _safeReportCall(
        () => reportsRepo.getInventoryAgingRecommendationsReport(event.request),
        InventoryAgingRecommendationResponse(success: false, data: []),
      );

      emit(
        AgingStockLoaded(
          summaryResponse: summaryResult,
          detailsResponse: detailsResult,
          expiryResponse: expiryResult,
          riskResponse: riskResult,
          recommendationResponse: recommendationResult,
        ),
      );
    } catch (e) {
      debugPrint('ReportsBloc Error: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<T> _safeReportCall<T>(Future<T> Function() call, T fallback) async {
    try {
      return await call();
    } catch (e) {
      debugPrint('SafeReportCall Error: $e');
      return fallback;
    }
  }

  Future<void> _onFetchProfitAndLoss(
    FetchProfitAndLoss event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      final response = await reportsRepo.getProfitAndLossReport(event.request);
      debugPrint(
        'Profit & Loss parsed: ${response.data.length} rows, ${response.columns.length} columns',
      );
      emit(ProfitAndLossLoaded(response));
    } catch (e) {
      debugPrint('ReportsBloc Error: $e');
      emit(ReportsError(e.toString()));
    }
  }
}
