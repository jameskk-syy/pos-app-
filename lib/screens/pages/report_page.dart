import 'package:flutter/material.dart';
import 'package:pos/widgets/inventory_card.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Reports", Colors.blue),
            const SizedBox(height: 4),
            _sectionSubtitle(
              "View detailed reports and analytics for your business",
            ),
            const SizedBox(height: 16),

            _grid([
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                icon: Icons.trending_down_outlined,
                title: "Slow Moving Report",
                subtitle: "Track slow-moving inventory items",
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SlowMovingReportPage()));
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                icon: Icons.point_of_sale_outlined,
                title: "Sales Report",
                subtitle: "View comprehensive sales data",
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SalesReportPage()));
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFEBEE),
                iconColor: Colors.red,
                icon: Icons.delete_outline,
                title: "Waste and Expiry Report",
                subtitle: "Monitor waste and expiring items",
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => WasteExpiryReportPage()));
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                icon: Icons.analytics_outlined,
                title: "Sales Analytics Report",
                subtitle: "Analyze sales trends and patterns",
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SalesAnalyticsReportPage()));
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE1F5FE),
                iconColor: Colors.cyan,
                icon: Icons.account_balance_outlined,
                title: "P&L Report",
                subtitle: "View profit and loss statements",
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfitLossReportPage()));
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFF3E5F5),
                iconColor: Colors.purple,
                icon: Icons.inventory_outlined,
                title: "Inventory Valuation Report",
                subtitle: "View current inventory value",
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryValuationReportPage()));
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