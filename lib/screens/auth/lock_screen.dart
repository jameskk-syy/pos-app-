import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/screens/sales/dashboard.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/presentation/widgets/custom_text_field.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _storedPassword;

  @override
  void initState() {
    super.initState();
    _loadStoredPassword();
  }

  Future<void> _loadStoredPassword() async {
    final storage = getIt<StorageService>();
    _storedPassword = await storage.getEncryptedPassword();
    // Double check logic: if no password, we should probably logout,
    // but the main.dart logic handles the initial check.
    // This is just to have it ready for comparison.
  }

  Future<void> _unlock() async {
    if (_passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Simulate a small delay for better UX (prevent brute force speed)
    await Future.delayed(const Duration(milliseconds: 500));

    if (_passwordController.text == _storedPassword) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect password'),
            backgroundColor: Colors.red,
          ),
        );
        _passwordController.clear();
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final storage = getIt<StorageService>();
    await storage.remove('access_token');
    await storage.removeEncryptedPassword();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SvgPicture.asset("assets/svgs/maiLogo.svg", height: 80),
              const SizedBox(height: 40),
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your password to unlock",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _passwordController,
                label: "Password",
                hint: "Enter your password",
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _unlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Unlock",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _logout,
                child: const Text(
                  "Not you? Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
