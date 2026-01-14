class CreateRoleResponse {
  final CreateRoleMessage message;

  CreateRoleResponse({required this.message});

  factory CreateRoleResponse.fromJson(Map<String, dynamic> json) {
    return CreateRoleResponse(
      message: CreateRoleMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class CreateRoleMessage {
  final bool success;
  final String message;
  final RoleData? data;

  CreateRoleMessage({required this.success, required this.message, this.data});

  factory CreateRoleMessage.fromJson(Map<String, dynamic> json) {
    return CreateRoleMessage(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? RoleData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class RoleData {
  final String name;
  final String roleName;
  final int deskAccess;
  final int twoFactorAuth;
  final int isCustom;
  final String? restrictToDomain;
  final String? homePage;
  final int disabled;

  RoleData({
    required this.name,
    required this.roleName,
    required this.deskAccess,
    required this.twoFactorAuth,
    required this.isCustom,
    this.restrictToDomain,
    this.homePage,
    required this.disabled,
  });

  factory RoleData.fromJson(Map<String, dynamic> json) {
    return RoleData(
      name: json['name'] as String? ?? '',
      roleName: json['role_name'] as String? ?? '',
      deskAccess: _toInt(json['desk_access']),
      twoFactorAuth: _toInt(json['two_factor_auth']),
      isCustom: _toInt(json['is_custom']),
      restrictToDomain: json['restrict_to_domain'] as String?,
      homePage: json['home_page'] as String?,
      disabled: _toInt(json['disabled']),
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
    return {
      'name': name,
      'role_name': roleName,
      'desk_access': deskAccess,
      'two_factor_auth': twoFactorAuth,
      'is_custom': isCustom,
      'restrict_to_domain': restrictToDomain,
      'home_page': homePage,
      'disabled': disabled,
    };
  }
}
