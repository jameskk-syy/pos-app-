import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportFilterCard extends StatefulWidget {
  final Function(String? startDate, String? endDate, String? warehouse, String? itemGroup, String? paymentMethod) onApply;
  final List<String> warehouses;
  final List<String> itemGroups;
  final List<String> paymentMethods;
  final bool showPaymentMethod;

  const ReportFilterCard({
    super.key,
    required this.onApply,
    this.warehouses = const [],
    this.itemGroups = const [],
    this.paymentMethods = const [],
    this.showPaymentMethod = true,
  });

  @override
  State<ReportFilterCard> createState() => _ReportFilterCardState();
}

class _ReportFilterCardState extends State<ReportFilterCard> {
  bool _isExpanded = false;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedWarehouse;
  String? _selectedItemGroup;
  String? _selectedPaymentMethod;

  final DateFormat _df = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.filter_list, color: Colors.blue),
            title: const Text(
              "Report Filters",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          label: "Start Date",
                          value: _startDate,
                          onTap: () => _selectDate(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker(
                          label: "End Date",
                          value: _endDate,
                          onTap: () => _selectDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: "Warehouse",
                          value: _selectedWarehouse,
                          items: widget.warehouses,
                          onChanged: (val) => setState(() => _selectedWarehouse = val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: "Item Group",
                          value: _selectedItemGroup,
                          items: widget.itemGroups,
                          onChanged: (val) => setState(() => _selectedItemGroup = val),
                        ),
                      ),
                    ],
                  ),
                  if (widget.showPaymentMethod) ...[
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: "Payment Method",
                      value: _selectedPaymentMethod,
                      items: widget.paymentMethods,
                      onChanged: (val) => setState(() => _selectedPaymentMethod = val),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _reset,
                        child: const Text("Reset", style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _apply,
                        child: const Text("Apply Filters"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({required String label, DateTime? value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value != null ? _df.format(value) : "Select Date",
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, String? value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 13, color: Colors.black),
      items: [
        const DropdownMenuItem(value: null, child: Text("All", style: TextStyle(fontSize: 13))),
        ...items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))),
      ],
      onChanged: onChanged,
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _reset() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedWarehouse = null;
      _selectedItemGroup = null;
      _selectedPaymentMethod = null;
    });
    _apply();
  }

  void _apply() {
    widget.onApply(
      _startDate != null ? _df.format(_startDate!) : null,
      _endDate != null ? _df.format(_endDate!) : null,
      _selectedWarehouse,
      _selectedItemGroup,
      _selectedPaymentMethod,
    );
  }
}
