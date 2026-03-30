import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/screens/auth/login.dart';

class WebViewSignUpScreen extends StatefulWidget {
  const WebViewSignUpScreen({super.key});

  @override
  State<WebViewSignUpScreen> createState() => _WebViewSignUpScreenState();
}

class _WebViewSignUpScreenState extends State<WebViewSignUpScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isPolling = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    final WebViewController controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..clearCache()
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            if (url.contains('/login')) {
              _navigateNext();
              return NavigationDecision.prevent;
            }
            if (url.contains('/dashboard') ||
                url.contains('/success') ||
                url.contains('.pos.saas.techsavanna.technology')) {
              _handleSuccess(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null && change.url!.contains('/login')) {
              _navigateNext();
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleSuccess(message.message);
        },
      )
      ..loadRequest(
        Uri.parse('https://savannapaypos.saas.techsavanna.technology/signup'),
      );

    _controller = controller;
  }

  void _handleSuccess(String data) async {
    if (_isPolling || _isNavigating) return;

    try {
      // If data is a URL, it might be a redirect to the new sub domain
      if (data.startsWith('http')) {
        final storage = getIt<StorageService>();
        await storage.remove('access_token');

        // Extract tenant URL if it's a saas sub domain
        if (data.contains('.pos.saas.techsavanna.technology')) {
          final uri = Uri.parse(data);
          final siteUrl = '${uri.scheme}://${uri.host}';
          await storage.setString('base_url', siteUrl);
        }
        
        _navigateNext();
        return;
      }

      final Map<String, dynamic> response = jsonDecode(data);
      final String? siteUrl = response['siteUrl'];
      final String? tenantId = response['tenantId'];

      if (tenantId != null && tenantId.isNotEmpty) {
        final storage = getIt<StorageService>();
        await storage.remove('access_token');

        if (siteUrl != null) {
          await storage.setString('base_url', siteUrl);
        }

        await _pollTenantStatus(tenantId);
      } else {
        _navigateNext();
      }
    } catch (e) {
      if (data.startsWith('http')) {
        _navigateNext();
      }
    }
  }

  Future<void> _pollTenantStatus(String tenantId) async {
    if (_isPolling) return;
    _isPolling = true;

    setState(() {
      _isLoading = true;
    });

    final dio = Dio();
    bool isProvisioned = false;

    while (!isProvisioned && mounted && !_isNavigating) {
      try {
        final response = await dio.get(
          'https://api.saas.techsavanna.technology/api/v1/tenants/$tenantId/status',
          options: Options(validateStatus: (status) => true),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          int progress = 0;

          try {
            final rawProgress = data['progressPercent'];
            if (rawProgress is int) {
              progress = rawProgress;
            } else if (rawProgress is double) {
              progress = rawProgress.toInt();
            } else if (rawProgress is String) {
              progress = int.tryParse(rawProgress) ?? 0;
            }
          } catch (e) {
            // Ignore error
          }

          if (progress >= 100) {
            isProvisioned = true;
            _isPolling = false;
            if (mounted) {
              _navigateNext();
            }
          } else {
            await Future.delayed(const Duration(seconds: 2));
          }
        } else {
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    _isPolling = false;
  }

  Future<void> _navigateNext() async {
    if (_isNavigating) return;
    _isNavigating = true;

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}