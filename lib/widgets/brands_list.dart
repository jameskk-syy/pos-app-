import 'package:flutter/material.dart';
import 'package:pos/domain/responses/item_brand.dart';

class BrandsList extends StatelessWidget {
  final List<Brand> brands;
  final Function(Brand) onEdit;

  const BrandsList({super.key, required this.brands, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) {
      return const Center(child: Text("No blocks found"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: isMobile ? 20 : 40,
              columns: _buildColumns(isMobile),
              rows: brands.map((brand) => _buildRow(brand, isMobile)).toList(),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(bool isMobile) {
    return [
      const DataColumn(
        label: Text(
          'Brand Name',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ),
      const DataColumn(
        label: Text(
          'Actions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ),
    ];
  }

  DataRow _buildRow(Brand brand, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(Text(brand.brandName)),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.blueGrey),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit(brand);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
