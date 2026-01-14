class RolePermissionsRequest {
  final String roleName;

  RolePermissionsRequest({required this.roleName});

  Map<String, dynamic> toJson() {
    return {'role_name': roleName};
  }
}
