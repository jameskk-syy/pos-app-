import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/globals.dart';
import 'package:pos/core/services/security_service.dart';
import 'package:pos/utils/themes/app_colors.dart';

class SecurityWrapper extends StatefulWidget {
  final Widget child;
  const SecurityWrapper({super.key, required this.child});

  @override
  State<SecurityWrapper> createState() => _SecurityWrapperState();
}

class _SecurityWrapperState extends State<SecurityWrapper>
    with WidgetsBindingObserver {
  final _securityService = getIt<SecurityService>();
  Timer? _timer;
  bool _isDialogOpen = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startSecurityChecks();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _performCheck();
    }
  }

  void _startSecurityChecks() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _performCheck());
    _performCheck(); // Initial check
  }

  Future<void> _performCheck() async {
    if (_isDialogOpen || _isChecking) return;
    _isChecking = true;

    try {
      final isUnsafe = await _securityService.isEnvironmentUnsafe();
      if (isUnsafe && mounted) {
        await _showSecurityDialog();
      }
    } catch (e) {
      debugPrint("Security check error: $e");
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _showSecurityDialog() async {
    final targetContext = navigatorKey.currentContext;
    if (targetContext == null) {
      debugPrint("Security check: Navigator context not available yet.");
      return;
    }

    setState(() => _isDialogOpen = true);

    try {
      await showGeneralDialog(
        context: targetContext,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          final size = MediaQuery.of(context).size;
          final isTabletValue = size.shortestSide >= 600;
          final dialogWidth = isTabletValue ? 450.0 : size.width * 0.85;

          return PopScope(
            canPop: false, // Prevent back button
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dialogWidth,
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        color: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Text(
                              'Security Risk Detected',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'This application cannot run while Developer Options or USB Debugging is enabled. This is required to ensure the security of your POS data.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _securityService.openDeveloperSettings(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'DISABLE DEVELOPER OPTIONS',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () => _securityService.forceQuit(),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: const Text(
                                  'QUIT APPLICATION',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isDialogOpen = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
