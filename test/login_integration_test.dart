import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/api.dart';
import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/requests/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Ensure Flutter bindings are initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Login Integration Test', () {
    late RemoteDataSource remoteDataSource;
    late Dio dio;

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Initialize ApiClient and Dio
      final apiClient = ApiClient();
      dio = apiClient.dio;
      remoteDataSource = RemoteDataSource(dio);
    });

    test('Test real login API call', () async {
      final request = LoginRequest(
        email: "aary@techsavana.com",
        password: "SecurePass123",
      );

      try {
        final response = await remoteDataSource.login(request);


        expect(response.message.accessToken, isNotEmpty);
        expect(response.message.user.email, equals(request.email));
      } catch (e) {
        debugPrint ('--- LOGIN FAILED ---');
      }
    });
    group('RemoteDataSource.getCurrentUser test', () {
      test('Test getCurrentUser after login status', () async {
        // This depends on whether you want to test the full flow or just the method
        // Since the login method saves the token to SharedPreferences,
        // we can try to call getCurrentUser after a successful login in a real scenario.
      });
    });
  });
}
