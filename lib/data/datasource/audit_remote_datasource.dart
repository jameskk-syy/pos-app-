import 'package:dio/dio.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/models/audit_log.dart';

class AuditRemoteDataSource extends BaseRemoteDataSource {
  AuditRemoteDataSource(super.dio);

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
    try {
      final queryParams = <String, dynamic>{
        if (company != null && company.isNotEmpty) 'company': company,
        if (activityType != null) 'activity_type': activityType,
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page ?? 1,
        'page_size': pageSize ?? 20,
        'sort_by': sortBy ?? 'creation',
        'sort_order': sortOrder ?? 'DESC',
      };

      final response = await dio.get(
        'techsavanna_pos.api.audit_log_api.get_audit_logs',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return AuditLogResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load audit logs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuditStatisticsResponse> getAuditStatistics({
    required String company,
  }) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.audit_log_api.get_audit_log_statistics',
        queryParameters: {'company': company},
      );

      if (response.statusCode == 200) {
        return AuditStatisticsResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load audit statistics: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
