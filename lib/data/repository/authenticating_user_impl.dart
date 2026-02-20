import 'package:pos/data/datasource/auth_remote_datasource.dart';
import 'package:pos/domain/repository/authenticating_user_repo.dart';
import 'package:pos/domain/requests/users/login.dart';
import 'package:pos/domain/requests/users/send_otp_request.dart';
import 'package:pos/domain/responses/users/login_response.dart';
import 'package:pos/domain/responses/users/send_otp_response.dart';

class AuthenticateUserRepoImpl implements AuthenticateUserRepo {
  final AuthRemoteDataSource remoteDataSource;

  AuthenticateUserRepoImpl({required this.remoteDataSource});
  @override
  Future<LoginResponse> login(LoginRequest request) async {
    return await remoteDataSource.login(request);
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await remoteDataSource.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<Map<String, dynamic>> verifyEmailCode(
    String email,
    String code,
  ) async {
    return await remoteDataSource.verifyEmailCode(email, code);
  }

  @override
  Future<SendOtpResponse> sendOtpEmail(SendOtpRequest request) async {
    return await remoteDataSource.sendOtpEmail(request);
  }
}
