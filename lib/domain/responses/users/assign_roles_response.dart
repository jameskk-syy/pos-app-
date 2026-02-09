class AssignRolesResponse {
  final AssignedStaffUser staffUser;
  final String message;

  AssignRolesResponse({
    required this.staffUser,
    required this.message,
  });

  factory AssignRolesResponse.fromJson(Map<String, dynamic> json) {
    // Get the nested message object
    final messageData = json['message'] as Map<String, dynamic>?;
    
    if (messageData == null) {
      throw FormatException('Missing "message" field in response');
    }
    
    // Get staff_user from the nested message object
    final staffUserJson = messageData['staff_user'] as Map<String, dynamic>?;
    if (staffUserJson == null) {
      throw FormatException('Missing "staff_user" field in response');
    }
    
    // Get the success message from the nested message object
    final successMessage = messageData['message'] as String?;
    if (successMessage == null) {
      throw FormatException('Missing message string in response');
    }
    
    return AssignRolesResponse(
      staffUser: AssignedStaffUser.fromJson(staffUserJson),
      message: successMessage,
    );
  }
}

class AssignedStaffUser {
  final String name;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final List<String> roles;

  AssignedStaffUser({
    required this.name,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.roles,
  });

  factory AssignedStaffUser.fromJson(Map<String, dynamic> json) {
    return AssignedStaffUser(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}