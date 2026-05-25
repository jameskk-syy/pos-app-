import 'package:flutter/material.dart';
import 'package:pos/domain/responses/inventory/stock_entries_response.dart';

class StockEntriesFilters extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final String? selectedVoucherType;
  final List<String> voucherTypes;
  final Function(String?) onVoucherTypeChanged;
  final String? selectedWarehouse;
  final List<String> warehouseNames;
  final Function(String?) onWarehouseChanged;
  final TextEditingController fromDateController;
  final Function(bool) onDateTap;
  final TextEditingController toDateController;
  final String? selectedStatus;
  final List<String> statusOptions;
  final Function(String?) onStatusChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const StockEntriesFilters({
    super.key,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.selectedVoucherType,
    required this.voucherTypes,
    required this.onVoucherTypeChanged,
    required this.selectedWarehouse,
    required this.warehouseNames,
    required this.onWarehouseChanged,
    required this.fromDateController,
    required this.onDateTap,
    required this.toDateController,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onStatusChanged,
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
              Text(
                "Filters",
                style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              IconButton(
                icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: isMobile ? 18 : 20, color: Colors.black),
                onPressed: onToggleExpanded,
              ),
            ],
          ),
          if (isExpanded) ...[
            SizedBox(height: isMobile ? 12 : 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isMobile ? 6.0 : 8.0),
                    child: _input(
                      "Stock Entry Type",
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedVoucherType,
                        style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black),
                        decoration: _decoration("Select type", context),
                        items: voucherTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type.isEmpty ? "All" : type, style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: onVoucherTypeChanged,
                      ),
                      context,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: isMobile ? 6.0 : 8.0),
                    child: _input(
                      "Warehouse",
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        initialValue: selectedWarehouse,
                        style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black),
                        decoration: _decoration("Warehouse", context),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text("All Warehouses", style: TextStyle(fontSize: 13, color: Colors.black))),
                          ...warehouseNames.map((whName) {
                            return DropdownMenuItem<String?>(value: whName, child: Text(whName, style: TextStyle(fontSize: 13, color: Colors.black)));
                          }),
                        ],
                        onChanged: onWarehouseChanged,
                      ),
                      context,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isMobile ? 6.0 : 8.0),
                    child: _input(
                      "From Date",
                      TextFormField(
                        controller: fromDateController,
                        readOnly: true,
                        style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black),
                        decoration: _decoration("Select date", context).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today, size: isMobile ? 16 : 18, color: Colors.grey[700]),
                            onPressed: () => onDateTap(true),
                          ),
                        ),
                      ),
                      context,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: isMobile ? 6.0 : 8.0),
                    child: _input(
                      "To Date",
                      TextFormField(
                        controller: toDateController,
                        readOnly: true,
                        style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black),
                        decoration: _decoration("Select date", context).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today, size: isMobile ? 16 : 18, color: Colors.grey[700]),
                            onPressed: () => onDateTap(false),
                          ),
                        ),
                      ),
                      context,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            _input(
              "Status",
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedStatus,
                style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black),
                decoration: _decoration("Status", context),
                items: statusOptions.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black)),
                  );
                }).toList(),
                onChanged: onStatusChanged,
              ),
              context,
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.0),
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 10 : 14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.red, size: isMobile ? 16 : 18),
                      SizedBox(width: isMobile ? 4 : 8),
                      Text("Reset Filters", style: TextStyle(color: Colors.red, fontSize: isMobile ? 12 : 14)),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 10 : 14),
                    elevation: 0,
                  ),
                  child: Text("Apply Filters", style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.grey[600]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: isMobile ? 12 : 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: .8)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: .8)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1)),
    );
  }

  Widget _input(String label, Widget field, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600)),
        SizedBox(height: isMobile ? 4 : 6),
        field,
      ],
    );
  }
}

class StockEntriesTable extends StatelessWidget {
  final StockEntriesResponse response;
  final int currentPage;
  final Function(int) onPageChanged;
  final Function(StockEntry) onViewDetails;

  const StockEntriesTable({
    super.key,
    required this.response,
    required this.currentPage,
    required this.onPageChanged,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final int totalPages = response.data.pagination.totalPages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing ${response.data.entries.length} of ${response.data.pagination.total} entries",
                style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
              ),
              Chip(
                backgroundColor: response.success ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                label: Text(
                  "Success: ${response.success ? 'Yes' : 'No'}",
                  style: TextStyle(color: response.success ? const Color(0xFF166534) : const Color(0xFFDC2626), fontSize: isMobile ? 11 : 14),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
            dataRowMinHeight: isMobile ? 40 : 56,
            columnSpacing: isMobile ? 12 : 24,
            headingTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14, color: Colors.black),
            columns: const [
              DataColumn(label: Text("Entry Name", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Type", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Date & Time", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Company", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Amount", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Actions", style: TextStyle(color: Colors.black))),
            ],
            rows: response.data.entries.map((entry) => _buildStockEntryRow(entry, context)).toList(),
          ),
        ),
        if (totalPages > 1)
          Padding(
            padding: EdgeInsets.only(top: isMobile ? 12 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB), width: 1.0),
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    minimumSize: Size(isMobile ? 80 : 100, 36),
                  ),
                  child: Text("Previous", style: TextStyle(fontSize: isMobile ? 12 : 14)),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
                  child: Text("Page $currentPage of $totalPages", style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black)),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                ElevatedButton(
                  onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    minimumSize: Size(isMobile ? 80 : 100, 36),
                    elevation: 0,
                  ),
                  child: Text("Next", style: TextStyle(fontSize: isMobile ? 12 : 14)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  DataRow _buildStockEntryRow(StockEntry entry, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(entry.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 14, color: Colors.black)),
              const SizedBox(height: 2),
              Text("Items: ${entry.itemsCount}", style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 3 : 4),
            decoration: BoxDecoration(
              color: entry.stockEntryType == "Material Receipt"
                  ? const Color(0xFFDCFCE7)
                  : entry.stockEntryType == "Material Transfer"
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.stockEntryType,
              style: TextStyle(
                color: entry.stockEntryType == "Material Receipt"
                    ? const Color(0xFF166534)
                    : entry.stockEntryType == "Material Transfer"
                        ? const Color(0xFF1E40AF)
                        : const Color(0xFF92400E),
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(entry.postingDate, style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black)),
              const SizedBox(height: 2),
              Text(entry.postingTime.split('.')[0], style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey)),
            ],
          ),
        ),
        DataCell(Text(entry.company, style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black))),
        DataCell(
          Text(
            "KES ${entry.totalAmount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: entry.totalIncomingValue > 0
                  ? const Color(0xFF059669)
                  : entry.totalOutgoingValue > 0
                      ? const Color(0xFFDC2626)
                      : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: Icon(Icons.remove_red_eye, size: isMobile ? 16 : 18),
            onPressed: () => onViewDetails(entry),
          ),
        ),
      ],
    );
  }
}

class StockEntryDetailDialog extends StatelessWidget {
  final StockEntry entry;

  const StockEntryDetailDialog({super.key, required this.entry});

  static Future<void> show(BuildContext context, StockEntry entry) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isMobile = screenWidth < 600;

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        insetPadding: isMobile ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24) : const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth * 0.95 : 1200,
            maxHeight: screenHeight * 0.85,
          ),
          child: StockEntryDetailDialog(entry: entry),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.black, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Stock Entry Details",
                  style: TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Document:", entry.name, context),
                const SizedBox(height: 8),
                _detailRow("Type:", entry.stockEntryType, context),
                const SizedBox(height: 8),
                _detailRow("Purpose:", entry.purpose, context),
                const SizedBox(height: 8),
                _detailRow("Company:", entry.company, context),
                const Divider(height: 32),
                _detailRow("Posting Date:", entry.postingDate, context),
                const SizedBox(height: 8),
                _detailRow("Posting Time:", entry.postingTime, context),
                const SizedBox(height: 8),
                _detailRow("Items Count:", entry.itemsCount.toString(), context),
                const Divider(height: 32),
                _detailRow("Total Amount:", "KES ${entry.totalAmount.toStringAsFixed(2)}", context),
                const SizedBox(height: 8),
                _detailRow("Total Incoming Value:", "KES ${entry.totalIncomingValue.toStringAsFixed(2)}", context),
                const SizedBox(height: 8),
                _detailRow("Total Outgoing Value:", "KES ${entry.totalOutgoingValue.toStringAsFixed(2)}", context),
                const SizedBox(height: 8),
                _detailRow("Total Additional Costs:", "KES ${entry.totalAdditionalCosts.toStringAsFixed(2)}", context),
                const SizedBox(height: 24),
                Text("Items:", style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 12),
                ...entry.items.map((item) => _buildItemDetail(item, context)),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[100]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
          ),
        ),
      ],
    );
  }

  Widget _buildItemDetail(StockEntryItem item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow("Item Code:", item.itemCode, context),
          _detailRow("Quantity:", item.qty.toStringAsFixed(2), context),
          if (item.sWarehouse != null) _detailRow("Source Warehouse:", item.sWarehouse!, context),
          _detailRow("Target Warehouse:", item.tWarehouse ?? "", context),
          _detailRow("Rate:", "KES ${item.basicRate.toStringAsFixed(2)}", context),
          _detailRow("Amount:", "KES ${item.amount.toStringAsFixed(2)}", context),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 3 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 120 : 150,
            child: Text(label, style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w500, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
