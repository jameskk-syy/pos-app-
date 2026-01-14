import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/authenticating_user_repo.dart';
import 'package:pos/domain/requests/login.dart';
import 'package:pos/domain/responses/login_response.dart';

class AuthenticateUserRepoImpl implements AuthenticateUserRepo {
  final RemoteDataSource remoteDataSource;

  AuthenticateUserRepoImpl({required this.remoteDataSource});
  @override
  Future<LoginResponse> login(LoginRequest request) async {
 return await remoteDataSource.login(request);
  }
}
