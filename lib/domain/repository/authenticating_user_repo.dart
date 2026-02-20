import 'package:pos/domain/requests/users/login.dart';
import 'package:pos/domain/requests/users/send_otp_request.dart';
import 'package:pos/domain/responses/users/login_response.dart';
import 'package:pos/domain/responses/users/send_otp_response.dart';

abstract class AuthenticateUserRepo {
  Future<LoginResponse> login(LoginRequest request);
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Map<String, dynamic>> verifyEmailCode(String email, String code);
  Future<SendOtpResponse> sendOtpEmail(SendOtpRequest request);
}
