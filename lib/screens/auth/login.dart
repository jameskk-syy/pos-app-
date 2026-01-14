import 'package:flutter/material.dart';
import 'package:pos/presentation/widgets/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/requests/login.dart';
import 'package:pos/presentation/loginBloc/bloc/login_bloc.dart';
import 'package:pos/screens/auth/register_user.dart';
import 'package:pos/screens/auth/reset_password.dart';
import 'package:pos/screens/dashboard.dart';
import 'package:pos/utils/themes/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool rememberMe = false;
  bool obscure = true;

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isTablet = _isTablet(context);
    final maxFormWidth = isTablet ? 500.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocProvider(
        create: (context) => getIt<LoginBloc>(),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginUserSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Login successful"),
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DashboardPage()),
              );
            } else if (state is LoginUserFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            final isLoading = state is LoginUserLoading;

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxFormWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: h * 0.06),

                        SvgPicture.asset(
                          "assets/svgs/maiLogo.svg",
                          height: isTablet ? 80 : 70,
                        ),

                        SizedBox(height: isTablet ? 32 : 24),

                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: isTablet ? 10 : 6),

                        Text(
                          "Log in to access\nTechsavanna POS",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.black54,
                          ),
                        ),

                        SizedBox(height: isTablet ? 40 : 32),

                        CustomTextField(
                          controller: emailCtrl,
                          label: "Username",
                          hint: "Input your username",
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            size: 20,
                          ),
                        ),

                        SizedBox(height: isTablet ? 20 : 16),

                        CustomTextField(
                          controller: passwordCtrl,
                          label: "Password",
                          hint: "Input your password",
                          obscureText: obscure,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => obscure = !obscure),
                            child: Icon(
                              obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                          ),
                        ),

                        SizedBox(height: isTablet ? 16 : 12),

                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (v) => setState(() => rememberMe = v!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Text(
                              "Remember Me",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: isTablet ? 15 : 14,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context2) => ResetPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: isTablet ? 15 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 28 : 20),

                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 56 : 52,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final loginRequest = LoginRequest(
                                      email: emailCtrl.text,
                                      password: passwordCtrl.text,
                                    );
                                    context.read<LoginBloc>().add(
                                      LoginUser(loginRequest: loginRequest),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: isTablet ? 26 : 24,
                                    height: isTablet ? 26 : 24,
                                    child: const CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: isTablet ? 36 : 28),

                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.black, height: 2),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                "or Login with",
                                style: TextStyle(fontSize: isTablet ? 15 : 14),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: AppColors.black, height: 2),
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 28 : 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialIcon(
                              "assets/svgs/google.svg",
                              isTablet: isTablet,
                            ),
                            SizedBox(width: isTablet ? 24 : 20),
                            _SocialIcon(
                              "assets/svgs/apple.svg",
                              isTablet: isTablet,
                            ),
                            SizedBox(width: isTablet ? 24 : 20),
                            _SocialIcon(
                              "assets/svgs/facebook.svg",
                              isTablet: isTablet,
                            ),
                          ],
                        ),

                        SizedBox(height: isTablet ? 36 : 28),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New here? ",
                              style: TextStyle(fontSize: isTablet ? 15 : 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 15 : 14,
                                ),
                              ),
                            ),
                            Text(
                              " to get started.",
                              style: TextStyle(fontSize: isTablet ? 15 : 14),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String asset;
  final bool isTablet;
  const _SocialIcon(this.asset, {this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final size = isTablet ? 52.0 : 46.0;
    final iconSize = isTablet ? 24.0 : 22.0;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Center(child: SvgPicture.asset(asset, height: iconSize)),
    );
  }
}
