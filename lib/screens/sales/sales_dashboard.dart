import 'package:flutter/material.dart';
import 'package:pos/screens/sales/invoices_page.dart';
import 'package:pos/screens/sales/pos_opening_entries_page.dart';
import 'package:pos/screens/settings/sync_page.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class SalesDashboard extends StatelessWidget {
  const SalesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Sales Operations", Colors.blue),
            const SizedBox(height: 4),
            _sectionSubtitle("Manage sales, invoices, and synchronization"),
            const SizedBox(height: 16),
            _grid(context, [
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                icon: Icons.description_outlined,
                title: "Invoices",
                subtitle: "View and manage invoices",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InvoicesPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                icon: Icons.vpn_key_outlined,
                title: "Opening Entries",
                subtitle: "Manage opening entries",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PosOpeningEntriesPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFEBEE),
                iconColor: Colors.red,
                icon: Icons.sync_outlined,
                title: "Offline Sync",
                subtitle: "Sync offline data",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SyncPage()),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _grid(BuildContext context, List<Widget> children) {
    return LayoutBuilder(
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
          children: children,
        );
      },
    );
  }
}
