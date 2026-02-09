import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = "Search product",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF979797).withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF757575)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}