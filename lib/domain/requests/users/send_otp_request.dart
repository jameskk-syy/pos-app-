class SendOtpRequest {
  final String email;
  final String purpose;

  SendOtpRequest({
    required this.email,
    this.purpose = 'verification',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'purpose': purpose,
    };
  }
}
