import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/utils/themes/app_colors.dart';

class InventoryCard extends StatelessWidget {
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final double? borderRadius;

  const InventoryCard({
    super.key,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        // final cardHeight = constraints.maxHeight;

        // Dynamic font and icon sizes based on CARD width
        final titleFontSize = title == 'Stock Multi Reconciliation'
            ? (cardWidth * 0.06).clamp(10.0, 14.0)
            : (cardWidth * 0.08).clamp(12.0, 16.0);
        final subtitleFontSize = (cardWidth * 0.05).clamp(9.0, 12.0);
        final iconSize = (cardWidth * 0.12).clamp(20.0, 32.0);
        final backgroundIconWidth = cardWidth * 0.5;

        final effectiveRadius = borderRadius ?? 12.0;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(effectiveRadius),
              border: Border.all(
                color: AppColors.black.withAlpha(10),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(effectiveRadius),
              child: Stack(
                children: [
                  Positioned(
                    bottom: -10,
                    right: -20,
                    child: SvgPicture.asset(
                      'assets/svgs/group.svg',
                      width: backgroundIconWidth,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: subtitleFontSize,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: iconBackgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color: iconColor,
                                  size: iconSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
