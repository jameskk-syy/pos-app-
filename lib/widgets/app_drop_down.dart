import 'package:flutter/material.dart';

class AppDropDown<T> extends StatelessWidget {
  final T? selectedValue;
  final List<DropdownMenuItem<T>> dropdownItems;
  final Function(T?) onChanged;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final double fontSize;
  final EdgeInsets contentPadding;

  const AppDropDown({
    super.key,
    this.selectedValue,
    required this.dropdownItems,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.fontSize = 14,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 16,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && labelText != '')
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              labelText!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        DropdownButtonFormField<T>(
          initialValue: selectedValue,
          onChanged: enabled ? onChanged : null,
          items: dropdownItems,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).colorScheme.outline,
            size: 22,
          ),
          dropdownColor: Colors.white,
          isDense: true,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: contentPadding,
            // Border and Fill color now come from theme
          ),
        ),
      ],
    );
  }
}
