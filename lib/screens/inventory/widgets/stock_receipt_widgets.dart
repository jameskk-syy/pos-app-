import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/widgets/common/delete_confirmation_dialog.dart';

class StockReceiptHeaderFields extends StatelessWidget {
  final String? selectedWarehouseName;
  final List<Warehouse> stores;
  final DateTime postingDate;
  final TimeOfDay postingTime;
  final Function(String?) onWarehouseChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const StockReceiptHeaderFields({
    super.key,
    required this.selectedWarehouseName,
    required this.stores,
    required this.postingDate,
    required this.postingTime,
    required this.onWarehouseChanged,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Target Warehouse*'),
        _buildStoreDropdown(),
        const SizedBox(height: 16),
        _buildLabel('Posting Date*'),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildLabel('Posting Time'),
        _buildTimeField(),
        const SizedBox(height: 4),
        const Text(
          'Optional (HH:MM:SS)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildStoreDropdown() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                state is StoreStateLoading
                    ? 'Loading stores...'
                    : stores.isEmpty
                    ? 'No stores available'
                    : 'Choose a warehouse',
              ),
              value: selectedWarehouseName,
              items: stores.map((store) {
                return DropdownMenuItem<String>(
                  value: store.name,
                  child: Text(
                    '${store.warehouseName}${store.isDefault ? ' (Default)' : ''}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onWarehouseChanged,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: onSelectDate,
      child: _buildInputBox(
        '${postingDate.day}/${postingDate.month}/${postingDate.year}',
        Icons.calendar_today,
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: onSelectTime,
      child: _buildInputBox(
        '${postingTime.hour.toString().padLeft(2, '0')}:${postingTime.minute.toString().padLeft(2, '0')}:00',
        Icons.access_time,
      ),
    );
  }

  Widget _buildInputBox(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          Icon(icon, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

class StockReceiptItemsTable extends StatelessWidget {
  final List<StockItem> items;
  final List<ProductItem> products;
  final String companyName;
  final VoidCallback onAddItem;
  final Function(int) onDeleteItem;
  final Function(int, ProductItem) onProductSelected;
  final Function(int, String) onQtyChanged;
  final Function(int, String) onRateChanged;

  const StockReceiptItemsTable({
    super.key,
    required this.items,
    required this.products,
    required this.companyName,
    required this.onAddItem,
    required this.onDeleteItem,
    required this.onProductSelected,
    required this.onQtyChanged,
    required this.onRateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Row(
                  children: const [
                    _Header('Item Code*', 200),
                    _Header('Qty*', 80),
                    _Header('Basic Rate*', 100),
                    _Header('', 50),
                  ],
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  _buildEmptyRow()
                else
                  ...items.asMap().entries.map(
                        (e) => StockReceiptItemRow(
                          item: e.value,
                          index: e.key,
                          products: products,
                          companyName: companyName,
                          onDeleteItem: () => onDeleteItem(e.key),
                          onProductSelected: (p) => onProductSelected(e.key, p),
                          onQtyChanged: (val) => onQtyChanged(e.key, val),
                          onRateChanged: (val) => onRateChanged(e.key, val),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onAddItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text('No items added yet', style: TextStyle(color: Colors.grey)),
    );
  }
}

class StockReceiptItemRow extends StatelessWidget {
  final StockItem item;
  final int index;
  final List<ProductItem> products;
  final String companyName;
  final VoidCallback onDeleteItem;
  final Function(ProductItem) onProductSelected;
  final Function(String) onQtyChanged;
  final Function(String) onRateChanged;

  const StockReceiptItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.products,
    required this.companyName,
    required this.onDeleteItem,
    required this.onProductSelected,
    required this.onQtyChanged,
    required this.onRateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            height: 40,
            child: InkWell(
              onTap: () => _handleProductSearch(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
                ),
                child: Text(
                  item.selectedProduct != null
                      ? '${item.selectedProduct!.itemCode} - ${item.selectedProduct!.itemName}'
                      : products.isEmpty ? 'No items' : 'Select Item',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            height: 40,
            child: TextFormField(
              initialValue: item.quantity.toString(),
              style: const TextStyle(fontSize: 12),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: onQtyChanged,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            height: 40,
            child: TextFormField(
              initialValue: item.basicRate.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: onRateChanged,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: () async {
                final confirmed = await DeleteConfirmationDialog.show(context);
                if (confirmed == true) onDeleteItem();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleProductSearch(BuildContext context) async {
    final selected = await showModalBottomSheet<ProductItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SearchPicker<ProductItem>(
        title: 'Select Item',
        items: products,
        displayLabel: (p) => '${p.itemCode} - ${p.itemName}',
        currentValue: item.selectedProduct,
        companyName: companyName,
      ),
    );

    if (selected != null) onProductSelected(selected);
  }
}

class _SearchPicker<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) displayLabel;
  final T? currentValue;
  final String companyName;

  const _SearchPicker({
    required this.title,
    required this.items,
    required this.displayLabel,
    required this.currentValue,
    required this.companyName,
  });

  @override
  State<_SearchPicker<T>> createState() => _SearchPickerState<T>();
}

class _SearchPickerState<T> extends State<_SearchPicker<T>> {
  final searchController = TextEditingController();
  Timer? debounce;

  @override
  void dispose() {
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController, autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...', prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { searchController.clear(); context.read<ProductsBloc>().add(GetAllProducts(company: widget.companyName, searchTerm: '')); setState(() {}); }) : null,
                  filled: true, fillColor: Colors.grey[100], contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  if (debounce?.isActive ?? false) debounce!.cancel();
                  debounce = Timer(const Duration(milliseconds: 500), () {
                    context.read<ProductsBloc>().add(GetAllProducts(company: widget.companyName, searchTerm: val));
                  });
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsStateLoading) return const Center(child: CircularProgressIndicator());
                  List<T> displayItems = widget.items;
                  if (state is ProductsStateSuccess) displayItems = state.productResponse.products as List<T>;
                  if (displayItems.isEmpty) return const Center(child: Text('No results found', style: TextStyle(color: Colors.grey)));
                  return ListView.builder(
                    controller: scrollController, itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      final isSelected = item == widget.currentValue;
                      return ListTile(
                        title: Text(widget.displayLabel(item), style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Colors.blue[700] : Colors.black87)),
                        trailing: isSelected ? Icon(Icons.check, color: Colors.blue[700], size: 20) : null,
                        onTap: () => Navigator.pop(context, item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class StockReceiptSubmitActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const StockReceiptSubmitActions({
    super.key,
    required this.isLoading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 8),
                        Text('Create'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  final double width;
  const _Header(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)));
  }
}

class StockItem {
  String? itemCode;
  int quantity = 1;
  double basicRate = 0;
  ProductItem? selectedProduct;
}
