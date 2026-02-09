import 'package:pos/domain/requests/users/login.dart';
import 'package:pos/domain/responses/users/login_response.dart';

abstract class AuthenticateUserRepo {
  Future<LoginResponse> login(LoginRequest request);
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
