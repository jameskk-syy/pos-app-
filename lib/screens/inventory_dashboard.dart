import 'package:flutter/material.dart';
// import 'package:pos/screens/create_material_transfer.dart';
import 'package:pos/screens/inventory_discount_rules_screen.dart';
import 'package:pos/screens/low_stock.dart';
import 'package:pos/screens/stock_entries.dart';
import 'package:pos/screens/stock_entry_page.dart';
import 'package:pos/screens/stock_leder.dart';
import 'package:pos/screens/stock_material_issue.dart';
import 'package:pos/screens/stock_receipt_page.dart';
// import 'package:pos/screens/stock_reconciliation.dart';
import 'package:pos/screens/stock_reconciliation_multi.dart';
import 'package:pos/screens/stock_summary.dart';
import 'package:pos/screens/stock_transfer.dart';
import 'package:pos/widgets/inventory_card.dart';

class InventoryDashboards extends StatelessWidget {
  const InventoryDashboards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Inventory Operations", Colors.blue),
            const SizedBox(height: 4),
            _sectionSubtitle(
              "Manage stock movements, view summaries, and track inventory across warehouses",
            ),
            const SizedBox(height: 16),

            _sectionTitle("Reports & Analysis", Colors.blue),
            const SizedBox(height: 10),

            _grid([
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                icon: Icons.inventory_2_outlined,
                title: "Stock Summary",
                subtitle: "View stock levels across",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockSummaryPage()),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                icon: Icons.warning_amber_outlined,
                title: "Low Stock Alert",
                subtitle: "Items below threshold",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => LowStockAlertPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                icon: Icons.receipt_long_outlined,
                title: "Stock Ledger",
                subtitle: "Transaction history",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => StockLedgerDetailsPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFEBEE),
                iconColor: Colors.red,
                icon: Icons.list_alt_outlined,
                title: "Inventory Details",
                subtitle: "View and track details",
                onTap: () {
                  Navigator.pushNamed(context, '/inventory-details');
                },
              ),
            ]),

            const SizedBox(height: 24),

            _sectionTitle("Stock Movements", Colors.blue),
            const SizedBox(height: 10),
            _grid([
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                icon: Icons.input_outlined,
                title: "Stock Entries",
                subtitle: "View all stock entries",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockEntriesPage()),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                icon: Icons.download_outlined,
                title: "Material Receipt",
                subtitle: "Log incoming receipts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => StockReceiptPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                icon: Icons.upload_outlined,
                title: "Material Issues",
                subtitle: "View and create issues",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => MaterialIssuePage(),
                    ),
                  );
                },
              ),
              // InventoryCard(
              //   backgroundColor: Colors.white,
              //   iconBackgroundColor: const Color(0xFFFFEBEE),
              //   iconColor: Colors.red,
              //   icon: Icons.sync_alt_outlined,
              //   title: "Material Transfers",
              //   subtitle: "View and create transfers",
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context2) => CreateTransferForm(),
              //       ),
              //     );
              //   },
              // ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFEBEE),
                iconColor: Colors.red,
                icon: Icons.sync_alt_outlined,
                title: "Stock  Transfers",
                subtitle: "View and create transfers",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => StockTransferPage(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            _sectionTitle("Stock Management", Colors.blue),
            const SizedBox(height: 10),
            _grid([
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                icon: Icons.add_box_outlined,
                title: "Stock Entry",
                subtitle: "Create stock entry",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context2) => StockEntryPage()),
                  );
                },
              ),
              // InventoryCard(
              //   backgroundColor: Colors.white,
              //   iconBackgroundColor: const Color(0xFFFFF3E0),
              //   iconColor: Colors.orange,
              //   icon: Icons.checklist_outlined,
              //   title: "Stock Reconciliation",
              //   subtitle: "Reconcile stock counts",
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context2) =>
              //             StockReconciliationPage(company: ''),
              //       ),
              //     );
              //   },
              // ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                icon: Icons.checklist_outlined,
                title: "Stock Multi Reconciliation",
                subtitle: "Reconcile stock counts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => StockReconciliationMultiPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                icon: Icons.checklist_outlined,
                title: "Inventory Discounts",
                subtitle: "apply discount rules",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context2) => InventoryDiscountRulesScreen(),
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
