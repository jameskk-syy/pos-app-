import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          readOnly: readOnly,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            // Most styling now comes from AppTheme's inputDecorationTheme
          ),
        ),
      ],
    );
  }
}
