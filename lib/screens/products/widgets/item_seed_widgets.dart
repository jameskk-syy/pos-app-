import 'package:flutter/material.dart';
import 'package:pos/domain/responses/products/seed_products_response.dart';
import 'package:pos/utils/themes/app_colors.dart';

class ProductSeedSearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final VoidCallback onChanged;

  const ProductSeedSearchField({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText: 'Search products by name or SKU...',
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.blue),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: onClear)
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
        ),
      ),
    );
  }
}

class ProductSeedTable extends StatelessWidget {
  final List<PharmacyProduct> products;
  final Map<String, dynamic> cartItemsMap;
  final Function(PharmacyProduct) onSelect;
  final Function(String) onRemove;
  final bool isMobile;
  final double contentWidth;

  const ProductSeedTable({
    super.key,
    required this.products,
    required this.cartItemsMap,
    required this.onSelect,
    required this.onRemove,
    required this.isMobile,
    required this.contentWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No products match your search', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: isMobile ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: isMobile ? contentWidth : 900,
            maxWidth: isMobile ? contentWidth : double.infinity,
          ),
          child: DataTable(
            columnSpacing: isMobile ? 8 : 24,
            horizontalMargin: isMobile ? 8 : 24,
            headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
            dataRowMinHeight: 56,
            dataRowMaxHeight: 64,
            columns: _buildColumns(),
            rows: products.map((product) => _buildRow(product)).toList(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    if (isMobile) {
      return const [
        DataColumn(label: Text('Select', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
      ];
    }
    return const [
      DataColumn(label: Text('Select', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Buying Price', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Selling Price', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
    ];
  }

  DataRow _buildRow(PharmacyProduct product) {
    final isInCart = cartItemsMap.containsKey(product.sku);
    final cartItem = cartItemsMap[product.sku];

    if (isMobile) {
      return DataRow(
        cells: [
          DataCell(SizedBox(width: 24, child: Checkbox(value: isInCart, onChanged: (_) => onSelect(product)))),
          DataCell(
            GestureDetector(
              onTap: () => onSelect(product),
              child: SizedBox(
                width: contentWidth * 0.45,
                child: Text(product.name ?? 'Unnamed', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          DataCell(Text(isInCart ? '${cartItem?.qty ?? 0}' : '-', style: TextStyle(fontWeight: isInCart ? FontWeight.bold : FontWeight.normal, color: isInCart ? AppColors.blue : Colors.black, fontSize: 12))),
          DataCell(Text(isInCart ? '${cartItem?.itemPrice.toStringAsFixed(0)}' : '-', style: TextStyle(color: isInCart ? AppColors.blue : Colors.grey, fontWeight: isInCart ? FontWeight.bold : FontWeight.normal, fontSize: 12))),
        ],
      );
    }

    return DataRow(
      cells: [
        DataCell(Row(children: [Checkbox(value: isInCart, onChanged: (_) => onSelect(product)), const Text('Consumable')])),
        DataCell(
          GestureDetector(
            onTap: () => onSelect(product),
            child: SizedBox(width: 250, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(product.name ?? 'Unnamed', style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(product.sku ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ])),
          ),
        ),
        DataCell(Text(isInCart ? '${cartItem?.qty ?? 0}' : '-', style: TextStyle(fontWeight: isInCart ? FontWeight.bold : FontWeight.normal, color: isInCart ? AppColors.blue : Colors.black))),
        DataCell(Text(isInCart ? '${cartItem?.buyingPrice.toStringAsFixed(2)}' : '-', style: TextStyle(color: isInCart ? Colors.black : Colors.grey))),
        DataCell(Text(isInCart ? '${cartItem?.itemPrice.toStringAsFixed(2)}' : '-', style: TextStyle(color: isInCart ? AppColors.blue : Colors.grey, fontWeight: isInCart ? FontWeight.bold : FontWeight.normal))),
        DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.edit_note, color: AppColors.blue), onPressed: () => onSelect(product), tooltip: 'Edit quantity/price'),
          if (isInCart) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => onRemove(product.sku!), tooltip: 'Remove'),
        ])),
      ],
    );
  }
}

class ProductQuantityDialog extends StatefulWidget {
  final PharmacyProduct product;
  final dynamic existingItem;
  final Function(int, double, double) onSave;
  final VoidCallback onRemove;

  const ProductQuantityDialog({
    super.key,
    required this.product,
    this.existingItem,
    required this.onSave,
    required this.onRemove,
  });

  @override
  State<ProductQuantityDialog> createState() => _ProductQuantityDialogState();
}

class _ProductQuantityDialogState extends State<ProductQuantityDialog> {
  late TextEditingController quantityController;
  late TextEditingController priceController;
  late TextEditingController buyingPriceController;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.existingItem?.qty.toString() ?? '1');
    priceController = TextEditingController(text: widget.existingItem?.itemPrice.toStringAsFixed(2) ?? widget.product.itemPrice?.toStringAsFixed(2) ?? '');
    buyingPriceController = TextEditingController(text: widget.existingItem?.buyingPrice.toStringAsFixed(2) ?? widget.product.buyingPrice?.toStringAsFixed(2) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.existingItem != null ? 'Update item' : 'Add item', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Text(widget.product.name ?? 'Product', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('SKU: ${widget.product.sku ?? "N/A"}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 20),
              const Text('Quantity:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildQtySelector(),
              const SizedBox(height: 20),
              _buildField('Selling Price per unit', priceController),
              const SizedBox(height: 16),
              _buildField('Buying Price per unit', buyingPriceController),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 28),
          onPressed: () {
            int currentQty = int.tryParse(quantityController.text) ?? 1;
            if (currentQty > 1) setState(() => quantityController.text = (currentQty - 1).toString());
          },
        ),
        const SizedBox(width: 16),
        SizedBox(width: 80, child: TextField(controller: quantityController, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true))),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 28),
          onPressed: () {
            int currentQty = int.tryParse(quantityController.text) ?? 1;
            setState(() => quantityController.text = (currentQty + 1).toString());
          },
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (widget.existingItem != null)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.red.shade200))),
              onPressed: () { widget.onRemove(); Navigator.pop(context); },
              child: const Text('Remove'),
            ),
          ),
        if (widget.existingItem != null) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 1;
              final price = double.tryParse(priceController.text) ?? 0.0;
              final buyingPrice = double.tryParse(buyingPriceController.text) ?? 0.0;
              if (price <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid selling price'), backgroundColor: Colors.red)); return; }
              widget.onSave(quantity, price, buyingPrice);
              Navigator.pop(context);
            },
            child: Text(widget.existingItem != null ? 'Update item' : 'Add item', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
