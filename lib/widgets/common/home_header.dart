import 'package:flutter/material.dart';
import 'package:pos/utils/constants/icons.dart';
import 'package:pos/widgets/common/earch_field.dart';
import 'icon_button_with_counter.dart';

class HomeHeader extends StatelessWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final int cartCount;
  final VoidCallback onCartPressed;
  final VoidCallback onNotificationsPressed;

  const HomeHeader({
    super.key,
    this.searchController,
    this.onSearchChanged,
    required this.cartCount,
    required this.onCartPressed,
    required this.onNotificationsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SearchField(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 16),
          IconBtnWithCounter(
            svgSrc: cartIcon,
            numOfitem: cartCount,
            onPressed: onCartPressed,
          ),
          const SizedBox(width: 8),
          IconBtnWithCounter(
            svgSrc: bellIcon,
            numOfitem: 3,
            onPressed: onNotificationsPressed,
          ),
        ],
      ),
    );
  }
}