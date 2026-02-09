class StaffUsersResponse {
  final MessageData message;

  StaffUsersResponse({required this.message});

  factory StaffUsersResponse.fromJson(Map<String, dynamic> json) {
    return StaffUsersResponse(
      message: MessageData.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

// Message Data Class
class MessageData {
  final List<StaffUser> staffUsers;
  final int count;
  final String company;

  MessageData({
    required this.staffUsers,
    required this.count,
    required this.company,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      staffUsers: (json['staff_users'] as List)
          .map((user) => StaffUser.fromJson(user))
          .toList(),
      count: json['count'],
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_users': staffUsers.map((user) => user.toJson()).toList(),
      'count': count,
      'company': company,
    };
  }
}

// Staff User Class
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
  final List<String> roles;
  final String industry;

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
  });

  factory StaffUser.fromJson(Map<String, dynamic> json) {
    return StaffUser(
      name: json['name'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      enabled: json['enabled'],
      creation: json['creation'],
      customCreatedBy: json['custom_created_by'],
      customCompany: json['custom_company'],
      roles: List<String>.from(json['roles']),
      industry: json['industry'],
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
    };
  }
}