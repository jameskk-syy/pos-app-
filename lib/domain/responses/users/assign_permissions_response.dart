class AssignPermissionsResponse {
  final bool success;
  final String message;
  final AssignedPermissionsData? data;

  AssignPermissionsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AssignPermissionsResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] is Map<String, dynamic>) {
      final messageData = json['message'];
      return AssignPermissionsResponse(
        success: messageData['success'] ?? false,
        message: messageData['message'] ?? '',
        data: messageData['data'] != null
            ? AssignedPermissionsData.fromJson(messageData['data'])
            : null,
      );
    }
    // Fallback if the structure is slightly different or direct
    return AssignPermissionsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AssignedPermissionsData.fromJson(json['data'])
          : null,
    );
  }
}

class AssignedPermissionsData {
  final String role;
  final String docType;
  final int permLevel;
  final int ifOwner;
  final Map<String, dynamic> permissions;

  AssignedPermissionsData({
    required this.role,
    required this.docType,
    required this.permLevel,
    required this.ifOwner,
    required this.permissions,
  });

  factory AssignedPermissionsData.fromJson(Map<String, dynamic> json) {
    return AssignedPermissionsData(
      role: json['role'] ?? '',
      docType: json['doctype'] ?? '',
      permLevel: json['permlevel'] ?? 0,
      ifOwner: json['if_owner'] ?? 0,
      permissions: json['permissions'] is Map<String, dynamic>
          ? json['permissions']
          : {},
    );
  }
}
