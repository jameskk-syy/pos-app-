import 'package:flutter/material.dart';
import 'package:pos/domain/responses/product_response.dart';

class WarrantiesList extends StatelessWidget {
  final List<ProductItem> products;
  final Function(ProductItem) onSetWarranty;

  const WarrantiesList({
    super.key,
    required this.products,
    required this.onSetWarranty,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: isMobile ? 20 : 40,
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              columns: [
                const DataColumn(
                  label: Text(
                    'Item Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Period',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: products
                  .map((product) => _buildRow(product, context))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(ProductItem product, BuildContext context) {
    final hasWarranty =
        product.warrantyPeriod != null && product.warrantyPeriod! > 0;

    return DataRow(
      cells: [
        DataCell(Text(product.itemCode, style: const TextStyle(fontSize: 13))),
        DataCell(Text(product.itemName, style: const TextStyle(fontSize: 13))),
        DataCell(_buildWarrantyChip(product)),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'set') onSetWarranty(product);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'set',
                child: Row(
                  children: [
                    Icon(
                      hasWarranty ? Icons.edit : Icons.add_moderator,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(hasWarranty ? 'Update Warranty' : 'Set Warranty'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarrantyChip(ProductItem product) {
    final hasWarranty =
        product.warrantyPeriod != null && product.warrantyPeriod! > 0;

    if (!hasWarranty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(20),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Not Set',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${product.warrantyPeriod} ${product.warrantyPeriodUnit}',
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
