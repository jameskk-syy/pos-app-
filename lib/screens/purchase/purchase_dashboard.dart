import 'package:flutter/material.dart';
import 'package:pos/screens/purchase/purchase_order_list.dart';
import 'package:pos/screens/purchase/purchase_invoice_list.dart';
import 'package:pos/screens/purchase/grn_list_screen.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class PurchaseDashboards extends StatelessWidget {
  const PurchaseDashboards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Purchase Dashboard", Colors.blue),
            const SizedBox(height: 4),
            _sectionSubtitle(
              "Manage purchase orders, track purchase receipts, and monitor supplier orders",
            ),
            const SizedBox(height: 16),

            _sectionTitle("Purchase Orders/Receive", Colors.blue),
            const SizedBox(height: 10),

            _grid([
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                icon: Icons.shopping_cart_outlined,
                title: "Purchase Orders",
                subtitle: "View and create purchase orders",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => PurchaseOrdersPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                icon: Icons.receipt_long,
                title: "Purchase Invoices",
                subtitle: "View supplier invoices",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PurchaseInvoiceListScreen(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFF3E5F5),
                iconColor: Colors.purple,
                icon: Icons.inventory_2_outlined,
                title: "Goods Received Notes",
                subtitle: "View purchase receipts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GrnListScreen(),
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
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
