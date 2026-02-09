import 'package:flutter/material.dart';
import 'package:pos/screens/brands/brands_page.dart';
import 'package:pos/screens/categories/categories_page.dart';
import 'package:pos/screens/price_list/price_lists_page.dart';
import 'package:pos/screens/products/product_list.dart';
import 'package:pos/screens/units/units_page.dart';
import 'package:pos/screens/warranties/warranties_page.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class ProductsDashboard extends StatelessWidget {
  const ProductsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Product Management", Colors.blue),
            const SizedBox(height: 4),
            _sectionSubtitle(
              "Manage products, brands, categories, and pricing",
            ),
            const SizedBox(height: 16),
            _grid([
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                icon: Icons.inventory_2_outlined,
                title: "Product List",
                subtitle: "View and manage products",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductManagementPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                icon: Icons.scale_outlined,
                title: "Units",
                subtitle: "Manage units of measure",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UnitsPage()),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                icon: Icons.branding_watermark_outlined,
                title: "Brands",
                subtitle: "Manage product brands",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BrandsPage()),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFEBEE),
                iconColor: Colors.red,
                icon: Icons.category_outlined,
                title: "Categories",
                subtitle: "Manage product categories",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.purple,
                icon: Icons.security_outlined,
                title: "Warranties",
                subtitle: "Manage warranties",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WarrantiesPage(),
                    ),
                  );
                },
              ),
              InventoryCard(
                backgroundColor: Colors.white,
                iconBackgroundColor: const Color(0xFFFFF3E0),
                iconColor: Colors.teal,
                icon: Icons.price_change_outlined,
                title: "Price Lists",
                subtitle: "Manage price lists",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PriceListsPage(),
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
