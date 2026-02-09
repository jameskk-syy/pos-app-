import 'package:flutter/material.dart';
import 'package:pos/screens/reports/widgets/inventory_turnover_page.dart';
import 'package:pos/screens/reports/widgets/inventory_days_on_hand_page.dart';
import 'package:pos/screens/reports/widgets/inventory_movement_patterns_page.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class StockMovementTab extends StatefulWidget {
  const StockMovementTab({super.key});

  @override
  State<StockMovementTab> createState() => _StockMovementTabState();
}

class _StockMovementTabState extends State<StockMovementTab> {
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
                icon: Icons.loop,
                title: "Inventory Turnover Report",
                subtitle: "Analyze stock rotation speed",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryTurnoverPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.green.withAlpha(26),
                iconColor: Colors.green,
                icon: Icons.timer,
                title: "Inventory Days on Hand Report",
                subtitle: "View stock availability periods",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryDaysOnHandPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.orange.withAlpha(26),
                iconColor: Colors.orange,
                icon: Icons.analytics_outlined,
                title: "Inventory Movement Patterns",
                subtitle: "Identify stock movement cycles",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryMovementPatternsPage(),
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
