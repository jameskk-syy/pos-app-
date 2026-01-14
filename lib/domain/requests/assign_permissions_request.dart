class AssignPermissionsRequest {
  final String roleName;
  final String docType;
  final String permissions; // JSON string
  final int permLevel;
  final int ifOwner;

  AssignPermissionsRequest({
    required this.roleName,
    required this.docType,
    required this.permissions,
    this.permLevel = 0,
    this.ifOwner = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'role_name': roleName,
      'doctype': docType,
      'permissions': permissions,
      'permlevel': permLevel,
      'if_owner': ifOwner,
    };
  }
}
