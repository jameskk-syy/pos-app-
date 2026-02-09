import 'package:flutter/material.dart';
import 'package:pos/domain/responses/price_list_response.dart';

class PriceListsList extends StatelessWidget {
  final List<PriceList> priceLists;
  final Function(PriceList) onEdit;

  const PriceListsList({
    super.key,
    required this.priceLists,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (priceLists.isEmpty) {
      return const Center(child: Text("No price lists found"));
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
              rows: priceLists.map((pl) => _buildRow(pl, isMobile)).toList(),
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
          'Currency',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ),
      if (!isMobile) ...[
        const DataColumn(
          label: Text(
            'Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        const DataColumn(
          label: Text(
            'Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ],
      const DataColumn(
        label: Text(
          'Actions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ),
    ];
  }

  DataRow _buildRow(PriceList pl, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(Text(pl.priceListName)),
        DataCell(Text(pl.currency)),
        if (!isMobile) ...[
          DataCell(
            Row(
              children: [
                if (pl.isSelling) _buildBadge('Selling', Colors.green),
                if (pl.isSelling && pl.isBuying) const SizedBox(width: 4),
                if (pl.isBuying) _buildBadge('Buying', Colors.orange),
              ],
            ),
          ),
          DataCell(
            _buildBadge(
              pl.isEnabled ? 'Enabled' : 'Disabled',
              pl.isEnabled ? Colors.blue : Colors.grey,
            ),
          ),
        ],
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.blueGrey),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit(pl);
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
