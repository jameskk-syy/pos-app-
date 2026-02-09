class RolesResponse {
  final RolesMessageData message;

  RolesResponse({required this.message});

  factory RolesResponse.fromJson(Map<String, dynamic> json) {
    return RolesResponse(message: RolesMessageData.fromJson(json['message']));
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

// Message Data Class
class RolesMessageData {
  final List<Role> roles;
  final int count;

  RolesMessageData({required this.roles, required this.count});

  factory RolesMessageData.fromJson(Map<String, dynamic> json) {
    return RolesMessageData(
      roles: (json['roles'] as List)
          .map((role) => Role.fromJson(role))
          .toList(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roles': roles.map((role) => role.toJson()).toList(),
      'count': count,
    };
  }
}

// Role Class
class Role {
  final String name;
  final String label;

  Role({required this.name, required this.label});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(name: json['name'] ?? '', label: json['label'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'label': label};
  }

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Role && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
