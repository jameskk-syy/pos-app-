import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/globals.dart';
import 'package:pos/screens/splash_screen.dart';

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
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          bool isAuthError = false;
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            isAuthError = true;
          } else if (e.response?.data is Map &&
              e.response?.data['exc_type'] == 'AuthenticationError') {
            isAuthError = true;
          }

          if (isAuthError) {
            try {
              final connectivity = getIt<ConnectivityService>();
              final isConnected = await connectivity.checkNow();

              if (isConnected) {
                final storage = getIt<StorageService>();
                await storage.remove('access_token');
                await storage.remove('current_user');

                final context = navigatorKey.currentContext;
                if (context != null && context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                }
              }
            } catch (_) {}
          }
          return handler.next(e);
        },
      ),
    );
  }

  bool _isAuthFreeEndpoint(String path) {
    return path.contains('login_user') || path.contains('login');
  }
}
