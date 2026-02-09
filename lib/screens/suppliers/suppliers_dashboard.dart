import 'package:flutter/material.dart';
import 'package:pos/screens/suppliers/supplier_entry.dart';
import 'package:pos/screens/suppliers/supplier_groups.dart';
import 'package:pos/screens/suppliers/suppliers_list.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class SupliersDashboards extends StatelessWidget {
  const SupliersDashboards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Suppliers Operations", Colors.blue),
            const SizedBox(height: 4),
            _sectionSubtitle("Manage suppliers both indivudal/group"),
            const SizedBox(height: 16),

            _sectionTitle("Actions", Colors.blue),
            const SizedBox(height: 10),

            _grid([
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                icon: Icons.inventory_2_outlined,
                title: "Suppliers List",
                subtitle: "View all suppliers",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuppliersListPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                icon: Icons.warning_amber_outlined,
                title: "Individual Supplier",
                subtitle: "Create individual supplier",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context2) => AddSupplierPage()),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                icon: Icons.receipt_long_outlined,
                title: "Suppliers groups",
                subtitle: "Create supplier groups",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => AddSupplierGroupPage(),
                    ),
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

  Widget _grid(List<Widget> children) {
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
