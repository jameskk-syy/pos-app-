class User {
  final String name;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;

  User({
    required this.name,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
    };
  }
}
