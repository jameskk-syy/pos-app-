class RegisterRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String? businessName;
  final String password;
  final String phone;
  final bool sendWelcomeEmail;
  final String posIndustry;

  RegisterRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.phone,
    required this.sendWelcomeEmail,
    required this.posIndustry,
    this.businessName,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      password: json['password'],
      sendWelcomeEmail: json['send_welcome_email'],
      phone: json['phone'],
      posIndustry: json['pos_industry'],
      businessName: json['business_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'phone': phone.replaceAll('+', ''),
      'send_welcome_email': sendWelcomeEmail,
      'pos_industry': posIndustry,
    };
    if (businessName != null) {
      data['business_name'] = businessName;
    }
    return data;
  }
}
