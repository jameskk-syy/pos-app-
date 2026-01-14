import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/requests/register_user.dart';
import 'package:pos/domain/responses/industries_list_response.dart';
import 'package:pos/presentation/industries/bloc/industries_bloc.dart';
import 'package:pos/presentation/registerBloc/bloc/register_bloc.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/screens/auth/register_company_details.dart';
import 'package:pos/utils/themes/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool obscure = true;
  String password = "";
  bool acceptedTerms = false;
  String? selectedIndustry;
  String? selectedIndustryCode;

  @override
  void initState() {
    super.initState();
    context.read<IndustriesBloc>().add(GetIndustriesList());
  }

  bool get showRules => password.isNotEmpty;
  bool get hasMinLength => password.length >= 8;
  bool get hasUpperLower =>
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecial => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final isTablet = _isTablet(context);
    final maxFormWidth = isTablet ? 600.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (_) => getIt<RegisterBloc>(),
        child: BlocBuilder<IndustriesBloc, IndustriesState>(
          builder: (context, industriesState) {
            return BlocConsumer<RegisterBloc, RegisterState>(
              listener: (context, state) {
                if (state is RegisterFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                if (state is RegisterSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  final request = RegisterRequest(
                    email: emailController.text.trim(),
                    firstName: firstNameController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    password: passwordController.text.trim(),
                    sendWelcomeEmail: true,
                    posIndustry: selectedIndustryCode ?? "RETAIL",
                    businessName: "",
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RegisterCompanyDetails(registerRequest: request),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is RegisterLoading;
                final industriesLoading = industriesState is IndustriesLoading;
                final industriesList = industriesState is IndustriesSuccess
                    ? industriesState.message.message.industries
                    : <Industry>[];

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
                            SizedBox(height: isTablet ? h * 0.05 : h * 0.04),
                            Text(
                              "Create Your Account",
                              style: TextStyle(
                                fontSize: isTablet ? 32 : 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: isTablet ? 10 : 6),
                            Text(
                              "Start using Techsavanna POS\nfor your organization.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: isTablet ? 40 : 32),

                            /// FIRST & LAST NAME (2 INPUTS PER ROW)
                            _InputLabel("Your Name", isTablet: isTablet),
                            Row(
                              children: [
                                Expanded(
                                  child: _InputField(
                                    controller: firstNameController,
                                    hint: "First name",
                                    isTablet: isTablet,
                                  ),
                                ),
                                SizedBox(width: isTablet ? 16 : 12),
                                Expanded(
                                  child: _InputField(
                                    controller: lastNameController,
                                    hint: "Last name",
                                    isTablet: isTablet,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isTablet ? 20 : 16),

                            /// EMAIL & PHONE (2 INPUTS PER ROW)
                            _InputLabel("Contact Details", isTablet: isTablet),
                            Row(
                              children: [
                                Expanded(
                                  child: _InputField(
                                    controller: emailController,
                                    hint: "Email address",
                                    isTablet: isTablet,
                                  ),
                                ),
                                SizedBox(width: isTablet ? 16 : 12),
                                Expanded(
                                  child: _InputField(
                                    controller: phoneController,
                                    hint: "Phone number",
                                    isTablet: isTablet,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isTablet ? 20 : 16),

                            /// INDUSTRY TYPE (Moved above Password)
                            _InputLabel("Industry Type", isTablet: isTablet),
                            industriesLoading
                                ? const Center(child: LinearProgressIndicator())
                                : _DropdownField(
                                    hint: "Select your industry",
                                    value: selectedIndustryCode,
                                    items: [
                                      const DropdownMenuItem(
                                        value: "NONE",
                                        child: Text("None"),
                                      ),
                                      ...industriesList.map(
                                        (e) => DropdownMenuItem(
                                          value: e.industryCode,
                                          child: Text(e.industryName),
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      setState(() => selectedIndustryCode = v);
                                    },
                                    isTablet: isTablet,
                                  ),

                            SizedBox(height: isTablet ? 20 : 16),

                            /// PASSWORD
                            _InputLabel("Password", isTablet: isTablet),
                            TextField(
                              controller: passwordController,
                              obscureText: obscure,
                              onChanged: (v) => setState(() => password = v),
                              style: TextStyle(fontSize: isTablet ? 16 : 14),
                              decoration: InputDecoration(
                                hintText: "Keep it secure",
                                hintStyle: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 18 : 16,
                                  vertical: isTablet ? 16 : 14,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () =>
                                      setState(() => obscure = !obscure),
                                  child: Icon(
                                    obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: isTablet ? 22 : 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            if (showRules) ...[
                              SizedBox(height: isTablet ? 14 : 10),
                              _PasswordRule(
                                "Minimum 8 characters",
                                hasMinLength,
                                isTablet: isTablet,
                              ),
                              _PasswordRule(
                                "Uppercase & lowercase letters",
                                hasUpperLower,
                                isTablet: isTablet,
                              ),
                              _PasswordRule(
                                "At least 1 number",
                                hasNumber,
                                isTablet: isTablet,
                              ),
                              _PasswordRule(
                                "At least 1 special character",
                                hasSpecial,
                                isTablet: isTablet,
                              ),
                            ],

                            SizedBox(height: isTablet ? 24 : 20),

                            /// CONFIRM PASSWORD
                            _InputLabel("Confirm Password", isTablet: isTablet),
                            _InputField(
                              controller: confirmController,
                              hint: "Re-enter password",
                              isTablet: isTablet,
                            ),

                            SizedBox(height: isTablet ? 24 : 20),

                            /// TERMS & CONDITIONS CHECKBOX
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: isTablet ? 22 : 20,
                                  width: isTablet ? 22 : 20,
                                  child: Checkbox(
                                    value: acceptedTerms,
                                    onChanged: (value) {
                                      setState(
                                        () => acceptedTerms = value ?? false,
                                      );
                                    },
                                    activeColor: AppColors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                SizedBox(width: isTablet ? 12 : 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(
                                        () => acceptedTerms = !acceptedTerms,
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: isTablet ? 15 : 14,
                                          color: Colors.black87,
                                        ),
                                        children: const [
                                          TextSpan(text: "I agree to the "),
                                          TextSpan(
                                            text: "Terms & Conditions",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(text: " and "),
                                          TextSpan(
                                            text: "Privacy Policy",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isTablet ? 36 : 28),

                            /// SUBMIT BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: isTablet ? 56 : 52,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (!acceptedTerms) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please accept the Terms & Conditions',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        if (selectedIndustryCode == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please select an industry Type',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        final password = passwordController.text
                                            .trim();
                                        final confirmPassword =
                                            confirmController.text.trim();
                                        if (password != confirmPassword) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Passwords do not match',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        if (password.isEmpty ||
                                            confirmPassword.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Password fields cannot be empty',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        final request = RegisterRequest(
                                          email: emailController.text.trim(),
                                          firstName: firstNameController.text
                                              .trim(),
                                          lastName: lastNameController.text
                                              .trim(),
                                          password: passwordController.text
                                              .trim(),
                                          sendWelcomeEmail: true,
                                          posIndustry: selectedIndustryCode!,
                                          businessName: "",
                                        );

                                        context.read<RegisterBloc>().add(
                                          RegisterUser(
                                            registerRequest: request,
                                            businessName: "",
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
                                    ? SizedBox(
                                        height: isTablet ? 24 : 22,
                                        width: isTablet ? 24 : 22,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Continue",
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(height: isTablet ? 36 : 28),

                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SignInScreen(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(
                                      fontSize: isTablet ? 15 : 14,
                                    ),
                                  ),
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isTablet ? 15 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  const _InputLabel(this.text, {this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool isTablet;
  const _InputField({
    required this.hint,
    this.controller,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: isTablet ? 16 : 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 16,
          vertical: isTablet ? 16 : 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _PasswordRule extends StatelessWidget {
  final String text;
  final bool valid;
  final bool isTablet;
  const _PasswordRule(this.text, this.valid, {this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.circle_outlined,
            size: isTablet ? 18 : 16,
            color: valid ? Colors.green : Colors.grey,
          ),
          SizedBox(width: isTablet ? 10 : 8),
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 15 : 13,
              color: valid ? Colors.green : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final bool isTablet;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      items: items,
      style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 16,
          vertical: isTablet ? 16 : 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
