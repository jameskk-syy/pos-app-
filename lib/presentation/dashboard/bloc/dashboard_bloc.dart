import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:pos/domain/repository/dashboard_repo.dart';
import 'package:pos/domain/requests/dashboard_request.dart';
import 'package:pos/domain/responses/dashboard_response.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepo dashboardRepo;
  DashboardResponse? _cachedData;
  DashboardRequest? _currentFilters;

  DashboardBloc({required this.dashboardRepo}) : super(DashboardInitial()) {
    on<FetchDashboardData>(_fetchDashboardData);
    on<RefreshDashboardData>(_refreshDashboardData);
    on<UpdateDashboardFilters>(_updateDashboardFilters);
    on<ClearDashboardFilters>(_clearDashboardFilters);
    on<LoadCachedDashboardData>(_loadCachedDashboardData);
    on<ClearCachedDashboardData>(_clearCachedDashboardData);
  }

  FutureOr<void> _fetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final response = await dashboardRepo.getDashboardStats(event.request);
      _cachedData = response;
      _currentFilters = event.request;
      emit(
        DashboardLoaded(
          dashboardData: response,
          currentFilters: event.request,
        ),
      );
    } catch (e) {
      debugPrint('Dashboard fetch error: ${e.toString()}');
      emit(
        DashboardError(
          message: e.toString(),
          currentFilters: event.request,
          cachedData: _cachedData,
        ),
      );
    }
  }

  FutureOr<void> _refreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // Use current filters or create default request
    final request = _currentFilters ?? DashboardRequest();
    
    try {
      final response = await dashboardRepo.getDashboardStats(request);
      _cachedData = response;
      emit(
        DashboardLoaded(
          dashboardData: response,
          currentFilters: request,
        ),
      );
    } catch (e) {
      debugPrint('Dashboard refresh error: ${e.toString()}');
      emit(
        DashboardError(
          message: e.toString(),
          currentFilters: request,
          cachedData: _cachedData,
        ),
      );
    }
  }

  FutureOr<void> _updateDashboardFilters(
    UpdateDashboardFilters event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final response = await dashboardRepo.getDashboardStats(event.newFilters);
      _cachedData = response;
      _currentFilters = event.newFilters;
      emit(
        DashboardLoaded(
          dashboardData: response,
          currentFilters: event.newFilters,
        ),
      );
    } catch (e) {
      debugPrint('Dashboard filter update error: ${e.toString()}');
      emit(
        DashboardError(
          message: e.toString(),
          currentFilters: event.newFilters,
          cachedData: _cachedData,
        ),
      );
    }
  }

  FutureOr<void> _clearDashboardFilters(
    ClearDashboardFilters event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final defaultRequest = DashboardRequest();
    
    try {
      final response = await dashboardRepo.getDashboardStats(defaultRequest);
      _cachedData = response;
      _currentFilters = defaultRequest;
      emit(
        DashboardLoaded(
          dashboardData: response,
          currentFilters: defaultRequest,
        ),
      );
    } catch (e) {
      debugPrint('Dashboard clear filters error: ${e.toString()}');
      emit(
        DashboardError(
          message: e.toString(),
          currentFilters: defaultRequest,
          cachedData: _cachedData,
        ),
      );
    }
  }

  FutureOr<void> _loadCachedDashboardData(
    LoadCachedDashboardData event,
    Emitter<DashboardState> emit,
  ) {
    if (_cachedData != null && _currentFilters != null) {
      emit(
        DashboardLoaded(
          dashboardData: _cachedData!,
          currentFilters: _currentFilters!,
          isFromCache: true,
        ),
      );
    } else {
      emit(DashboardInitial());
    }
  }

  FutureOr<void> _clearCachedDashboardData(
    ClearCachedDashboardData event,
    Emitter<DashboardState> emit,
  ) {
    _cachedData = null;
    _currentFilters = null;
    emit(DashboardCacheCleared());
  }
}