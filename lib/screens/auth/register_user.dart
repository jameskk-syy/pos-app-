import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/requests/users/register_user.dart';
import 'package:pos/domain/responses/industries_list_response.dart';
import 'package:pos/presentation/industries/bloc/industries_bloc.dart';
import 'package:pos/presentation/registerBloc/bloc/register_bloc.dart';
import 'package:pos/screens/auth/login.dart';
import 'package:pos/screens/auth/register_company_details.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool acceptedTerms = false;
  String? selectedIndustryCode;
  PhoneNumber number = PhoneNumber(isoCode: 'KE');

  @override
  void initState() {
    super.initState();
    context.read<IndustriesBloc>().add(GetIndustriesList());
  }

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
                  final isAlreadyRegistered = state.error
                      .toLowerCase()
                      .contains('already exists');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                      action: isAlreadyRegistered
                          ? SnackBarAction(
                              label: 'Login',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignInScreen(),
                                  ),
                                );
                              },
                            )
                          : null,
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
                    phone: phoneController.text.trim(),
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

                            /// EMAIL (Full Width)
                            _InputLabel("Email Address", isTablet: isTablet),
                            _InputField(
                              controller: emailController,
                              hint: "Email address",
                              isTablet: isTablet,
                            ),

                            SizedBox(height: isTablet ? 20 : 16),

                            /// PHONE NUMBER (Country Code Picker + Input)
                            _InputLabel("Phone Number", isTablet: isTablet),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.black.withAlpha(40),
                                  width: 1,
                                ),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Colors.white,
                                  bottomSheetTheme: const BottomSheetThemeData(
                                    backgroundColor: Colors.white,
                                    surfaceTintColor: Colors.white,
                                  ),
                                ),
                                child: InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber value) {
                                    setState(() {
                                      number = value;
                                    });
                                  },
                                  onSaved: (PhoneNumber number) {
                                    setState(() {
                                      this.number = number;
                                    });
                                  },
                                  selectorConfig: SelectorConfig(
                                    selectorType: isTablet
                                        ? PhoneInputSelectorType.DIALOG
                                        : PhoneInputSelectorType.BOTTOM_SHEET,
                                    showFlags: true,
                                    useEmoji: true,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  selectorTextStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                  initialValue: number,
                                  textFieldController: phoneController,
                                  formatInput: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                  inputDecoration: InputDecoration(
                                    hintText: "Phone number",
                                    hintStyle: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: isTablet ? 16 : 14,
                                    ),
                                  ),
                                  searchBoxDecoration: const InputDecoration(
                                    labelText:
                                        'Search by country name or dial code',
                                  ),
                                ),
                              ),
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
                            _PasswordSection(
                              controller: passwordController,
                              isTablet: isTablet,
                            ),

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
                                          sendWelcomeEmail: false,
                                          posIndustry: selectedIndustryCode!,
                                          businessName: "",
                                          phone: number.phoneNumber!,
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
    if (valid) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 18 : 16,
            color: Colors.red,
          ),
          SizedBox(width: isTablet ? 10 : 8),
          Text(
            text,
            style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.red),
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

class _PasswordSection extends StatefulWidget {
  final TextEditingController controller;
  final bool isTablet;

  const _PasswordSection({required this.controller, this.isTablet = false});

  @override
  State<_PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<_PasswordSection> {
  bool obscure = true;
  String password = "";

  bool get showRules => password.isNotEmpty;
  bool get hasMinLength => password.length >= 8;
  bool get hasUpperLower =>
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecial => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  void initState() {
    super.initState();
    // Initialize password with current controller text in case of rebuilds/re-entry
    password = widget.controller.text;
    widget.controller.addListener(_updatePassword);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePassword);
    super.dispose();
  }

  void _updatePassword() {
    if (widget.controller.text != password) {
      setState(() {
        password = widget.controller.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputLabel("Password", isTablet: widget.isTablet),
        TextField(
          controller: widget.controller,
          obscureText: obscure,
          // Update local state on change to trigger validation rules rebuild
          // This only rebuilds _PasswordSection, not the entire screen
          onChanged: (v) => setState(() => password = v),
          style: TextStyle(fontSize: widget.isTablet ? 16 : 14),
          decoration: InputDecoration(
            hintText: "Keep it secure",
            hintStyle: TextStyle(fontSize: widget.isTablet ? 16 : 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? 18 : 16,
              vertical: widget.isTablet ? 16 : 14,
            ),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => obscure = !obscure),
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: widget.isTablet ? 22 : 20,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (showRules) ...[
          SizedBox(height: widget.isTablet ? 14 : 10),
          _PasswordRule(
            "Minimum 8 characters",
            hasMinLength,
            isTablet: widget.isTablet,
          ),
          _PasswordRule(
            "Uppercase & lowercase letters",
            hasUpperLower,
            isTablet: widget.isTablet,
          ),
          _PasswordRule(
            "At least 1 number",
            hasNumber,
            isTablet: widget.isTablet,
          ),
          _PasswordRule(
            "At least 1 special character",
            hasSpecial,
            isTablet: widget.isTablet,
          ),
        ],
      ],
    );
  }
}
