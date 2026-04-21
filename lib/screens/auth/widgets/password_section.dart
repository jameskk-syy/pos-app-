import 'package:flutter/material.dart';
import 'auth_input_field.dart';

class PasswordRule extends StatelessWidget {
  final String text;
  final bool valid;
  final bool isTablet;
  const PasswordRule(
    this.text,
    this.valid, {
    super.key,
    this.isTablet = false,
  });

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

class PasswordSection extends StatefulWidget {
  final TextEditingController controller;
  final bool isTablet;

  const PasswordSection({
    super.key,
    required this.controller,
    this.isTablet = false,
  });

  @override
  State<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<PasswordSection> {
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
      if (mounted) {
        setState(() {
          password = widget.controller.text;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthInputLabel("Password", isTablet: widget.isTablet),
        AuthTextField(
          controller: widget.controller,
          obscureText: obscure,
          hint: "Keep it secure",
          isTablet: widget.isTablet,
          onChanged: (v) => setState(() => password = v),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => obscure = !obscure),
            child: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: widget.isTablet ? 22 : 20,
            ),
          ),
        ),
        if (showRules) ...[
          SizedBox(height: widget.isTablet ? 14 : 10),
          PasswordRule(
            "Minimum 8 characters",
            hasMinLength,
            isTablet: widget.isTablet,
          ),
          PasswordRule(
            "Uppercase & lowercase letters",
            hasUpperLower,
            isTablet: widget.isTablet,
          ),
          PasswordRule(
            "At least 1 number",
            hasNumber,
            isTablet: widget.isTablet,
          ),
          PasswordRule(
            "At least 1 special character",
            hasSpecial,
            isTablet: widget.isTablet,
          ),
        ],
      ],
    );
  }
}
