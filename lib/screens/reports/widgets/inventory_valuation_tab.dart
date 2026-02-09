import 'package:flutter/material.dart';
import 'package:pos/screens/reports/widgets/inventory_cost_method_page.dart';
import 'package:pos/screens/reports/widgets/inventory_value_by_category_page.dart';
import 'package:pos/screens/reports/widgets/inventory_value_trends_page.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryValuationTab extends StatefulWidget {
  const InventoryValuationTab({super.key});

  @override
  State<InventoryValuationTab> createState() => _InventoryValuationTabState();
}

class _InventoryValuationTabState extends State<InventoryValuationTab> {
  String companyName = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = MediaQuery.of(context).size.width;
          int crossAxisCount = w < 600 ? 2 : (w < 1100 ? 3 : 4);
          double childAspectRatio = w < 600 ? 1.4 : (w < 1100 ? 1.6 : 1.8);

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
                icon: Icons.category_outlined,
                title: "Value by Category",
                subtitle: "View inventory value distribution",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryValueByCategoryPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.orange.withAlpha(26),
                iconColor: Colors.orange,
                icon: Icons.compare_arrows,
                title: "Cost Method Comparison",
                subtitle: "Compare FIFO vs Weighted Average",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryCostMethodPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: Colors.purple.withAlpha(26),
                iconColor: Colors.purple,
                icon: Icons.trending_up,
                title: "Inventory Value Trends",
                subtitle: "Analyze inventory value over time",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryValueTrendsPage(),
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
