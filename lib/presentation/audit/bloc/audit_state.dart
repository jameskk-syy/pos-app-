part of 'audit_bloc.dart';

abstract class AuditState {}

class AuditInitial extends AuditState {}

class AuditLoading extends AuditState {
  final bool isFirstFetch;
  AuditLoading({this.isFirstFetch = true});
}

class AuditLoaded extends AuditState {
  final List<AuditLog> logs;
  final bool hasNext;
  final int currentPage;
  final String? company;
  final String? activityType;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? search;
  final AuditStatistics? statistics;

  AuditLoaded({
    required this.logs,
    required this.hasNext,
    required this.currentPage,
    this.company,
    this.activityType,
    this.status,
    this.startDate,
    this.endDate,
    this.search,
    this.statistics,
  });
}

class AuditFailure extends AuditState {
  final String error;
  AuditFailure({required this.error});
}
