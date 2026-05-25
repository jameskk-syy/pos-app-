import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/widgets/common/delete_confirmation_dialog.dart';

class StockEntryItemModel {
  String? itemCode;
  int quantity = 1;
  double basicRate = 0.0;
  String purpose = '';
  ProductItem? selectedProduct;
  final TextEditingController qtyController;
  final TextEditingController purposeController;

  StockEntryItemModel()
      : qtyController = TextEditingController(text: '1'),
        purposeController = TextEditingController();

  void dispose() {
    qtyController.dispose();
    purposeController.dispose();
  }
}

class StockEntryTypeSelector extends StatelessWidget {
  final String selectedType;
  final List<String> entryTypes;
  final ValueChanged<String?> onChanged;

  const StockEntryTypeSelector({
    super.key,
    required this.selectedType,
    required this.entryTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedType,
          items: entryTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class StockEntryWarehouseSection extends StatelessWidget {
  final String selectedType;
  final String? selectedSourceStoreName;
  final String? selectedTargetStoreName;
  final List<Warehouse> stores;
  final Function(String?) onSourceChanged;
  final Function(String?) onTargetChanged;

  const StockEntryWarehouseSection({
    super.key,
    required this.selectedType,
    required this.selectedSourceStoreName,
    required this.selectedTargetStoreName,
    required this.stores,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedType == 'Material Issue' || selectedType == 'Material Transfer') ...[
          const _Label('Source Warehouse*'),
          _StoreDropdown(
            selectedStoreName: selectedSourceStoreName,
            stores: stores,
            onChanged: onSourceChanged,
            hint: 'Source Warehouse',
          ),
          const SizedBox(height: 16),
        ],
        if (selectedType == 'Material Receipt' || selectedType == 'Material Transfer') ...[
          const _Label('Target Warehouse*'),
          _StoreDropdown(
            selectedStoreName: selectedTargetStoreName,
            stores: stores,
            onChanged: onTargetChanged,
            hint: 'Target Warehouse',
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _StoreDropdown extends StatelessWidget {
  final String? selectedStoreName;
  final List<Warehouse> stores;
  final ValueChanged<String?> onChanged;
  final String hint;

  const _StoreDropdown({
    required this.selectedStoreName,
    required this.stores,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                state is StoreStateLoading
                    ? 'Loading stores...'
                    : stores.isEmpty
                        ? 'No stores available'
                        : hint,
                style: const TextStyle(fontSize: 14),
              ),
              value: selectedStoreName,
              items: stores.map((store) {
                return DropdownMenuItem<String>(
                  value: store.name,
                  child: Text(
                    '${store.name}${store.isDefault ? ' (Default)' : ''}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}

class StockEntryItemsTable extends StatelessWidget {
  final String selectedType;
  final List<StockEntryItemModel> items;
  final List<ProductItem> products;
  final CurrentUserResponse? currentUserResponse;
  final VoidCallback onAddItem;
  final Function(int) onRemoveItem;
  final VoidCallback onStateChanged;

  const StockEntryItemsTable({
    super.key,
    required this.selectedType,
    required this.items,
    required this.products,
    this.currentUserResponse,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onStateChanged,
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _Header('Item Code*', 200),
                    const _Header('Qty*', 90),
                    if (selectedType == 'Material Receipt') const _Header('Basic Rate*', 100),
                    if (selectedType != 'Material Receipt') const _Header('Purpose', 160),
                    const _Header('', 50),
                  ],
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No items added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...items.asMap().entries.map((e) => StockEntryItemRow(
                        key: ValueKey(e.value),
                        item: e.value,
                        index: e.key,
                        selectedType: selectedType,
                        products: products,
                        currentUserResponse: currentUserResponse,
                        onRemove: () => onRemoveItem(e.key),
                        onChanged: onStateChanged,
                      )),
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
}

class StockEntryItemRow extends StatelessWidget {
  final StockEntryItemModel item;
  final int index;
  final String selectedType;
  final List<ProductItem> products;
  final CurrentUserResponse? currentUserResponse;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const StockEntryItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.selectedType,
    required this.products,
    this.currentUserResponse,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Code
          SizedBox(
            width: 200,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  return InkWell(
                    onTap: state is ProductsStateLoading || products.isEmpty
                        ? null
                        : () async {
                            final selected = await _showSearchableBottomSheet<ProductItem>(
                              context: context,
                              title: 'Select Item',
                              items: products,
                              displayLabel: (p) => '${p.itemCode} - ${p.itemName}',
                              currentValue: item.selectedProduct,
                              isProductSearch: true,
                              currentUserResponse: currentUserResponse,
                            );

                            if (selected != null) {
                              item.selectedProduct = selected;
                              item.itemCode = selected.itemCode;
                              item.basicRate = selected.standardRate;
                              onChanged();
                            }
                          },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
                      ),
                      child: Text(
                        item.selectedProduct != null
                            ? '${item.selectedProduct!.itemCode} - ${item.selectedProduct!.itemName}'
                            : state is ProductsStateLoading
                                ? 'Loading...'
                                : products.isEmpty
                                    ? 'No items'
                                    : 'Select Item',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Qty
          SizedBox(
            width: 90,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: item.qtyController,
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                onChanged: (value) {
                  item.quantity = int.tryParse(value) ?? 1;
                },
              ),
            ),
          ),

          // Rate
          if (selectedType == 'Material Receipt')
            SizedBox(
              width: 100,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextFormField(
                  initialValue: item.basicRate.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 12),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    item.basicRate = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
            ),

          // Purpose
          if (selectedType != 'Material Receipt')
            SizedBox(
              width: 160,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextFormField(
                  controller: item.purposeController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    hintText: 'Purpose',
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (value) {
                    item.purpose = value;
                  },
                ),
              ),
            ),

          // Delete
          SizedBox(
            width: 50,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                final confirmed = await DeleteConfirmationDialog.show(context);
                if (confirmed == true) {
                  onRemove();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StockEntrySubmitActions extends StatelessWidget {
  final bool isLoading;
  final String selectedType;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const StockEntrySubmitActions({
    super.key,
    required this.isLoading,
    required this.selectedType,
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
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'Create $selectedType',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}

Future<T?> _showSearchableBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) displayLabel,
  required T? currentValue,
  bool isProductSearch = false,
  CurrentUserResponse? currentUserResponse,
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
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                                  if (isProductSearch && currentUserResponse != null) {
                                    context.read<ProductsBloc>().add(
                                          GetAllProducts(
                                            company: currentUserResponse.message.company.name,
                                            searchTerm: '',
                                          ),
                                        );
                                  }
                                  setModalState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        if (debounce?.isActive ?? false) debounce!.cancel();
                        debounce = Timer(
                          const Duration(milliseconds: 500),
                          () {
                            if (isProductSearch && currentUserResponse != null) {
                              context.read<ProductsBloc>().add(
                                    GetAllProducts(
                                      company: currentUserResponse.message.company.name,
                                      searchTerm: val,
                                    ),
                                  );
                            }
                          },
                        );
                        setModalState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Expanded(
                    child: BlocBuilder<ProductsBloc, ProductsState>(
                      builder: (context, state) {
                        if (isProductSearch && state is ProductsStateLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        List<T> displayItems = items;
                        if (isProductSearch && state is ProductsStateSuccess) {
                          displayItems = state.productResponse.products as List<T>;
                        } else if (!isProductSearch) {
                          final query = searchController.text.toLowerCase();
                          displayItems = items
                              .where(
                                (item) => displayLabel(item).toLowerCase().contains(query),
                              )
                              .toList();
                        }

                        if (displayItems.isEmpty) {
                          return const Center(
                            child: Text(
                              'No results found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: displayItems.length,
                          itemBuilder: (context, index) {
                            final item = displayItems[index];
                            final isSelected = item == currentValue;

                            return ListTile(
                              title: Text(
                                displayLabel(item),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? Colors.blue[700] : Colors.black87,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.blue[700],
                                      size: 20,
                                    )
                                  : null,
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
