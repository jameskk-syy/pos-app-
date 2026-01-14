import 'package:pos/domain/requests/register_company.dart';
import 'package:pos/domain/responses/register_company_response.dart';

abstract class RegisterCompanyRepo {
  Future<CompanyResponse> registerCompany(CompanyRequest companyRequest);
}
