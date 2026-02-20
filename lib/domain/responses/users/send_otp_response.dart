class SendOtpResponse {
  final bool success;
  final String message;
  final int? expiresInMinutes;
  final String? email;
  final String? error;
  final String? errorType;

  SendOtpResponse({
    required this.success,
    required this.message,
    this.expiresInMinutes,
    this.email,
    this.error,
    this.errorType,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    // Check if the response is nested under 'message' key (Frappe style)
    if (json.containsKey('message') && json['message'] is Map<String, dynamic>) {
      return SendOtpResponse.fromJson(json['message'] as Map<String, dynamic>);
    }

    return SendOtpResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      expiresInMinutes: json['expires_in_minutes'] is int
          ? json['expires_in_minutes'] as int
          : int.tryParse(json['expires_in_minutes']?.toString() ?? ''),
      email: json['email']?.toString(),
      error: json['error']?.toString(),
      errorType: json['error_type']?.toString(),
    );
  }
}
