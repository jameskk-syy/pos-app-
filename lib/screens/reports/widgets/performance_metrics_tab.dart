import 'package:flutter/material.dart';
import 'package:pos/screens/reports/widgets/inventory_accuracy_page.dart';
import 'package:pos/screens/reports/widgets/adjustment_trend_page.dart';
import 'package:pos/screens/reports/widgets/inventory_transfer_efficiency_page.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class PerformanceMetricsTab extends StatefulWidget {
  const PerformanceMetricsTab({super.key});

  @override
  State<PerformanceMetricsTab> createState() => _PerformanceMetricsTabState();
}

class _PerformanceMetricsTabState extends State<PerformanceMetricsTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          // Use 2 columns on mobile, 3 or more on larger screens
          int crossAxisCount = w < 600 ? 2 : (w < 1100 ? 3 : 4);
          double childAspectRatio = w < 600 ? 1.3 : (w < 1100 ? 1.5 : 1.7);

          return GridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.blue.withAlpha(26),
                iconColor: Colors.blue,
                icon: Icons.check_circle_outline,
                title: "Inventory Accuracy",
                subtitle: "Analyze stock counting precision",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryAccuracyPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.orange.withAlpha(26),
                iconColor: Colors.orange,
                icon: Icons.trending_up,
                title: "Adjustment Trend",
                subtitle: "Monitor stock adjustments over time",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdjustmentTrendPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.purple.withAlpha(26),
                iconColor: Colors.purple,
                icon: Icons.swap_horiz,
                title: "Transfer Efficiency",
                subtitle: "Evaluate stock transfer performance",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryTransferEfficiencyPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
