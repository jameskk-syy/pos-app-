import 'package:dio/dio.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/models/subdomain_response.dart';
import 'package:pos/core/dependency.dart';

class SubdomainRemoteDataSource extends BaseRemoteDataSource {
  SubdomainRemoteDataSource(super.dio);

  Future<SubdomainResponse> validateSubdomain(String slug) async {
    try {
      final response = await dio.get(
        'https://api.saas.techsavanna.technology/api/v1/tenants/by-subdomain/$slug',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final subdomainResponse = SubdomainResponse.fromJson(data);
          final storage = getIt<StorageService>();
          if (subdomainResponse.siteUrl.isNotEmpty) {
            await storage.setString('base_url', subdomainResponse.siteUrl);
          }
          await storage.remove('access_token');

          return subdomainResponse;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
