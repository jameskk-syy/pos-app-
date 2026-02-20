import 'package:pos/domain/models/subdomain_response.dart';

abstract class SubdomainRepository {
  Future<SubdomainResponse> validateSubdomain(String slug);
}
