part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}

class FetchDashboardData extends DashboardEvent {
  final DashboardRequest request;

  FetchDashboardData(this.request);
}

class RefreshDashboardData extends DashboardEvent {}

class UpdateDashboardFilters extends DashboardEvent {
  final DashboardRequest newFilters;

  UpdateDashboardFilters(this.newFilters);
}

class ClearDashboardFilters extends DashboardEvent {}

class LoadCachedDashboardData extends DashboardEvent {}

class ClearCachedDashboardData extends DashboardEvent {}