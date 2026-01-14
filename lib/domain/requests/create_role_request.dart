class CreateRoleRequest {
  final String? name; // For updates
  final String roleName;
  final int deskAccess;
  final int twoFactorAuth;
  final int isCustom;
  final String? restrictToDomain;
  final String? homePage;

  CreateRoleRequest({
    this.name,
    required this.roleName,
    required this.deskAccess,
    required this.twoFactorAuth,
    required this.isCustom,
    this.restrictToDomain,
    this.homePage,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      'role_name': roleName,
      'desk_access': deskAccess,
      'two_factor_auth': twoFactorAuth,
      'is_custom': isCustom,
      'custom': isCustom, // Added alias for compatibility
      if (restrictToDomain != null) 'restrict_to_domain': restrictToDomain,
      if (homePage != null) 'home_page': homePage,
    };
  }
}
