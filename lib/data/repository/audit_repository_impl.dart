import 'package:pos/data/datasource/audit_remote_datasource.dart';
import 'package:pos/domain/models/audit_log.dart';
import 'package:pos/domain/repository/audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource remoteDataSource;

  AuditRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    return await remoteDataSource.getAuditLogs(
      company: company,
      activityType: activityType,
      status: status,
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      pageSize: pageSize,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  @override
  Future<AuditStatisticsResponse> getAuditStatistics({
    required String company,
  }) {
    return remoteDataSource.getAuditStatistics(company: company);
  }
}
