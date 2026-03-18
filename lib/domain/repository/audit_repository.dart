import 'package:pos/domain/models/audit_log.dart';

abstract class AuditRepository {
  Future<AuditLogResponse> getAuditLogs({
    String? company,
    String? activityType,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    int? page,
    int? pageSize,
    String? sortBy,
    String? sortOrder,
  });

  Future<AuditStatisticsResponse> getAuditStatistics({required String company});
}
