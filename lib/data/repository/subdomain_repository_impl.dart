import 'package:pos/data/datasource/subdomain_remote_datasource.dart';
import 'package:pos/domain/models/subdomain_response.dart';
import 'package:pos/domain/repository/subdomain_repository.dart';

class SubdomainRepositoryImpl implements SubdomainRepository {
  final SubdomainRemoteDataSource remoteDataSource;

  SubdomainRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SubdomainResponse> validateSubdomain(String slug) async {
    return await remoteDataSource.validateSubdomain(slug);
  }
}
