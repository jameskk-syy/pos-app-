import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/products/item_group.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';

class SearchablePickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) displayLabel;
  final T? currentValue;
  final bool isProductSearch;
  final CurrentUserResponse? currentUserResponse;

  const SearchablePickerSheet({
    super.key,
    required this.title,
    required this.items,
    required this.displayLabel,
    this.currentValue,
    this.isProductSearch = false,
    this.currentUserResponse,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) displayLabel,
    T? currentValue,
    bool isProductSearch = false,
    CurrentUserResponse? currentUserResponse,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SearchablePickerSheet<T>(
        title: title,
        items: items,
        displayLabel: displayLabel,
        currentValue: currentValue,
        isProductSearch: isProductSearch,
        currentUserResponse: currentUserResponse,
      ),
    );
  }

  @override
  State<SearchablePickerSheet<T>> createState() => _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<SearchablePickerSheet<T>> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                widget.title,
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
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            if (widget.isProductSearch && widget.currentUserResponse != null) {
                              context.read<ProductsBloc>().add(
                                    GetAllProducts(
                                      company: widget.currentUserResponse!.message.company.name,
                                      searchTerm: '',
                                    ),
                                  );
                            }
                            setState(() {});
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
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      if (widget.isProductSearch && widget.currentUserResponse != null) {
                        context.read<ProductsBloc>().add(
                              GetAllProducts(
                                company: widget.currentUserResponse!.message.company.name,
                                searchTerm: val,
                              ),
                            );
                      }
                    },
                  );
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (widget.isProductSearch && state is ProductsStateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<T> displayItems = widget.items;
                  if (widget.isProductSearch && state is ProductsStateSuccess) {
                    displayItems = state.productResponse.products as List<T>;
                  } else if (!widget.isProductSearch) {
                    final query = _searchController.text.toLowerCase();
                    displayItems = widget.items
                        .where((item) => widget.displayLabel(item).toLowerCase().contains(query))
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
                      final isSelected = item == widget.currentValue;

                      return ListTile(
                        title: Text(
                          widget.displayLabel(item),
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

class RuleTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const RuleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rule Type *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'Item',
              label: Text('Item'),
              icon: Icon(Icons.category, size: 18),
            ),
            ButtonSegment<String>(
              value: 'Batch',
              label: Text('Batch'),
              icon: Icon(Icons.inventory, size: 18),
            ),
            ButtonSegment<String>(
              value: 'ItemGroup',
              label: Text(
                'Item Group',
                style: TextStyle(fontSize: 12),
              ),
              icon: Icon(Icons.group_work, size: 18),
            ),
          ],
          selected: {selectedType},
          onSelectionChanged: (Set<String> newSelection) {
            onTypeChanged(newSelection.first);
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.grey[100],
            selectedBackgroundColor: const Color(0xFF1976F3),
            selectedForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ],
    );
  }
}

class DiscountValueSection extends StatelessWidget {
  final String selectedDiscountType;
  final TextEditingController valueController;
  final ValueChanged<String> onTypeChanged;

  const DiscountValueSection({
    super.key,
    required this.selectedDiscountType,
    required this.valueController,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discount Type *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'Percentage',
              label: Text('Percentage'),
              icon: Icon(Icons.percent, size: 18),
            ),
            ButtonSegment<String>(
              value: 'Amount',
              label: Text('Fixed Amount'),
              icon: Icon(Icons.money, size: 18),
            ),
          ],
          selected: {selectedDiscountType},
          onSelectionChanged: (Set<String> newSelection) {
            onTypeChanged(newSelection.first);
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.grey[100],
            selectedBackgroundColor: const Color(0xFF1976F3),
            selectedForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discount ${selectedDiscountType == 'Percentage' ? 'Percentage' : 'Amount'} *',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            if (selectedDiscountType == 'Percentage')
              const Text(
                '(0-100%)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: selectedDiscountType == 'Percentage' ? '0' : '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    selectedDiscountType == 'Percentage' ? '%' : 'KES',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AdditionalSettingsSection extends StatelessWidget {
  final DateTime? validFrom;
  final DateTime? validUpto;
  final VoidCallback onSelectFromDate;
  final VoidCallback onSelectUptoDate;
  final TextEditingController descriptionController;
  final bool isActive;
  final ValueChanged<bool> onStatusChanged;

  const AdditionalSettingsSection({
    super.key,
    required this.validFrom,
    required this.validUpto,
    required this.onSelectFromDate,
    required this.onSelectUptoDate,
    required this.descriptionController,
    required this.isActive,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Validity Period (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onSelectFromDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            validFrom != null
                                ? DateFormat('MM/dd/yyyy').format(validFrom!)
                                : 'mm/dd/yyyy',
                            style: TextStyle(
                              color: validFrom != null ? Colors.black : Colors.grey[400],
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: onSelectUptoDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            validUpto != null
                                ? DateFormat('MM/dd/yyyy').format(validUpto!)
                                : 'mm/dd/yyyy',
                            style: TextStyle(
                              color: validUpto != null ? Colors.black : Colors.grey[400],
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Leave empty for unlimited validity',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Description (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add notes or comments about this rule',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Rule Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
          value: isActive,
          onChanged: onStatusChanged,
          activeThumbColor: const Color(0xFF1976F3),
        ),
        const SizedBox(height: 8),
        const Text(
          'Active rules will be applied',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class RuleSpecificFields extends StatelessWidget {
  final String selectedRuleType;
  final bool loadingItems;
  final bool loadingItemGroups;
  final List<ProductItem> items;
  final List<ItemGroup> itemGroups;
  final String? selectedItem;
  final String? selectedItemGroup;
  final TextEditingController batchNoController;
  final CurrentUserResponse? currentUserResponse;
  final void Function(String?) onItemChanged;
  final void Function(String?) onItemGroupChanged;

  const RuleSpecificFields({
    super.key,
    required this.selectedRuleType,
    required this.loadingItems,
    required this.loadingItemGroups,
    required this.items,
    required this.itemGroups,
    required this.selectedItem,
    required this.selectedItemGroup,
    required this.batchNoController,
    this.currentUserResponse,
    required this.onItemChanged,
    required this.onItemGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedRuleType == 'Item') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          loadingItems
              ? _buildLoadingContainer('Loading items...')
              : InkWell(
                  onTap: items.isEmpty
                      ? null
                      : () async {
                          final selected = await SearchablePickerSheet.show<ProductItem>(
                            context: context,
                            title: 'Select Item',
                            items: items,
                            displayLabel: (p) => '${p.itemCode} - ${p.itemName}',
                            currentValue: items.where((i) => i.itemCode == selectedItem).firstOrNull,
                            isProductSearch: true,
                            currentUserResponse: currentUserResponse,
                          );
                          if (selected != null) onItemChanged(selected.itemCode);
                        },
                  child: _buildPickerContainer(
                    selectedItem != null
                        ? items.firstWhere((i) => i.itemCode == selectedItem).itemName
                        : 'Select Item',
                    selectedItem != null,
                  ),
                ),
        ],
      );
    } else if (selectedRuleType == 'Batch') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Batch Number *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: batchNoController,
            decoration: InputDecoration(
              hintText: 'Enter batch number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      );
    } else if (selectedRuleType == 'ItemGroup') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item Group *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          loadingItemGroups
              ? _buildLoadingContainer('Loading item groups...')
              : InkWell(
                  onTap: itemGroups.isEmpty
                      ? null
                      : () async {
                          final selected = await SearchablePickerSheet.show<ItemGroup>(
                            context: context,
                            title: 'Select Item Group',
                            items: itemGroups,
                            displayLabel: (g) => g.itemGroupName,
                            currentValue:
                                itemGroups.where((g) => g.name == selectedItemGroup).firstOrNull,
                          );
                          if (selected != null) onItemGroupChanged(selected.name);
                        },
                  child: _buildPickerContainer(
                    selectedItemGroup != null
                        ? itemGroups.firstWhere((g) => g.name == selectedItemGroup).itemGroupName
                        : 'Select Item Group',
                    selectedItemGroup != null,
                  ),
                ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingContainer(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPickerContainer(String text, bool hasValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: hasValue ? Colors.black87 : Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }
}
