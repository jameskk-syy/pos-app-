import 'package:pos/data/datasource/auth_remote_datasource.dart';
import 'package:pos/domain/repository/register_company_repo.dart';
import 'package:pos/domain/requests/users/register_company.dart';
import 'package:pos/domain/responses/users/register_company_response.dart';

class RegisterCompanyRepoImpl implements RegisterCompanyRepo {
  final AuthRemoteDataSource remoteDataSource;

  RegisterCompanyRepoImpl({required this.remoteDataSource});

  @override
  Future<CompanyResponse> registerCompany(CompanyRequest companyRequest) {
    return remoteDataSource.registerCompany(companyRequest);
  }
}
