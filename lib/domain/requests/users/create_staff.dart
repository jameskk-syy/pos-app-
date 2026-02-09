// Staff User Request Class
class StaffUserRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String phone;
  final List<String> roles;
  final bool enabled;
  final bool sendWelcomeEmail;
  final String company;

  StaffUserRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.phone,
    required this.roles,
    this.enabled = true,
    this.sendWelcomeEmail = false,
    required this.company,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'phone': phone,
      'roles': roles,
      'enabled': enabled,
      'send_welcome_email': sendWelcomeEmail,
      'company': company,
    };
  }

  // Create from JSON (optional, for testing or caching)
  factory StaffUserRequest.fromJson(Map<String, dynamic> json) {
    return StaffUserRequest(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      password: json['password'],
      phone: json['phone'],
      roles: List<String>.from(json['roles']),
      enabled: json['enabled'] ?? true,
      sendWelcomeEmail: json['send_welcome_email'] ?? false,
      company: json['company'],
    );
  }

  // Create a copy with modified fields
  StaffUserRequest copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? password,
    String? phone,
    List<String>? roles,
    bool? enabled,
    bool? sendWelcomeEmail,
    String? company,
  }) {
    return StaffUserRequest(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      roles: roles ?? this.roles,
      enabled: enabled ?? this.enabled,
      sendWelcomeEmail: sendWelcomeEmail ?? this.sendWelcomeEmail,
      company: company ?? this.company,
    );
  }
}