import 'package:flutter/material.dart';
import 'package:pos/screens/purchase_order_list.dart';
import 'package:pos/widgets/inventory_card.dart';

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
                  Navigator.push(context, MaterialPageRoute(builder: (context2)=>PurchaseOrdersPage()));
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFEBEE),
                iconColor: Colors.red,
                icon: Icons.cancel_outlined,
                title: "Received Purchase",
                subtitle: "View and create  received note",
                onTap: () {
                  Navigator.pushNamed(context, '/cancelled-purchase-orders');
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