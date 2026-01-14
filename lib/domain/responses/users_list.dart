class StaffUsersResponse {
  final StaffUsersMessage message;

  StaffUsersResponse({required this.message});

  factory StaffUsersResponse.fromJson(Map<String, dynamic> json) {
    final messageJson = json['message'] as Map<String, dynamic>?;

    if (messageJson == null) {
      throw Exception('Message field is missing in response');
    }

    return StaffUsersResponse(message: StaffUsersMessage.fromJson(messageJson));
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class StaffUsersMessage {
  final List<StaffUser> staffUsers;
  final int count;
  final String company;

  StaffUsersMessage({
    required this.staffUsers,
    required this.count,
    required this.company,
  });

  factory StaffUsersMessage.fromJson(Map<String, dynamic> json) {
    return StaffUsersMessage(
      staffUsers:
          (json['staff_users'] as List<dynamic>?)
              ?.map((e) => StaffUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], // safe fallback to empty list
      count: json['count'] ?? 0,
      company: json['company'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_users': staffUsers.map((e) => e.toJson()).toList(),
      'count': count,
      'company': company,
    };
  }
}

class StaffUser {
  final String name;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final int enabled;
  final String creation;
  final String customCreatedBy;
  final String customCompany;
  final List<String> roles; // not nullable, default to empty
  final String industry;
  final String phone;

  StaffUser({
    required this.name,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.enabled,
    required this.creation,
    required this.customCreatedBy,
    required this.customCompany,
    required this.roles,
    required this.industry,
    required this.phone,
  });

  factory StaffUser.fromJson(Map<String, dynamic> json) {
    return StaffUser(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      enabled: json['enabled'] ?? 0,
      creation: json['creation'] ?? '',
      customCreatedBy: json['custom_created_by'] ?? '',
      customCompany: json['custom_company'] ?? '',
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [], // safe fallback if roles is missing
      industry: json['industry'] ?? '',
      phone: json['mobile_no'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'enabled': enabled,
      'creation': creation,
      'custom_created_by': customCreatedBy,
      'custom_company': customCompany,
      'roles': roles,
      'industry': industry,
      'mobile_no': phone,
    };
  }
}
