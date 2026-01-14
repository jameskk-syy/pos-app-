import 'package:pos/domain/requests/login.dart';
import 'package:pos/domain/responses/login_response.dart';

abstract class AuthenticateUserRepo {
  Future<LoginResponse> login(LoginRequest request);
}
