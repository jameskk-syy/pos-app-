class UpdateStaffUserResponse {
  final StaffUserData staffUser;
  final String message;

  UpdateStaffUserResponse({
    required this.staffUser,
    required this.message,
  });

  factory UpdateStaffUserResponse.fromJson(Map<String, dynamic> json) {
    // First, get the nested message object
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
    
    return UpdateStaffUserResponse(
      staffUser: StaffUserData.fromJson(staffUserJson),
      message: successMessage,
    );
  }
}

class StaffUserData {
  final String name;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final int enabled;

  StaffUserData({
    required this.name,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.enabled,
  });

  factory StaffUserData.fromJson(Map<String, dynamic> json) {
    return StaffUserData(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      enabled: (json['enabled'] as int?) ?? 0,
    );
  }

  bool get isEnabled => enabled == 1;
}