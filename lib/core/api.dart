import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://savanna.nyikatech.com/api/method/",
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kIsWeb) {
      (dio.httpClientAdapter as dynamic).withCredentials = true;
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = getIt<StorageService>();
          final baseUrl = await storage.getString('base_url');

          if (baseUrl != null && baseUrl.isNotEmpty) {
            // Ensure trailing slash and correct path structure
            String newBase = baseUrl;
            if (!newBase.endsWith('/')) {
              newBase += '/';
            }
            if (!newBase.contains('/api/method/')) {
              newBase += 'api/method/';
            }

            options.baseUrl = newBase;
          }

          if (!_isAuthFreeEndpoint(options.path)) {
            final token = await storage.getString('access_token');

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },
      ),
    );
  }

  bool _isAuthFreeEndpoint(String path) {
    return path.contains('login_user') || path.contains('login');
  }
}
