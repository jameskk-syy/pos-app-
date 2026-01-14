part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}
class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {
}

class DashboardLoaded extends DashboardState {
  final DashboardResponse dashboardData;
  final DashboardRequest currentFilters;
  final bool isFromCache;

  DashboardLoaded({
    required this.dashboardData,
    required this.currentFilters,
    this.isFromCache = false,
  });
}

class DashboardError extends DashboardState {
  final String message;
  final DashboardRequest currentFilters;
  final DashboardResponse? cachedData; 

  DashboardError({
    required this.message,
    required this.currentFilters,
    this.cachedData,
  });
}

class DashboardCacheCleared extends DashboardState {}