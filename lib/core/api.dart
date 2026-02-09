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
          if (_isAuthFreeEndpoint(options.path)) {
            return handler.next(options);
          }

          final storage = getIt<StorageService>();
          final token = await storage.getString('access_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
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
