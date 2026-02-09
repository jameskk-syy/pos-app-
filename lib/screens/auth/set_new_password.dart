import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/screens/auth/confrimation.dart';
import 'package:pos/utils/themes/app_colors.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key});

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController passwordCtrl = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;

  bool hasMinLength = false;
  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasSpecial = false;

  void validatePassword(String value) {
    setState(() {
      hasMinLength = value.length >= 8;
      hasUpper = value.contains(RegExp(r'[A-Z]'));
      hasLower = value.contains(RegExp(r'[a-z]'));
      hasNumber = value.contains(RegExp(r'[0-9]'));
      hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.orange, width: 1),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.orange,
              size: 28,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: h * 0.05),
                  SvgPicture.asset("assets/svgs/maiLogo.svg", height: 60),
                  const SizedBox(height: 24),
                  const Text(
                    "Set New Password",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Create a unique password",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  _label("New Password"),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: obscurePassword,
                    onChanged: validatePassword,
                    decoration: InputDecoration(
                      hintText: "Keep it secure",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      border: _border(),
                      enabledBorder: _border(),
                      focusedBorder: _border(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _rule("Minimum 8 characters", hasMinLength),
                  _rule("1 uppercase letter (A–Z)", hasUpper),
                  _rule("1 lowercase letter (a–z)", hasLower),
                  _rule("1 number (0–9)", hasNumber),
                  _rule("1 special character (!@#\$%^&*)", hasSpecial),
                  const SizedBox(height: 24),
                  _label("Confirm Password"),
                  TextField(
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      hintText: "Confirm your password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                      border: _border(),
                      enabledBorder: _border(),
                      focusedBorder: _border(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) => ConfirmationResetPage(),
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
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _rule(String text, bool valid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: valid ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: valid ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    );
  }
}
