import 'package:flutter/material.dart';

Widget getIndustryIcon(String industry, {Color? color, double size = 24}) {
  IconData iconData;
  switch (industry.toLowerCase()) {
    case 'retail':
    case 'retail (default migration)':
      iconData = Icons.storefront;
      break;
    case 'f&b':
    case 'food & beverage':
    case 'restaurant':
      iconData = Icons.restaurant;
      break;
    case 'pharmacy':
    case 'healthcare':
      iconData = Icons.local_pharmacy;
      break;
    case 'supermarket':
      iconData = Icons.shopping_cart;
      break;
    case 'services':
      iconData = Icons.build_circle;
      break;
    default:
      iconData = Icons.business;
  }
  return Icon(iconData, color: color ?? Colors.blue, size: size);
}

class IndustryBadge extends StatelessWidget {
  final String industry;

  const IndustryBadge({super.key, required this.industry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          getIndustryIcon(industry, size: 14),
          const SizedBox(width: 4),
          Text(
            industry,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
