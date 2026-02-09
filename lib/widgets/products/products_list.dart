import 'package:flutter/material.dart';
import 'package:pos/domain/responses/products/product_response.dart';

class ProductsList extends StatelessWidget {
  final String searchQuery;
  final List<ProductItem> filteredProducts;
  final List<ProductItem> allProducts;
  final VoidCallback onRefresh;
  final Function(ProductItem) onViewDetails;
  final Function(ProductItem) onEditProduct;
  final Function(ProductItem) onManageBarcode;
  final Function(ProductItem) onManagePrice;
  final Function(ProductItem) onDisable;
  final Function(ProductItem) onEnable;

  final ScrollController scrollController;
  final bool isLoading;

  const ProductsList({
    super.key,
    required this.searchQuery,
    required this.filteredProducts,
    required this.allProducts,
    required this.onRefresh,
    required this.onViewDetails,
    required this.onEditProduct,
    required this.onManageBarcode,
    required this.onManagePrice,
    required this.onDisable,
    required this.onEnable,
    required this.scrollController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        return Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,

            border: isTablet
                ? null
                : Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: isTablet ? null : BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey.shade100,
                      ),
                      border: isTablet
                          ? null
                          : TableBorder.all(
                              color: Colors.grey.shade200,
                              width: 0.5,
                            ),
                      columns: _buildColumns(isTablet),
                      rows: filteredProducts.map((product) {
                        return DataRow(
                          cells: _buildCells(context, product, isTablet),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(bool isTablet) {
    final baseColumns = [
      const DataColumn(
        label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];

    if (isTablet) {
      baseColumns.addAll([
        const DataColumn(
          label: Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const DataColumn(
          label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ]);
    }

    baseColumns.add(
      const DataColumn(
        label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );

    return baseColumns;
  }

  List<DataCell> _buildCells(
    BuildContext context,
    ProductItem product,
    bool isTablet,
  ) {
    final baseCells = [
      DataCell(Text(product.itemName)),

      DataCell(Text(product.stockQty.toString())),
      DataCell(Text(product.price.toStringAsFixed(2))),
    ];

    if (isTablet) {
      baseCells.addAll([
        DataCell(Text(product.itemGroup)),
        DataCell(Text(product.itemCode)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.stockQty > 10
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              product.stockQty > 10 ? 'In Stock' : 'Low Stock',
              style: TextStyle(
                fontSize: 12,
                color: product.stockQty > 10
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
              ),
            ),
          ),
        ),
      ]);
    }

    baseCells.add(
      DataCell(
        PopupMenuButton<String>(
          color: Colors.white,
          icon: const Icon(Icons.more_vert, size: 20),
          tooltip: 'Actions',
          onSelected: (value) {
            switch (value) {
              case 'view':
                onViewDetails(product);
                break;
              case 'edit':
                onEditProduct(product);
                break;
              case 'barcode':
                onManageBarcode(product);
                break;
              case 'price':
                onManagePrice(product);
                break;
              case 'disable':
                onDisable(product);
                break;
              case 'enable':
                onEnable(product);
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            if (!product.isActive) {
              return [
                const PopupMenuItem<String>(
                  value: 'enable',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 18, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Enable Product'),
                    ],
                  ),
                ),
              ];
            }
            return [
              const PopupMenuItem<String>(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 18),
                    SizedBox(width: 12),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 12),
                    Text('Edit Product'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'barcode',
                child: Row(
                  children: [
                    Icon(Icons.qr_code, size: 18),
                    SizedBox(width: 12),
                    Text('Manage Barcode'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'price',
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 18),
                    SizedBox(width: 12),
                    Text('Manage Price'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'disable',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Disable Product',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );

    return baseCells;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty
                ? "No products found for '$searchQuery'"
                : "No products available",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          if (searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                onRefresh();
              },
              child: const Text(
                "Clear search",
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}
