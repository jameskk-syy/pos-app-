import 'package:flutter/material.dart';
import 'package:pos/core/api.dart';
import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/requests/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Running Login Test... Check Console')))));

  debugPrint('--- INITIALIZING TEST ---');
  
  // Initialize ApiClient and Dio
  final apiClient = ApiClient();
  final dio = apiClient.dio;
  final remoteDataSource = RemoteDataSource(dio);

  final request = LoginRequest(
    email: "aary@techsavana.com",
    password: "SecurePass123",
  );

  debugPrint('Starting login request for: ${request.email}');
  
  try {
    final response = await remoteDataSource.login(request);
    
    debugPrint('\nLOGIN SUCCESSFUL $response');
  } catch (e) {
    debugPrint('\nLOGIN FAILED');
  }
}
