import 'package:flutter/material.dart';
import 'package:pos/domain/responses/item_group.dart';

class CategoriesList extends StatelessWidget {
  final List<ItemGroup> categories;
  final Function(ItemGroup) onEdit;

  const CategoriesList({
    super.key,
    required this.categories,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text("No categories found"));
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
              rows: categories.map((cat) => _buildRow(cat, isMobile)).toList(),
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
          'Name',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ),
      const DataColumn(
        label: Text(
          'Parent Group',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ),
      if (!isMobile)
        const DataColumn(
          label: Text(
            'Is Group',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
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

  DataRow _buildRow(ItemGroup cat, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(Text(cat.itemGroupName)),
        DataCell(Text(cat.parentItemGroup.isEmpty ? '-' : cat.parentItemGroup)),
        if (!isMobile)
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cat.isGroupBool
                    ? Colors.blue.withAlpha(1)
                    : Colors.grey.withAlpha(1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cat.isGroupBool ? 'Yes' : 'No',
                style: TextStyle(
                  color: cat.isGroupBool ? Colors.blue : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.blueGrey),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit(cat);
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
