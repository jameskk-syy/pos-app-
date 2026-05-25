import 'package:flutter/material.dart';

class AuthInputLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  const AuthInputLabel(this.text, {super.key, this.isTablet = false});

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

class AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool isTablet;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.hint,
    this.controller,
    this.isTablet = false,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
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
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
