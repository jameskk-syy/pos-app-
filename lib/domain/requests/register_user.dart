class RegisterRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String businessName;
  final String password;
  final bool sendWelcomeEmail;
  final String posIndustry;

  RegisterRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.sendWelcomeEmail,
    required this.posIndustry, 
    required this.businessName,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      password: json['password'],
      sendWelcomeEmail: json['send_welcome_email'],
      posIndustry: json['pos_industry'],
      businessName: json['business_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'send_welcome_email': sendWelcomeEmail,
      'pos_industry': posIndustry,
      'business_name': businessName,
    };
  }
}
