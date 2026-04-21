import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/suppliers/suppliers_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';

class PurchaseOrderSearchablePicker {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) displayLabel,
    required T? currentValue,
    bool isProductSearch = false,
    String? companyName,
  }) async {
    final searchController = TextEditingController();
    Timer? debounce;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 12),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    searchController.clear();
                                    if (isProductSearch && companyName != null) {
                                      context.read<ProductsBloc>().add(GetAllProducts(company: companyName, searchTerm: ''));
                                    }
                                    setModalState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) {
                          if (debounce?.isActive ?? false) debounce!.cancel();
                          debounce = Timer(const Duration(milliseconds: 500), () {
                            if (isProductSearch && companyName != null) {
                              context.read<ProductsBloc>().add(GetAllProducts(company: companyName, searchTerm: val));
                            }
                          });
                          setModalState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    Expanded(
                      child: BlocBuilder<ProductsBloc, ProductsState>(
                        builder: (context, state) {
                          if (isProductSearch && state is ProductsStateLoading) return const Center(child: CircularProgressIndicator());
                          List<T> displayItems = items;
                          if (isProductSearch && state is ProductsStateSuccess) {
                            displayItems = state.productResponse.products as List<T>;
                          } else if (!isProductSearch) {
                            final query = searchController.text.toLowerCase();
                            displayItems = items.where((item) => displayLabel(item).toLowerCase().contains(query)).toList();
                          }
                          if (displayItems.isEmpty) return const Center(child: Text('No results found', style: TextStyle(color: Colors.grey)));
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: displayItems.length,
                            itemBuilder: (context, index) {
                              final item = displayItems[index];
                              final isSelected = item == currentValue;
                              return ListTile(
                                title: Text(displayLabel(item), style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Colors.blue[700] : Colors.black87)),
                                trailing: isSelected ? Icon(Icons.check, color: Colors.blue[700], size: 20) : null,
                                onTap: () => Navigator.pop(ctx, item),
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
          },
        );
      },
    );
  }
}

class PurchaseOrderHeaderFields extends StatelessWidget {
  final List<Supplier> suppliers;
  final Supplier? selectedSupplier;
  final Function(Supplier?) onSupplierChanged;
  final List<Warehouse> stores;
  final Warehouse? selectedStore;
  final Function(Warehouse?) onStoreChanged;
  final DateTime postingDate;
  final VoidCallback onDateTap;

  const PurchaseOrderHeaderFields({
    super.key,
    required this.suppliers,
    required this.selectedSupplier,
    required this.onSupplierChanged,
    required this.stores,
    required this.selectedStore,
    required this.onStoreChanged,
    required this.postingDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Suppliers*'),
        _dropdown<Supplier>(
          hint: 'Choose a supplier',
          value: selectedSupplier,
          items: suppliers,
          onChanged: onSupplierChanged,
          displayLabel: (s) => s.supplierName,
        ),
        const SizedBox(height: 16),
        _label('Default Warehouse*'),
        _dropdown<Warehouse>(
          hint: 'Choose a warehouse',
          value: selectedStore,
          items: stores,
          onChanged: onStoreChanged,
          displayLabel: (w) => w.name,
        ),
        const SizedBox(height: 16),
        _label('Posting Date*'),
        InkWell(
          onTap: onDateTap,
          child: _inputBox('${postingDate.day}/${postingDate.month}/${postingDate.year}', Icons.calendar_today),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));

  Widget _dropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required String Function(T) displayLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          value: value,
          items: items.map((item) => DropdownMenuItem<T>(value: item, child: Text(displayLabel(item), style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _inputBox(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(text), Icon(icon, size: 18, color: Colors.grey)]),
    );
  }
}

class PurchaseOrderItemsTable extends StatelessWidget {
  final List<dynamic> items; // List<StockItem>
  final List<ProductItem> products;
  final List<Warehouse> stores;
  final VoidCallback onAddItem;
  final Function(int) onRemoveItem;
  final Function(int, ProductItem) onProductSelected;
  final double subtotal;
  final bool isLoadingProducts;

  final String? companyName;

  const PurchaseOrderItemsTable({
    super.key,
    required this.items,
    required this.products,
    required this.stores,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onProductSelected,
    required this.subtotal,
    this.companyName,
    this.isLoadingProducts = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildTable(context),
          const SizedBox(height: 12),
          _buildSubtotal(),
          const SizedBox(height: 12),
          TextButton.icon(onPressed: onAddItem, icon: const Icon(Icons.add), label: const Text('Add Item')),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: const [
              _Header('Item Code*', 200),
              _Header('Quantity*', 100),
              _Header('Rate', 100),
              _Header('Amount', 100),
              _Header('Warehouse', 150),
              _Header('Schedule Date', 150),
              _Header('Actions', 80),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('No items added', style: TextStyle(fontSize: 12, color: Colors.grey))
          else
            ...items.asMap().entries.map((e) => PurchaseOrderItemRow(
              index: e.key,
              item: e.value,
              products: products,
              stores: stores,
              onRemove: () => onRemoveItem(e.key),
              onProductSelected: (p) => onProductSelected(e.key, p),
              isLoadingProducts: isLoadingProducts,
              companyName: companyName,
            )),
        ],
      ),
    );
  }

  Widget _buildSubtotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Subtotal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(width: 24),
        Text('KES ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue)),
      ],
    );
  }
}

class PurchaseOrderItemRow extends StatefulWidget {
  final int index;
  final dynamic item; // StockItem
  final List<ProductItem> products;
  final List<Warehouse> stores;
  final VoidCallback onRemove;
  final Function(ProductItem) onProductSelected;
  final bool isLoadingProducts;
  final String? companyName;

  const PurchaseOrderItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.products,
    required this.stores,
    required this.onRemove,
    required this.onProductSelected,
    this.isLoadingProducts = false,
    this.companyName,
  });

  @override
  State<PurchaseOrderItemRow> createState() => _PurchaseOrderItemRowState();
}

class _PurchaseOrderItemRowState extends State<PurchaseOrderItemRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _buildItemPicker(context),
          _buildQtyField(),
          _buildRateField(),
          _buildAmountField(),
          _buildWarehouseDropdown(),
          _buildDateField(context),
          _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildItemPicker(BuildContext context) {
    return SizedBox(
      width: 200, height: 40,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
        child: InkWell(
          onTap: (widget.products.isEmpty && !widget.isLoadingProducts && widget.companyName == null) ? null : () async {
            final selected = await PurchaseOrderSearchablePicker.show<ProductItem>(
              context: context,
              title: 'Select Item',
              items: widget.products,
              displayLabel: (p) => '${p.itemCode} - ${p.itemName}',
              currentValue: widget.item.selectedProduct,
              isProductSearch: true,
              companyName: widget.companyName,
            );
            if (selected != null) widget.onProductSelected(selected);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(widget.item.selectedProduct != null ? '${widget.item.selectedProduct!.itemCode} - ${widget.item.selectedProduct!.itemName}' : (widget.isLoadingProducts ? 'Loading...' : 'Select Item'), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyField() {
    return _tableInput(100, widget.item.qtyController, (v) {
      setState(() {
        widget.item.quantity = int.tryParse(v) ?? 1;
        (context as Element).markNeedsBuild(); // Trigger parent subtotal recalc if possible or use callbacks
      });
    });
  }

  Widget _buildRateField() {
    return _tableInput(100, widget.item.rateController, (v) {
      setState(() {
        widget.item.rate = double.tryParse(v) ?? 0.0;
        (context as Element).markNeedsBuild();
      });
    });
  }

  Widget _tableInput(double width, TextEditingController controller, Function(String) onChanged) {
    return SizedBox(
      width: width, height: 40,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade200)),
        child: TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 12),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return SizedBox(
      width: 100, height: 40,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
        child: Text('KES ${(widget.item.quantity * widget.item.rate).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return SizedBox(
      width: 150, height: 40,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Warehouse>(
            isExpanded: true, style: const TextStyle(fontSize: 12),
            hint: const Text('Select...', style: TextStyle(fontSize: 12)),
            value: widget.item.warehouse,
            items: widget.stores.map((s) => DropdownMenuItem<Warehouse>(value: s, child: Text(s.name, style: const TextStyle(fontSize: 12, color: Colors.black), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) { if (v != null) setState(() => widget.item.warehouse = v); },
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return SizedBox(
      width: 150, height: 40,
      child: InkWell(
        onTap: () async {
          final p = await showDatePicker(context: context, initialDate: widget.item.scheduleDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2035));
          if (p != null) setState(() => widget.item.scheduleDate = p);
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.item.scheduleDate != null ? '${widget.item.scheduleDate!.day}/${widget.item.scheduleDate!.month}/${widget.item.scheduleDate!.year}' : '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(fontSize: 12)),
            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
          ]),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(width: 80, height: 40, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey), onPressed: widget.onRemove));
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

class PurchaseOrderBottomButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const PurchaseOrderBottomButtons({
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
          Expanded(child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Cancel'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, size: 18), SizedBox(width: 8), Text('Create Purchase Order')]),
          )),
        ],
      ),
    );
  }
}
