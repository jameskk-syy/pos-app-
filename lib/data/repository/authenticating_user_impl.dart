import 'package:pos/data/datasource/auth_remote_datasource.dart';
import 'package:pos/domain/repository/authenticating_user_repo.dart';
import 'package:pos/domain/requests/users/login.dart';
import 'package:pos/domain/responses/users/login_response.dart';

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
}
