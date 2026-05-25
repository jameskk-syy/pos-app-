import 'package:flutter/material.dart';
import 'package:pos/domain/responses/suppliers/suppliers_response.dart';

class SupplierFilterSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final TextEditingController searchController;
  final String? selectedGroup;
  final String? selectedType;
  final String? selectedCountry;
  final List<String> groups;
  final List<String> types;
  final List<String> countries;
  final Function(String?) onGroupChanged;
  final Function(String?) onTypeChanged;
  final Function(String?) onCountryChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const SupplierFilterSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.searchController,
    required this.selectedGroup,
    required this.selectedType,
    required this.selectedCountry,
    required this.groups,
    required this.types,
    required this.countries,
    required this.onGroupChanged,
    required this.onTypeChanged,
    required this.onCountryChanged,
    required this.onSearch,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double padding = isMobile ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Filters", style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: isMobile ? 18 : 20),
                onPressed: onToggle,
              ),
            ],
          ),
          if (isExpanded) ...[
            SizedBox(height: isMobile ? 12 : 16),
            if (isMobile) ...[
              _buildMobileFields(context),
            ] else ...[
              _buildDesktopFields(context),
            ],
            SizedBox(height: isMobile ? 12 : 16),
            _buildActionButtons(isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileFields(BuildContext context) {
    return Column(
      children: [
        _input("Search Supplier", _buildSearchField(context), context),
        const SizedBox(height: 12),
        _input("Supplier Group", _buildDropdown(selectedGroup, groups, onGroupChanged, context), context),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _input("Type", _buildDropdown(selectedType, types, onTypeChanged, context), context)),
            const SizedBox(width: 8),
            Expanded(child: _input("Country", _buildDropdown(selectedCountry, countries, onCountryChanged, context), context)),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFields(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _input("Search Supplier", _buildSearchField(context), context)),
        const SizedBox(width: 12),
        Expanded(child: _input("Supplier Group", _buildDropdown(selectedGroup, groups, onGroupChanged, context), context)),
        const SizedBox(width: 12),
        Expanded(child: _input("Supplier Type", _buildDropdown(selectedType, types, onTypeChanged, context), context)),
        const SizedBox(width: 12),
        Expanded(child: _input("Country", _buildDropdown(selectedCountry, countries, onCountryChanged, context), context)),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextFormField(
      controller: searchController,
      style: const TextStyle(fontSize: 14),
      decoration: _decoration("Search by name...", context).copyWith(
        suffixIcon: IconButton(icon: const Icon(Icons.search, size: 18), onPressed: onSearch),
      ),
    );
  }

  Widget _buildDropdown(String? value, List<String> items, Function(String?) onChanged, BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      decoration: _decoration("Select...", context),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 14),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Row(children: [const Icon(Icons.close, size: 16), const SizedBox(width: 4), Text("Reset", style: TextStyle(fontSize: isMobile ? 12 : 14))]),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 14),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), elevation: 0,
          ),
          child: Text("Apply Filters", style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  InputDecoration _decoration(String hint, BuildContext context) {
    return InputDecoration(
      hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: .8)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: .8)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1)),
    );
  }

  Widget _input(String label, Widget field, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}

class SupplierDataTable extends StatelessWidget {
  final List<Supplier> suppliers;
  final int totalCount;
  final bool isLoading;
  final Function(Supplier) onView;
  final Function(Supplier) onEdit;

  const SupplierDataTable({
    super.key,
    required this.suppliers,
    required this.totalCount,
    required this.isLoading,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text("Showing ${suppliers.length} of $totalCount suppliers", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: isMobile ? 0.0 : constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  dataRowMinHeight: 56, dataRowMaxHeight: 56, columnSpacing: 24,
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                  columns: const [
                    DataColumn(label: Text("Supplier Details")),
                    DataColumn(label: Text("Type")),
                    DataColumn(label: Text("Group")),
                    DataColumn(label: Text("Country")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: suppliers.map((s) => _buildRow(s, context, isMobile)).toList(),
                ),
              ),
            );
          },
        ),
        if (isLoading) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator())),
      ],
    );
  }

  DataRow _buildRow(Supplier s, BuildContext context, bool isMobile) {
    return DataRow(cells: [
      DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(s.supplierName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ])),
      DataCell(_buildBadge(s.supplierType, s.supplierType == "Company" ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE), s.supplierType == "Company" ? const Color(0xFF166534) : const Color(0xFF1E40AF))),
      DataCell(Text(s.supplierGroup ?? "N/A")),
      DataCell(Text(s.country)),
      DataCell(_buildBadge(s.disabled == 1 ? "Disabled" : "Active", s.disabled == 1 ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7), s.disabled == 1 ? const Color(0xFFDC2626) : const Color(0xFF059669))),
      DataCell(_buildActions(s, context)),
    ]);
  }

  Widget _buildBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildActions(Supplier s, BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (val) => val == 'edit' ? onEdit(s) : onView(s),
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.remove_red_eye, color: Colors.green, size: 20), SizedBox(width: 8), Text('View')])),
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue, size: 20), SizedBox(width: 8), Text('Edit')])),
      ],
    );
  }
}

class SupplierDetailDialog extends StatelessWidget {
  final Supplier supplier;
  const SupplierDetailDialog({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Supplier Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
          children: [
            _row("Supplier ID:", supplier.name),
            _row("Supplier Name:", supplier.supplierName),
            _row("Supplier Type:", supplier.supplierType),
            _row("Supplier Group:", supplier.supplierGroup ?? "N/A"),
            _row("Tax ID:", supplier.taxId ?? "N/A"),
            _row("Country:", supplier.country),
            _row("Currency:", supplier.defaultCurrency ?? "N/A"),
            _row("Status:", supplier.disabled == 1 ? "Disabled" : "Active"),
            _row("Internal:", supplier.isInternalSupplier == 1 ? "Yes" : "No"),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: Color(0xFF2563EB))))],
    );
  }

  Widget _row(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey))),
          Expanded(child: Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class SupplierEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const SupplierEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No suppliers found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Try adjusting your filters or add a new supplier", style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, size: 18), SizedBox(width: 8), Text("Add Supplier")]),
          ),
        ],
      ),
    );
  }
}
