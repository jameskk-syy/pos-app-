import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/widgets/common/delete_confirmation_dialog.dart';
import 'dart:async';

class WarehouseSelector extends StatelessWidget {
  final Warehouse? selectedSourceStore;
  final Warehouse? selectedTargetStore;
  final List<Warehouse> stores;
  final Function(Warehouse?) onSourceChanged;
  final Function(Warehouse?) onTargetChanged;

  const WarehouseSelector({
    super.key,
    required this.selectedSourceStore,
    required this.selectedTargetStore,
    required this.stores,
    required this.onSourceChanged,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Source Warehouse*'),
        _storeDropdown(context, isSource: true),
        const SizedBox(height: 16),
        _label('Target Warehouse*'),
        _storeDropdown(context, isSource: false),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _storeDropdown(BuildContext context, {required bool isSource}) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        final selectedStore = isSource ? selectedSourceStore : selectedTargetStore;

        return DropdownButtonFormField<Warehouse>(
          isExpanded: true,
          hint: Text(
            state is StoreStateLoading
                ? 'Loading stores...'
                : stores.isEmpty
                    ? 'No stores available'
                    : 'Choose a warehouse',
          ),
          initialValue: selectedStore,
          items: stores.map((store) {
            return DropdownMenuItem<Warehouse>(
              value: store,
              child: Text(
                '${store.warehouseName}${store.isDefault ? ' (Default)' : ''}',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: isSource ? onSourceChanged : onTargetChanged,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        );
      },
    );
  }
}

class DateAndTimeFields extends StatelessWidget {
  final DateTime postingDate;
  final DateTime scheduleDate;
  final TimeOfDay postingTime;
  final VoidCallback onSelectPostingDate;
  final VoidCallback onSelectScheduleDate;
  final VoidCallback onSelectPostingTime;

  const DateAndTimeFields({
    super.key,
    required this.postingDate,
    required this.scheduleDate,
    required this.postingTime,
    required this.onSelectPostingDate,
    required this.onSelectScheduleDate,
    required this.onSelectPostingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Transaction Date*'),
        _dateBox('${postingDate.day}/${postingDate.month}/${postingDate.year}', onSelectPostingDate),
        const SizedBox(height: 16),
        _label('Schedule Date*'),
        _dateBox('${scheduleDate.day}/${scheduleDate.month}/${scheduleDate.year}', onSelectScheduleDate),
        const SizedBox(height: 16),
        _label('Posting Time'),
        _dateBox(
          '${postingTime.hour.toString().padLeft(2, '0')}:${postingTime.minute.toString().padLeft(2, '0')}:00',
          onSelectPostingTime,
          icon: Icons.access_time,
        ),
        const SizedBox(height: 4),
        const Text(
          'Optional (HH:MM:SS)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _dateBox(String text, VoidCallback onTap, {IconData icon = Icons.calendar_today}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            Icon(icon, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class StockItemsTable extends StatelessWidget {
  final List<dynamic> items; // Will use dynamic to avoid circular ref or define StockItem separately
  final List<ProductItem> products;
  final VoidCallback onAddItem;
  final Function(int) onDeleteItem;
  final Function(int, ProductItem) onItemChanged;
  final Function(int, String) onQtyChanged;
  final Function(int, String) onPurposeChanged;
  final CurrentUserResponse? currentUserResponse;

  const StockItemsTable({
    super.key,
    required this.items,
    required this.products,
    required this.onAddItem,
    required this.onDeleteItem,
    required this.onItemChanged,
    required this.onQtyChanged,
    required this.onPurposeChanged,
    this.currentUserResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  children: const [
                    _Header('Item Code*', 200),
                    _Header('Qty*', 90),
                    _Header('Purpose*', 160),
                    _Header('', 50),
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
                  ...items.asMap().entries.map((e) {
                    final index = e.key;
                    final item = e.value;
                    return StockItemRow(
                      index: index,
                      item: item,
                      products: products,
                      onDeleteItem: () => onDeleteItem(index),
                      onItemChanged: (p) => onItemChanged(index, p),
                      onQtyChanged: (v) => onQtyChanged(index, v),
                      onPurposeChanged: (v) => onPurposeChanged(index, v),
                      currentUserResponse: currentUserResponse,
                    );
                  }),
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

class StockItemRow extends StatelessWidget {
  final int index;
  final dynamic item;
  final List<ProductItem> products;
  final VoidCallback onDeleteItem;
  final Function(ProductItem) onItemChanged;
  final Function(String) onQtyChanged;
  final Function(String) onPurposeChanged;
  final CurrentUserResponse? currentUserResponse;

  const StockItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.products,
    required this.onDeleteItem,
    required this.onItemChanged,
    required this.onQtyChanged,
    required this.onPurposeChanged,
    this.currentUserResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Code Dropdown
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
                              onItemChanged(selected);
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

          // Quantity field
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
                onChanged: onQtyChanged,
              ),
            ),
          ),

          // Purpose field
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
                  hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onChanged: onPurposeChanged,
              ),
            ),
          ),

          // Delete button
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
                  onDeleteItem();
                }
              },
            ),
          ),
        ],
      ),
    );
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
