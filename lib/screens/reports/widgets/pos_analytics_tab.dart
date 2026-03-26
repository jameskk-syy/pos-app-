import 'package:flutter/material.dart';
import 'package:pos/screens/reports/widgets/product_sales_analytics_page.dart';
import 'package:pos/screens/reports/widgets/z_report_page.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class PosAnalyticsTab extends StatefulWidget {
  const PosAnalyticsTab({super.key});

  @override
  State<PosAnalyticsTab> createState() => _PosAnalyticsTabState();
}

class _PosAnalyticsTabState extends State<PosAnalyticsTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
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
                iconBackgroundColor: Colors.teal.withAlpha(26),
                iconColor: Colors.teal,
                icon: Icons.analytics,
                title: "Product Sales Analytics",
                subtitle: "Grouped sales metrics by product",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductSalesAnalyticsPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.amber.withAlpha(26),
                iconColor: Colors.amber,
                icon: Icons.summarize_outlined,
                title: "Z-Report (EOD)",
                subtitle: "End of day POS summary",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ZReportPage(),
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
