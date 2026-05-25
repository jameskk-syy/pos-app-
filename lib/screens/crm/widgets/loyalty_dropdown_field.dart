import 'package:flutter/material.dart';

class LoyaltyDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final bool isMobile;
  final ValueChanged<String> onChanged;

  const LoyaltyDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.isMobile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category, size: 18, color: Color(0xFF1E88E5)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: onChanged,
            itemBuilder: (BuildContext context) => items
                .map(
                  (item) => _buildPopupMenuItem(
                    item,
                    _getItemIcon(item),
                    isMobile,
                  ),
                )
                .toList(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 14,
                vertical: isMobile ? 12 : 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more, color: Color(0xFF1E88E5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    IconData icon,
    bool isMobile,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E88E5)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: isMobile ? 13 : 14)),
          ),
        ],
      ),
    );
  }

  IconData _getItemIcon(String item) {
    switch (item) {
      case 'Single Tier Program':
        return Icons.layers;
      case 'Multiple Tier Program':
        return Icons.stairs;
      case 'Points Only':
        return Icons.stars;
      default:
        return Icons.category;
    }
  }
}
