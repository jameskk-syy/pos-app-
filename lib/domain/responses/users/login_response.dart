class LoginResponse {
  final LoginMessage message;

  LoginResponse({required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(message: LoginMessage.fromJson(json['message']));
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class LoginMessage {
  final User user;
  final String? apiKey;
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String expiresAt;
  final String refreshToken;
  final String message;

  LoginMessage({
    required this.user,
    this.apiKey,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.expiresAt,
    required this.refreshToken,
    required this.message,
  });

  factory LoginMessage.fromJson(Map<String, dynamic> json) {
    return LoginMessage(
      user: User.fromJson(json['user']),
      apiKey: json['api_key'],
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 0,
      expiresAt: json['expires_at'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'api_key': apiKey,
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expires_at': expiresAt,
      'refresh_token': refreshToken,
      'message': message,
    };
  }
}

class User {
  final String name;
  final String email;
  final String firstName;
  final String? lastName;
  final String fullName;

  User({
    required this.name,
    required this.email,
    required this.firstName,
    this.lastName,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      fullName: json['full_name'] ?? '',
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
