import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/utils/themes/app_colors.dart';

class SalesCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String value;
  final String? netLabel;
  final String? netValue;
  final String? percentage;
  final Color? valueColor;
  final Color? percentageColor;

  const SalesCard({
    super.key,
    required this.backgroundColor,
    required this.title,
    required this.value,
    this.netLabel,
    this.netValue,
    this.percentage,
    this.valueColor,
    this.percentageColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        // Dynamic font sizes based on CARD width, with a cap for larger screens
        final labelFontSize = (cardWidth * 0.07).clamp(10.0, 14.0);
        final valueFontSize = (cardWidth * 0.11).clamp(16.0, 24.0);
        final miniFontSize = (cardWidth * 0.06).clamp(9.0, 12.0);

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.black, width: .1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned(
                  bottom: -10,
                  right: -20,
                  child: SvgPicture.asset(
                    'assets/svgs/group.svg',
                    width: cardWidth * 0.5,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.bold,
                            color: valueColor ?? Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (netLabel != null ||
                          netValue != null ||
                          percentage != null)
                        Flexible(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (netLabel != null)
                                Text(
                                  "$netLabel ",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: miniFontSize,
                                    color: Colors.black54,
                                  ),
                                ),
                              if (netValue != null)
                                Text(
                                  "$netValue ",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: miniFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (percentage != null) ...[
                                Text(
                                  "• ",
                                  style: TextStyle(
                                    fontSize: miniFontSize,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  percentage!,
                                  style: TextStyle(
                                    fontSize: miniFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: percentageColor ?? Colors.green,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
