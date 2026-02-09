import 'package:pos/data/datasource/auth_remote_datasource.dart';
import 'package:pos/domain/models/message.dart';
import 'package:pos/domain/repository/register_user_repo.dart';
import 'package:pos/domain/requests/users/register_user.dart';

class UserRegisterRepoImpl implements RegisterRepository {
  final AuthRemoteDataSource remoteDataSource;

  UserRegisterRepoImpl({required this.remoteDataSource});

  @override
  Future<Message> registerUser(RegisterRequest registerRequest) async {
    return await remoteDataSource.registerUser(registerRequest);
  }
}
