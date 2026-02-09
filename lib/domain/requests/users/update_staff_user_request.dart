class UpdateStaffUserRequest {
  final String userEmail;
  final String firstName;
  final String lastName;
  final String phone;
  final bool enabled;

  UpdateStaffUserRequest({
    required this.userEmail,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.enabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_email': userEmail,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'enabled': enabled,
    };
  }
}