import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/repository/reports_repo.dart';
import 'package:pos/domain/requests/report_request.dart';

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
  }

  Future<void> _onFetchSalesAnalytics(
    FetchSalesAnalytics event,
    Emitter<ReportsState> emit,
  ) async {
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
      final response = await reportsRepo.getInventoryValueByCategoryReport(
        event.request,
      );
      emit(InventoryValueLoaded(response));
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
      // Fetch both reports in parallel
      final results = await Future.wait([
        reportsRepo.getInventoryTurnoverReport(event.request),
        reportsRepo.getInventoryDaysOnHandReport(event.request),
      ]);

      emit(
        StockMovementLoaded(
          turnoverResponse: results[0] as InventoryTurnoverResponse,
          daysOnHandResponse: results[1] as InventoryDaysOnHandResponse,
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
      // Fetch 3 reports in parallel
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
      // Fetch 3 reports in parallel
      final results = await Future.wait([
        reportsRepo.getAgingStockSummaryReport(event.request),
        reportsRepo.getAgingStockDetailsReport(event.request),
        reportsRepo.getInventoryExpiryReport(event.request),
      ]);

      emit(
        AgingStockLoaded(
          summaryResponse: results[0] as AgingStockSummaryResponse,
          detailsResponse: results[1] as AgingStockDetailsResponse,
          expiryResponse: results[2] as InventoryExpiryResponse,
        ),
      );
    } catch (e) {
      debugPrint('ReportsBloc Error: $e');
      emit(ReportsError(e.toString()));
    }
  }
}
