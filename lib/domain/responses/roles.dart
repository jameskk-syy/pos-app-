// role_response.dart

class RoleResponse {
  final MessageWrapper message;

  RoleResponse({required this.message});

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      message: MessageWrapper.fromJson(json['message'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class MessageWrapper {
  final bool success;
  final DataWrapper data;

  MessageWrapper({required this.success, required this.data});

  factory MessageWrapper.fromJson(Map<String, dynamic> json) {
    return MessageWrapper(
      success: json['success'] ?? false,
      data: DataWrapper.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class DataWrapper {
  final List<RoleData> roles;

  DataWrapper({required this.roles});

  factory DataWrapper.fromJson(Map<String, dynamic> json) {
    return DataWrapper(
      roles:
          (json['roles'] as List?)
              ?.where((role) => role != null)
              .map((role) => RoleData.fromJson(role as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {'roles': roles.map((role) => role.toJson()).toList()};
  }
}

class RoleData {
  final String name;
  final String roleName;
  final int disabled;
  final int isCustom;
  final int deskAccess;
  final int twoFactorAuth;
  final String? restrictToDomain;
  final String? homePage;
  final int userCount;
  final int? permissionCount;
  final List<String>? doctypesWithPermissions;
  final bool? isAutomatic;

  RoleData({
    required this.name,
    required this.roleName,
    required this.disabled,
    required this.isCustom,
    required this.deskAccess,
    required this.twoFactorAuth,
    this.restrictToDomain,
    this.homePage,
    required this.userCount,
    this.permissionCount,
    this.doctypesWithPermissions,
    this.isAutomatic,
  });

  factory RoleData.fromJson(Map<String, dynamic> json) {
    return RoleData(
      name: json['name'] as String? ?? '',
      roleName: json['role_name'] as String? ?? '',
      disabled: DataWrapper._toInt(json['disabled']),
      isCustom: DataWrapper._toInt(json['is_custom']),
      deskAccess: DataWrapper._toInt(json['desk_access']),
      twoFactorAuth: DataWrapper._toInt(json['two_factor_auth']),
      restrictToDomain: json['restrict_to_domain'] as String?,
      homePage: json['home_page'] as String?,
      userCount: DataWrapper._toInt(json['user_count']),
      permissionCount: json['permission_count'] != null
          ? DataWrapper._toInt(json['permission_count'])
          : null,
      doctypesWithPermissions: json['doctypes_with_permissions'] != null
          ? List<String>.from(json['doctypes_with_permissions'])
          : null,
      isAutomatic: json['is_automatic'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role_name': roleName,
      'disabled': disabled,
      'is_custom': isCustom,
      'desk_access': deskAccess,
      'two_factor_auth': twoFactorAuth,
      'restrict_to_domain': restrictToDomain,
      'home_page': homePage,
      'user_count': userCount,
      'permission_count': permissionCount,
      'doctypes_with_permissions': doctypesWithPermissions,
      'is_automatic': isAutomatic,
    };
  }

  bool get isDisabled => disabled == 1;
  bool get hasDeskAccess => deskAccess == 1;
  bool get requiresTwoFactor => twoFactorAuth == 1;
  bool get isCustomRole => isCustom == 1;
}

// For backwards compatibility - keeping the old structure
class RolesListResponse {
  final bool success;
  final List<RoleData> data;

  RolesListResponse({required this.success, required this.data});

  factory RolesListResponse.fromJson(Map<String, dynamic> json) {
    // Handle the nested structure: message.data.roles
    if (json.containsKey('message')) {
      final message = json['message'] as Map<String, dynamic>;
      final data = message['data'] as Map<String, dynamic>?;
      final rolesList = data?['roles'] as List?;

      return RolesListResponse(
        success: message['success'] ?? false,
        data:
            rolesList
                ?.map((role) => RoleData.fromJson(role as Map<String, dynamic>))
                .toList() ??
            [],
      );
    }

    // Fallback to old structure if message key doesn't exist
    return RolesListResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((role) => RoleData.fromJson(role as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'success': success,
        'data': {'roles': data.map((role) => role.toJson()).toList()},
      },
    };
  }
}
