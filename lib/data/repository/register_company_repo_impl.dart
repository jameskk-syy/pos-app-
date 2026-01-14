import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/register_company_repo.dart';
import 'package:pos/domain/requests/register_company.dart';
import 'package:pos/domain/responses/register_company_response.dart';

class RegisterCompanyRepoImpl implements RegisterCompanyRepo {
  final RemoteDataSource remoteDataSource;

  RegisterCompanyRepoImpl({required this.remoteDataSource});

  @override
  Future<CompanyResponse> registerCompany(CompanyRequest companyRequest) {
    return remoteDataSource.registerCompany(companyRequest);
  }
}
