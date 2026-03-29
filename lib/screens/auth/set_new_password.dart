import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/presentation/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:pos/screens/auth/confrimation.dart';
import 'package:pos/utils/themes/app_colors.dart';

class SetPasswordPage extends StatefulWidget {
  final String email;
  const SetPasswordPage({super.key, required this.email});

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
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
  void dispose() {
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => getIt<ForgotPasswordBloc>(),
      child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ConfirmationResetPage()),
              (route) => false,
            );
          } else if (state is ResetPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ResetPasswordLoading;
          final isFormValid = hasMinLength && hasUpper && hasLower && hasNumber && hasSpecial;

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
                          onChanged: (v) {
                            validatePassword(v);
                            setState(() {}); // Trigger rebuild for confirm check
                          },
                          decoration: InputDecoration(
                            hintText: "Keep it secure",
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                        if (passwordCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          if (!hasMinLength) _rule("Minimum 8 characters", false),
                          if (!hasUpper) _rule("1 uppercase letter (A–Z)", false),
                          if (!hasLower) _rule("1 lowercase letter (a–z)", false),
                          if (!hasNumber) _rule("1 number (0–9)", false),
                          if (!hasSpecial) _rule("1 special character (!@#\$%^&*)", false),
                        ],
                        const SizedBox(height: 14),
                        _label("Confirm Password"),
                        TextField(
                          controller: confirmPasswordCtrl,
                          obscureText: obscureConfirm,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: "Confirm your password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                        if (confirmPasswordCtrl.text.isNotEmpty && passwordCtrl.text != confirmPasswordCtrl.text) ...[
                          const SizedBox(height: 10),
                          _rule("Passwords do not match", false),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (isLoading || !isFormValid)
                                ? null
                                : () {
                                    if (passwordCtrl.text != confirmPasswordCtrl.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Passwords do not match")),
                                      );
                                      return;
                                    }
                                    context.read<ForgotPasswordBloc>().add(
                                          ResetPassword(
                                            email: widget.email,
                                            newPassword: passwordCtrl.text,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
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
        },
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
