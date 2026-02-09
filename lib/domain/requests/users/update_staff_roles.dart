class AssignRolesRequest {
  final String userEmail;
  final List<String> roles;
  final bool replaceExisting;

  AssignRolesRequest({
    required this.userEmail,
    required this.roles,
    required this.replaceExisting,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_email': userEmail,
      'roles': roles,
      'replace_existing': replaceExisting,
    };
  }
}