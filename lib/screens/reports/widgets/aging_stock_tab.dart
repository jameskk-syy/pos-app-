import 'package:flutter/material.dart';
import 'package:pos/screens/reports/widgets/aging_stock_report_page.dart';
import 'package:pos/screens/reports/widgets/expiry_report_page.dart';
import 'package:pos/screens/reports/widgets/inventory_recommendations_page.dart';
import 'package:pos/screens/reports/widgets/risk_report_page.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class AgingStockTab extends StatefulWidget {
  const AgingStockTab({super.key});

  @override
  State<AgingStockTab> createState() => _AgingStockTabState();
}

class _AgingStockTabState extends State<AgingStockTab> {
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
                icon: Icons.pie_chart,
                title: "Stock Aging Analysis",
                subtitle: "View charts and detailed aging reports",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StockAgingReportPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.orange.withAlpha(26),
                iconColor: Colors.orange,
                icon: Icons.lightbulb,
                title: "Inventory Recommendations",
                subtitle: "Insights for stock optimization",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryRecommendationsPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.red.withAlpha(26),
                iconColor: Colors.red,
                icon: Icons.access_time_filled,
                title: "Expiry Analysis",
                subtitle: "Track batch expiry and shelf life",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExpiryReportPage()),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.purple.withAlpha(26),
                iconColor: Colors.purple,
                icon: Icons.warning,
                title: "Obsolescence Risk",
                subtitle: "Identify slow-moving and risky stock",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RiskAnalysisPage()),
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
