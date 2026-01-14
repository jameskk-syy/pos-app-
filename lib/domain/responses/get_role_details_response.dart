import 'package:pos/domain/responses/roles.dart';

class GetRoleDetailsResponse {
  final bool success;
  final RoleData? data;

  GetRoleDetailsResponse({required this.success, this.data});

  factory GetRoleDetailsResponse.fromJson(Map<String, dynamic> json) {
    // Structure: {"message": {"success": true, "data": {...}}}
    if (json['message'] is Map<String, dynamic>) {
      final message = json['message'];
      return GetRoleDetailsResponse(
        success: message['success'] ?? false,
        data: message['data'] != null
            ? RoleData.fromJson(message['data'])
            : null,
      );
    }
    // Fallback
    return GetRoleDetailsResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? RoleData.fromJson(json['data']) : null,
    );
  }
}
