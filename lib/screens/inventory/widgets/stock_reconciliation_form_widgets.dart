import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/products/item_list.dart';

class ItemRow {
  String? itemCode;
  String? itemName;
  double systemQty;
  double physicalQty;
  double difference;
  double valuationRate;
  String stockUom;
  late TextEditingController physicalQtyController;

  ItemRow({
    required this.itemCode,
    required this.itemName,
    required this.systemQty,
    required this.physicalQty,
    required this.difference,
    required this.valuationRate,
    required this.stockUom,
  }) {
    physicalQtyController = TextEditingController(
      text: physicalQty == 0 ? '' : physicalQty.toStringAsFixed(2),
    );
  }

  void dispose() {
    physicalQtyController.dispose();
  }
}

class ReconciliationHeader extends StatelessWidget {
  final String? selectedWarehouse;
  final List<Warehouse> warehouses;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Function(String?) onWarehouseChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const ReconciliationHeader({
    super.key,
    required this.selectedWarehouse,
    required this.warehouses,
    required this.selectedDate,
    required this.selectedTime,
    required this.onWarehouseChanged,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWarehouseField(),
        const SizedBox(height: 20),
        _buildPostingDateField(),
        const SizedBox(height: 20),
        _buildPostingTimeField(),
      ],
    );
  }

  Widget _buildWarehouseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Warehouse',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedWarehouse,
          decoration: const InputDecoration(
            hintText: 'Choose a warehouse',
            hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          items: warehouses.map((warehouse) {
            return DropdownMenuItem(
              value: warehouse.name,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    warehouse.warehouseName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (warehouse.warehouseType != null)
                    Text(
                      warehouse.warehouseType!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: onWarehouseChanged,
        ),
        if (selectedWarehouse != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildWarehouseInfo(),
          ),
      ],
    );
  }

  Widget _buildWarehouseInfo() {
    final warehouse = warehouses.firstWhere((w) => w.name == selectedWarehouse);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                warehouse.company,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          if (warehouse.addressLine1 != null || warehouse.city != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      warehouse.addressLine1,
                      warehouse.city,
                      warehouse.state,
                    ].where((e) => e != null && e.isNotEmpty).join(', '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostingDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Posting Date',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onSelectDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostingTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Posting Time',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onSelectTime,
          child: InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Optional (HH:MM:SS)',
          style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }
}

class ReconciliationTable extends StatelessWidget {
  final List<ItemRow> items;
  final List<StockItem> stockItems;
  final bool isLoadingItems;
  final VoidCallback onAddItem;
  final Function(int) onDeleteItem;
  final Function(int, String?) onItemChanged;
  final Function(int, String) onPhysicalQtyChanged;

  const ReconciliationTable({
    super.key,
    required this.items,
    required this.stockItems,
    required this.isLoadingItems,
    required this.onAddItem,
    required this.onDeleteItem,
    required this.onItemChanged,
    required this.onPhysicalQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (isLoadingItems) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Optional: Add inventory details (buying price, selling price, UOM, SKU, expiry, batch) to create / update warehouse-specific inventory details.',
          style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 16),
        _buildItemsTable(context),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: stockItems.isEmpty ? null : onAddItem,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Item'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(horizontal: 0),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              ...items.asMap().entries.map((entry) {
                return ReconciliationRow(
                  index: entry.key,
                  item: entry.value,
                  stockItems: stockItems,
                  onDeleteItem: onDeleteItem,
                  onItemChanged: onItemChanged,
                  onPhysicalQtyChanged: onPhysicalQtyChanged,
                  isOnlyItem: items.length == 1,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: Row(
              children: const [
                Text(
                  'Item Code',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text('*', style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(
            width: 120,
            child: Text(
              'System Qty',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: const [
                Text(
                  'Physical Qty',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text('*', style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(
            width: 120,
            child: Text(
              'Difference',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            width: 120,
            child: Text(
              'Valuation Rate',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class ReconciliationRow extends StatelessWidget {
  final int index;
  final ItemRow item;
  final List<StockItem> stockItems;
  final Function(int) onDeleteItem;
  final Function(int, String?) onItemChanged;
  final Function(int, String) onPhysicalQtyChanged;
  final bool isOnlyItem;

  const ReconciliationRow({
    super.key,
    required this.index,
    required this.item,
    required this.stockItems,
    required this.onDeleteItem,
    required this.onItemChanged,
    required this.onPhysicalQtyChanged,
    required this.isOnlyItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              initialValue: item.itemCode,
              decoration: const InputDecoration(
                hintText: 'Select item',
                hintStyle: TextStyle(fontSize: 12),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              isExpanded: true,
              items: stockItems.map((stockItem) {
                return DropdownMenuItem(
                  value: stockItem.name,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stockItem.itemName,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${stockItem.itemCode} • ${stockItem.stockUom}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => onItemChanged(index, val),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              item.systemQty.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: item.physicalQtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              onChanged: (val) => onPhysicalQtyChanged(index, val),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              item.difference.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 12,
                color: item.difference == 0
                    ? Colors.black
                    : item.difference > 0
                        ? Colors.green
                        : Colors.red,
                fontWeight: item.difference != 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              item.valuationRate.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 40,
            child: !isOnlyItem
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red,
                    onPressed: () => onDeleteItem(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class ReconciliationSubmitActions extends StatelessWidget {
  final bool isSubmitting;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const ReconciliationSubmitActions({
    super.key,
    required this.isSubmitting,
    required this.canSubmit,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSubmitting ? null : onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (canSubmit && !isSubmitting) ? onSubmit : null,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.add, size: 20),
              label: Text(
                isSubmitting ? 'Creating...' : 'Create',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                disabledForegroundColor: const Color(0xFF9E9E9E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
