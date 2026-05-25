import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/inventory_discount_rule.dart';
import 'package:pos/domain/responses/sales/store_response.dart';

class DiscountRulesFilters extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final String? selectedRuleType;
  final List<String> ruleTypeOptions;
  final Function(String?) onRuleTypeChanged;
  final List<Warehouse> warehouses;
  final String? selectedWarehouse;
  final Function(String?) onWarehouseChanged;
  final List<String> discountTypeOptions;
  final String? selectedDiscountType;
  final Function(String?) onDiscountTypeChanged;
  final List<Map<String, dynamic>> statusOptions;
  final int? selectedStatus;
  final Function(String?) onStatusChanged;
  final String? searchTerm;
  final Function(String) onSearchChanged;
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onSelectFromDate;
  final VoidCallback onSelectToDate;
  final VoidCallback onReset;
  final VoidCallback onApply;
  final bool warehousesLoaded;

  const DiscountRulesFilters({
    super.key,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.selectedRuleType,
    required this.ruleTypeOptions,
    required this.onRuleTypeChanged,
    required this.warehouses,
    required this.selectedWarehouse,
    required this.onWarehouseChanged,
    required this.discountTypeOptions,
    required this.selectedDiscountType,
    required this.onDiscountTypeChanged,
    required this.statusOptions,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.fromDate,
    required this.toDate,
    required this.onSelectFromDate,
    required this.onSelectToDate,
    required this.onReset,
    required this.onApply,
    required this.warehousesLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: Row(
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dropdownField(
                    "Rule Type",
                    selectedRuleType,
                    ruleTypeOptions,
                    onRuleTypeChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: warehousesLoaded
                      ? _dropdownField(
                          "Warehouse",
                          selectedWarehouse,
                          warehouses.map((w) => w.name).toList(),
                          onWarehouseChanged,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: _inputDecoration(),
                          child: const Text(
                            'Loading warehouses...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dropdownField(
                    "Discount Type",
                    selectedDiscountType,
                    discountTypeOptions,
                    onDiscountTypeChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdownField(
                    "Status",
                    statusOptions.firstWhere(
                      (s) => s['value'] == selectedStatus,
                      orElse: () => statusOptions.first,
                    )['label'],
                    statusOptions.map((s) => s['label'] as String).toList(),
                    onStatusChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    "Search (Item Code/Batch/Description)",
                    searchTerm,
                    onSearchChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    "Valid From",
                    fromDate,
                    onSelectFromDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField(
                    "Valid To",
                    toDate,
                    onSelectToDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text(
                      "Reset Filters",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(color: Colors.white),
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

  Widget _dropdownField(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _inputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField(String hint, String? value, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1976F3), width: 0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1976F3), width: 0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
      controller: TextEditingController(text: value ?? '')..selection = TextSelection.fromPosition(TextPosition(offset: (value ?? '').length)),
    );
  }

  Widget _dateField(String hint, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: _inputDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('dd MMM yyyy').format(date) : hint,
              style: TextStyle(
                color: date != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.6),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.4),
    );
  }
}

class DiscountRulesTable extends StatelessWidget {
  final bool isLoading;
  final List<InventoryDiscountRule> rules;
  final Function(InventoryDiscountRule) onActionMenu;

  const DiscountRulesTable({
    super.key,
    required this.isLoading,
    required this.rules,
    required this.onActionMenu,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && rules.isEmpty) {
      return Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(40),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (rules.isEmpty) {
      return Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(40),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.discount, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No discount rules found',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          columns: const [
            DataColumn(label: Text("Rule Name")),
            DataColumn(label: Text("Rule Type")),
            DataColumn(label: Text("Item Code")),
            DataColumn(label: Text("Warehouse")),
            DataColumn(label: Text("Discount Type")),
            DataColumn(label: Text("Discount Value")),
            DataColumn(label: Text("Priority")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Valid From")),
            DataColumn(label: Text("Valid Until")),
            DataColumn(label: Text("Actions")),
          ],
          rows: rules.map((rule) {
            String validFrom = rule.validFrom ?? 'N/A';
            if (rule.validFrom != null) {
              final date = DateTime.tryParse(rule.validFrom!);
              if (date != null) {
                validFrom = DateFormat('dd MMM yyyy').format(date);
              }
            }

            String validUpto = rule.validUpto ?? 'N/A';
            if (rule.validUpto != null) {
              final date = DateTime.tryParse(rule.validUpto!);
              if (date != null) {
                validUpto = DateFormat('dd MMM yyyy').format(date);
              }
            }

            return DataRow(
              cells: [
                DataCell(Text(rule.name)),
                DataCell(Text(rule.ruleType)),
                DataCell(Text(rule.itemCode)),
                DataCell(Text(rule.warehouse)),
                DataCell(Text(rule.discountType)),
                DataCell(Text('${rule.discountValue}${rule.discountType == 'Percentage' ? '%' : ''}')),
                DataCell(Text(rule.priority.toString())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: rule.statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rule.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                DataCell(Text(validFrom)),
                DataCell(Text(validUpto)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => onActionMenu(rule),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.4),
    );
  }
}

class DiscountRuleDetailsDialog extends StatelessWidget {
  final InventoryDiscountRule rule;

  const DiscountRuleDetailsDialog({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 800, minWidth: 600),
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.discount, color: Color(0xFF1976F3)),
                const SizedBox(width: 12),
                const Text(
                  'Discount Rule Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Rule Name', rule.name),
                    const Divider(height: 24),
                    _detailRow('Rule Type', rule.ruleType),
                    const Divider(height: 24),
                    _detailRow('Item Code', rule.itemCode),
                    const Divider(height: 24),
                    _detailRow('Warehouse', rule.warehouse),
                    const Divider(height: 24),
                    _detailRow('Batch No', rule.batchNo ?? 'N/A'),
                    const Divider(height: 24),
                    _detailRow('Item Group', rule.itemGroup ?? 'N/A'),
                    const Divider(height: 24),
                    _detailRow('Company', rule.company),
                    const Divider(height: 24),
                    _detailRow('Discount Type', rule.discountType),
                    const Divider(height: 24),
                    _detailRow('Discount Value', rule.discountValue.toString()),
                    const Divider(height: 24),
                    _detailRow('Priority', rule.priority.toString()),
                    const Divider(height: 24),
                    _detailRow('Status', rule.status, valueColor: rule.statusColor),
                    const Divider(height: 24),
                    _detailRow('Valid From', rule.validFrom ?? 'N/A'),
                    const Divider(height: 24),
                    _detailRow('Valid Until', rule.validUpto ?? 'N/A'),
                    const Divider(height: 24),
                    _detailRow('Description', rule.description ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiscountRuleActionMenu extends StatelessWidget {
  final InventoryDiscountRule rule;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback? onDeactivate;
  final VoidCallback? onActivate;

  const DiscountRuleActionMenu({
    super.key,
    required this.rule,
    required this.onViewDetails,
    required this.onEdit,
    this.onDeactivate,
    this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility, color: Colors.blue),
            title: const Text('View Details'),
            onTap: onViewDetails,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.orange),
            title: const Text('Edit Rule'),
            onTap: onEdit,
          ),
          if (rule.isActive == 1 && onDeactivate != null)
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Deactivate Rule'),
              onTap: onDeactivate,
            ),
          if (rule.isActive == 0 && onActivate != null)
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: const Text('Activate Rule'),
              onTap: onActivate,
            ),
        ],
      ),
    );
  }
}
