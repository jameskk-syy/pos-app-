import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/utils/themes/app_colors.dart';

class ConfirmationResetPage extends StatefulWidget {
  const ConfirmationResetPage({super.key});

  @override
  State<ConfirmationResetPage> createState() => _ConfirmationResetPageState();
}

class _ConfirmationResetPageState extends State<ConfirmationResetPage> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: h * 0.1),
                  SvgPicture.asset('assets/svgs/maiLogo.svg', height: 60),
                  const SizedBox(height: 24),
                  const Text(
                    "Password Changed!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Easy-peasy. Your password has been\nreset successfully!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
