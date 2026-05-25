import 'package:flutter/material.dart';
import 'package:pos/domain/responses/inventory/stock_summary_response.dart';

class StockSummaryDetailDialog extends StatelessWidget {
  final StockSummaryItem item;

  const StockSummaryDetailDialog({super.key, required this.item});

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
          maxHeight: screenHeight * (isMobile ? 0.80 : 0.85),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, isMobile),
            _buildContent(context, isMobile),
            _buildFooter(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 14 : 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.itemName,
              style: TextStyle(
                fontSize: isMobile ? 15 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    return Flexible(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Item Code:", item.itemCode, isMobile),
            _detailRow("Item Group:", item.itemGroup, isMobile),
            _detailRow("Warehouse:", item.warehouse, isMobile),
            SizedBox(height: isMobile ? 14 : 18),
            _buildSectionHeader("Stock Details", isMobile),
            const SizedBox(height: 8),
            _buildInfoBox([
              _detailRow("Actual QTY:", "${item.actualQty.toStringAsFixed(2)} ${item.stockUom}", isMobile),
              _detailRow("Reserved QTY:", "${item.reservedQty.toStringAsFixed(2)} ${item.stockUom}", isMobile),
              _detailRow("Ordered QTY:", "${item.orderedQty.toStringAsFixed(2)} ${item.stockUom}", isMobile),
              _detailRow("Projected QTY:", "${item.projectedQty.toStringAsFixed(2)} ${item.stockUom}", isMobile),
            ], isMobile),
            SizedBox(height: isMobile ? 14 : 18),
            _buildSectionHeader("Financial Details", isMobile),
            const SizedBox(height: 8),
            _buildInfoBox([
              _detailRow("Stock Value:", "\$${item.stockValue.toStringAsFixed(2)}", isMobile),
              _detailRow("Valuation Rate:", "\$${item.valuationRate.toStringAsFixed(2)}", isMobile),
              _detailRow("Unit of Measure:", item.stockUom, isMobile),
            ], isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isMobile ? 13 : 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoBox(List<Widget> children, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 3 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 100 : 120,
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

class StockSummaryFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedWarehouse;
  final String? selectedItemGroup;
  final List<String> warehouseList;
  final List<String> itemGroupList;
  final bool isFiltersExpanded;
  final VoidCallback onToggleFilters;
  final Function(String?) onWarehouseChanged;
  final Function(String?) onItemGroupChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onApplyFilters;
  final VoidCallback onLoadStockSummary;

  const StockSummaryFilters({
    super.key,
    required this.searchController,
    required this.selectedWarehouse,
    required this.selectedItemGroup,
    required this.warehouseList,
    required this.itemGroupList,
    required this.isFiltersExpanded,
    required this.onToggleFilters,
    required this.onWarehouseChanged,
    required this.onItemGroupChanged,
    required this.onClearFilters,
    required this.onApplyFilters,
    required this.onLoadStockSummary,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
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
          _buildFilterHeader(isMobile),
          if (isFiltersExpanded) ...[
            SizedBox(height: isMobile ? 12 : 16),
            _buildFirstFilterRow(context, isMobile),
            SizedBox(height: isMobile ? 12 : 16),
            _buildSecondFilterRow(context, isMobile),
            SizedBox(height: isMobile ? 16 : 20),
            _buildActionButtons(isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Filters",
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(
            isFiltersExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: isMobile ? 18 : 20,
          ),
          onPressed: onToggleFilters,
        ),
      ],
    );
  }

  Widget _buildFirstFilterRow(BuildContext context, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isMobile ? 6.0 : 8.0),
            child: _inputField(
              "Search Items",
              TextField(
                controller: searchController,
                onChanged: (value) {
                  if (value.isEmpty) onLoadStockSummary();
                },
                onSubmitted: (_) => onApplyFilters(),
                style: TextStyle(fontSize: isMobile ? 13 : 14),
                decoration: _fieldDecoration("Search items", context).copyWith(
                  prefixIcon: Icon(Icons.search, size: isMobile ? 18 : 20, color: Colors.grey[600]),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: isMobile ? 16 : 18),
                          onPressed: () {
                            searchController.clear();
                            onLoadStockSummary();
                          },
                        )
                      : null,
                ),
              ),
              isMobile,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isMobile ? 6.0 : 8.0),
            child: _inputField(
              "Warehouse",
              DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: selectedWarehouse,
                style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black),
                decoration: _fieldDecoration("Warehouse", context),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text("All Warehouses", style: TextStyle(fontSize: isMobile ? 13 : 14)),
                  ),
                  ...warehouseList
                      .where((wh) => wh != "All Warehouses")
                      .map((wh) => DropdownMenuItem<String?>(
                            value: wh,
                            child: Text(wh, style: TextStyle(fontSize: isMobile ? 13 : 14)),
                          )),
                ],
                onChanged: onWarehouseChanged,
              ),
              isMobile,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondFilterRow(BuildContext context, bool isMobile) {
    return _inputField(
      "Item Group",
      DropdownButtonFormField<String?>(
        isExpanded: true,
        initialValue: selectedItemGroup,
        style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black),
        decoration: _fieldDecoration("Select Group", context),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text("All Groups", style: TextStyle(fontSize: isMobile ? 13 : 14)),
          ),
          ...itemGroupList.map((group) => DropdownMenuItem<String?>(
                value: group,
                child: Text(group, style: TextStyle(fontSize: isMobile ? 13 : 14)),
              )),
        ],
        onChanged: onItemGroupChanged,
      ),
      isMobile,
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: onClearFilters,
          icon: Icon(Icons.clear_all, size: isMobile ? 16 : 18),
          label: Text("Clear Filters", style: TextStyle(fontSize: isMobile ? 12 : 14)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 10 : 14),
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        ElevatedButton(
          onPressed: onApplyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 10 : 14),
            elevation: 0,
          ),
          child: Text(
            "Apply Filters",
            style: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, Widget field, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        field,
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return InputDecoration(
      hintText: hint,
      isDense: true,
      hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5)),
    );
  }
}

class StockSummaryTable extends StatelessWidget {
  final List<StockSummaryItem> items;
  final Function(StockSummaryItem) onViewDetails;
  final VoidCallback onAdjustItem;
  final VoidCallback onTransferItem;

  const StockSummaryTable({
    super.key,
    required this.items,
    required this.onViewDetails,
    required this.onAdjustItem,
    required this.onTransferItem,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        _buildHeader(isMobile),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildRow(context, items[index], isMobile);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
      ),
      child: Row(
        children: [
          _headerCell("Item Name", 3, isMobile),
          SizedBox(width: isMobile ? 8 : 16),
          _headerCell("Actual QTY", 2, isMobile, textAlign: TextAlign.center),
          SizedBox(width: isMobile ? 4 : 8),
          Container(
            width: isMobile ? 40 : 48,
            alignment: Alignment.center,
            child: Text(
              "Action",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, int flex, bool isMobile, {TextAlign? textAlign}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14),
      ),
    );
  }

  Widget _buildRow(BuildContext context, StockSummaryItem item, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: isMobile ? 13 : 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  item.itemCode,
                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 8 : 16),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.actualQty.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 14),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  item.stockUom,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 4 : 8),
          SizedBox(
            width: isMobile ? 40 : 48,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.more_vert, size: isMobile ? 18 : 20, color: Colors.blue),
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    onViewDetails(item);
                    break;
                  case 'adjust':
                    onAdjustItem();
                    break;
                  case 'transfer':
                    onTransferItem();
                    break;
                }
              },
              itemBuilder: (context) => [
                _menuItem('view', Icons.remove_red_eye, 'View Details'),
                _menuItem('adjust', Icons.edit, 'Adjust'),
                _menuItem('transfer', Icons.swap_horiz, 'Transfer'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
