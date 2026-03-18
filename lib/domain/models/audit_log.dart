class AuditLog {
  final String name;
  final String activityType;
  final String activityDescription;
  final String user;
  final String company;
  final String? referenceDoctype;
  final String? referenceName;
  final String status;
  final String? ipAddress;
  final String? userAgent;
  final double? executionTime;
  final String? errorMessage;
  final String creation;
  final String modified;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? requestData;
  final Map<String, dynamic>? responseData;

  AuditLog({
    required this.name,
    required this.activityType,
    required this.activityDescription,
    required this.user,
    required this.company,
    this.referenceDoctype,
    this.referenceName,
    required this.status,
    this.ipAddress,
    this.userAgent,
    this.executionTime,
    this.errorMessage,
    required this.creation,
    required this.modified,
    this.metadata,
    this.requestData,
    this.responseData,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      name: json['name'] ?? '',
      activityType: json['activity_type'] ?? '',
      activityDescription: json['activity_description'] ?? '',
      user: json['user'] ?? '',
      company: json['company'] ?? '',
      referenceDoctype: json['reference_doctype'],
      referenceName: json['reference_name'],
      status: json['status'] ?? '',
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      executionTime: (json['execution_time'] as num?)?.toDouble(),
      errorMessage: json['error_message'],
      creation: json['creation'] ?? '',
      modified: json['modified'] ?? '',
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata']
          : null,
      requestData: json['request_data'] is Map<String, dynamic>
          ? json['request_data']
          : null,
      responseData: json['response_data'] is Map<String, dynamic>
          ? json['response_data']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'activity_type': activityType,
      'activity_description': activityDescription,
      'user': user,
      'company': company,
      'reference_doctype': referenceDoctype,
      'reference_name': referenceName,
      'status': status,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'execution_time': executionTime,
      'error_message': errorMessage,
      'creation': creation,
      'modified': modified,
      'metadata': metadata,
      'request_data': requestData,
      'response_data': responseData,
    };
  }
}

class AuditLogResponse {
  final bool success;
  final List<AuditLog> data;
  final AuditPagination pagination;

  AuditLogResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory AuditLogResponse.fromJson(Map<String, dynamic> json) {
    final root = json['message'] ?? json;
    return AuditLogResponse(
      success: root['success'] ?? false,
      data:
          (root['data'] as List?)?.map((e) => AuditLog.fromJson(e)).toList() ??
          [],
      pagination: AuditPagination.fromJson(root['pagination'] ?? {}),
    );
  }
}

class AuditStatisticsResponse {
  final bool success;
  final AuditStatistics data;

  AuditStatisticsResponse({required this.success, required this.data});

  factory AuditStatisticsResponse.fromJson(Map<String, dynamic> json) {
    final root = json['message'] ?? json;
    return AuditStatisticsResponse(
      success: root['success'] ?? false,
      data: AuditStatistics.fromJson(root['data'] ?? {}),
    );
  }
}

class AuditStatistics {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byActivityType;
  final List<TopUser> topUsers;

  AuditStatistics({
    required this.total,
    required this.byStatus,
    required this.byActivityType,
    required this.topUsers,
  });

  factory AuditStatistics.fromJson(Map<String, dynamic> json) {
    return AuditStatistics(
      total: json['total'] ?? 0,
      byStatus: Map<String, int>.from(json['by_status'] ?? {}),
      byActivityType: Map<String, int>.from(json['by_activity_type'] ?? {}),
      topUsers:
          (json['top_users'] as List?)
              ?.map((e) => TopUser.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TopUser {
  final String user;
  final int count;

  TopUser({required this.user, required this.count});

  factory TopUser.fromJson(Map<String, dynamic> json) {
    return TopUser(user: json['user'] ?? '', count: json['count'] ?? 0);
  }
}

class AuditPagination {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  AuditPagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory AuditPagination.fromJson(Map<String, dynamic> json) {
    return AuditPagination(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
      hasPrevious: json['has_previous'] ?? false,
    );
  }
}
