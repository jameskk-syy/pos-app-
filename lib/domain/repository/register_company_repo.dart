import 'package:pos/domain/requests/users/register_company.dart';
import 'package:pos/domain/responses/users/register_company_response.dart';

abstract class RegisterCompanyRepo {
  Future<CompanyResponse> registerCompany(CompanyRequest companyRequest);
}
