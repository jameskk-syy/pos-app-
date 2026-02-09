import 'package:pos/data/datasource/auth_remote_datasource.dart';
import 'package:pos/domain/repository/pos_profile_repo.dart';
import 'package:pos/domain/requests/sales/create_pos_request.dart';
import 'package:pos/domain/responses/sales/pos_create_response.dart';

class PosProfileRepoImpl implements PosProfileRepo {
  final AuthRemoteDataSource remoteDataSource;

  PosProfileRepoImpl({required this.remoteDataSource});
  @override
  Future<CompanyProfileResponse> createPosProfile(
    CompanyProfileRequest posRequest,
  ) async {
    return await remoteDataSource.createPosProfile(posRequest);
  }
}
