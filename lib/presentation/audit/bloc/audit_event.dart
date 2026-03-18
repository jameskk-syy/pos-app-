part of 'audit_bloc.dart';

abstract class AuditEvent {}

class FetchAuditLogs extends AuditEvent {
  final bool isRefresh;
  final String? company;
  final String? activityType;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? search;

  FetchAuditLogs({
    this.isRefresh = false,
    this.company,
    this.activityType,
    this.status,
    this.startDate,
    this.endDate,
    this.search,
  });
}

class LoadMoreAuditLogs extends AuditEvent {}

class FetchAuditStatistics extends AuditEvent {
  final String company;
  FetchAuditStatistics({required this.company});
}
