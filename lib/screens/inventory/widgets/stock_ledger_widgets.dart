import 'package:flutter/material.dart';
import 'package:pos/domain/models/stock_ledger_entry.dart';

class StockLedgerFilters extends StatelessWidget {
  final String? selectedVoucherType;
  final String? selectedWarehouse;
  final String? selectedStatus;
  final bool isFiltersExpanded;
  final List<String> voucherTypes;
  final List<String> statusOptions;
  final List<String> warehouseNames;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final VoidCallback onToggleFilters;
  final Function(String?) onVoucherTypeChanged;
  final Function(String?) onWarehouseChanged;
  final Function(String?) onStatusChanged;
  final VoidCallback onSelectFromDate;
  final VoidCallback onSelectToDate;
  final VoidCallback onResetFilters;
  final VoidCallback onApplyFilters;

  const StockLedgerFilters({
    super.key,
    this.selectedVoucherType,
    this.selectedWarehouse,
    this.selectedStatus,
    required this.isFiltersExpanded,
    required this.voucherTypes,
    required this.statusOptions,
    required this.warehouseNames,
    required this.fromDateController,
    required this.toDateController,
    required this.onToggleFilters,
    required this.onVoucherTypeChanged,
    required this.onWarehouseChanged,
    required this.onStatusChanged,
    required this.onSelectFromDate,
    required this.onSelectToDate,
    required this.onResetFilters,
    required this.onApplyFilters,
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
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(
                  isFiltersExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: isMobile ? 18 : 20,
                  color: Colors.black,
                ),
                onPressed: onToggleFilters,
              ),
            ],
          ),
          if (isFiltersExpanded) ...[
            SizedBox(height: isMobile ? 12 : 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isMobile ? 6.0 : 8.0),
                    child: _buildInput(
                      "Voucher Type",
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedVoucherType,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: Colors.black,
                        ),
                        decoration: _buildDecoration("Select type", context),
                        items: voucherTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                color: Colors.black,
                              ),
                            ),
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
                    child: _buildInput(
                      "Warehouse",
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        initialValue: selectedWarehouse,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: Colors.black,
                        ),
                        decoration: _buildDecoration("Warehouse", context),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              "All Warehouses",
                              style: TextStyle(fontSize: 13, color: Colors.black),
                            ),
                          ),
                          ...warehouseNames.map((whName) {
                            return DropdownMenuItem<String?>(
                              value: whName,
                              child: Text(
                                whName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            );
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
                    child: _buildInput(
                      "From Date",
                      TextFormField(
                        controller: fromDateController,
                        readOnly: true,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: Colors.black,
                        ),
                        decoration: _buildDecoration("Select date", context).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              size: isMobile ? 16 : 18,
                              color: Colors.grey[700],
                            ),
                            onPressed: onSelectFromDate,
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
                    child: _buildInput(
                      "To Date",
                      TextFormField(
                        controller: toDateController,
                        readOnly: true,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: Colors.black,
                        ),
                        decoration: _buildDecoration("Select date", context).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              size: isMobile ? 16 : 18,
                              color: Colors.grey[700],
                            ),
                            onPressed: onSelectToDate,
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
            _buildInput(
              "Status",
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedStatus,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.black,
                ),
                decoration: _buildDecoration("Status", context),
                items: statusOptions.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.black,
                      ),
                    ),
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
                  onPressed: onResetFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.0),
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 10 : 14,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.red, size: isMobile ? 16 : 18),
                      SizedBox(width: isMobile ? 4 : 8),
                      Text(
                        "Reset Filters",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                ElevatedButton(
                  onPressed: onApplyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 10 : 14,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Apply Filters",
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildInput(String label, Widget field, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        field,
      ],
    );
  }

  InputDecoration _buildDecoration(String hint, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: isMobile ? 13 : 14,
        color: Colors.grey[600],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isMobile ? 12 : 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: .8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: .8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1),
      ),
    );
  }
}

class StockLedgerTable extends StatelessWidget {
  final StockLedgerResponse response;
  final Function(StockLedgerEntry) onViewDetails;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const StockLedgerTable({
    super.key,
    required this.response,
    required this.onViewDetails,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing ${response.data.length} of ${response.count} entries",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey,
                ),
              ),
              Chip(
                backgroundColor: const Color(0xFFDCFCE7),
                label: Text(
                  "Success: ${response.success ? 'Yes' : 'No'}",
                  style: TextStyle(
                    color: const Color(0xFF166534),
                    fontSize: isMobile ? 11 : 14,
                  ),
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
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 12 : 14,
              color: Colors.black,
            ),
            columns: const [
              DataColumn(label: Text("Voucher No", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Voucher Type", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Date & Time", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Warehouse", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Quantity", style: TextStyle(color: Colors.black))),
              DataColumn(label: Text("Actions", style: TextStyle(color: Colors.black))),
            ],
            rows: response.data
                .map((entry) => _buildStockEntryRow(entry, context))
                .toList(),
          ),
        ),
        if (response.count > response.data.length)
          Padding(
            padding: EdgeInsets.only(top: isMobile ? 12 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onPrevious,
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
                ElevatedButton(
                  onPressed: onNext,
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

  DataRow _buildStockEntryRow(StockLedgerEntry entry, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.voucherNo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.itemCode,
                style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: entry.voucherType == "Stock Entry"
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.voucherType,
              style: TextStyle(
                color: entry.voucherType == "Stock Entry"
                    ? const Color(0xFF166534)
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
              Text(
                entry.postingDate,
                style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black),
              ),
              const SizedBox(height: 2),
              Text(
                entry.postingTime.split('.')[0],
                style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            entry.warehouse,
            style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black),
          ),
        ),
        DataCell(
          Text(
            "${entry.actualQty > 0 ? '+' : ''}${entry.actualQty.toInt()}",
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: entry.actualQty > 0
                  ? const Color(0xFF059669)
                  : const Color(0xFFDC2626),
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

class StockLedgerDetailDialog extends StatelessWidget {
  final StockLedgerEntry entry;

  const StockLedgerDetailDialog({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isMobile = screenWidth < 600;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? screenWidth * 0.95 : 1200,
          maxHeight: screenHeight * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.black, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Stock Entry Details",
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Voucher No:", entry.voucherNo, context),
                    const SizedBox(height: 8),
                    _buildDetailRow("Item Code:", entry.itemCode, context),
                    const SizedBox(height: 8),
                    _buildDetailRow("Warehouse:", entry.warehouse, context),
                    const SizedBox(height: 8),
                    _buildDetailRow("Voucher Type:", entry.voucherType, context),
                    const Divider(height: 32),
                    _buildDetailRow("Posting Date:", entry.postingDate, context),
                    const SizedBox(height: 8),
                    _buildDetailRow("Posting Time:", entry.postingTime, context),
                    const SizedBox(height: 8),
                    _buildDetailRow("Actual Qty:", entry.actualQty.toString(), context),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      "Qty After Transaction:",
                      entry.qtyAfterTransaction.toString(),
                      context,
                    ),
                    const Divider(height: 32),
                    _buildDetailRow("Valuation Rate:", entry.valuationRate.toString(), context),
                    const SizedBox(height: 8),
                    _buildDetailRow("Stock Value:", entry.stockValue.toString(), context),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      "Status:",
                      entry.isCancelled == 1 ? "Cancelled" : "Active",
                      context,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 3 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 120 : 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
