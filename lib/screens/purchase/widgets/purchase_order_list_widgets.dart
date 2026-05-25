import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;
}

class PurchaseOrderUIModel {
  final String poNumber;
  final String supplierName;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final DateTime expectedDate;
  final String currency;

  PurchaseOrderUIModel({
    required this.poNumber,
    required this.supplierName,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.expectedDate,
    this.currency = 'KES',
  });
}

class PurchaseOrderFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final String? selectedSupplier;
  final VoidCallback onStatusTap;
  final VoidCallback onSupplierTap;
  final VoidCallback onClear;

  const PurchaseOrderFilters({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedSupplier,
    required this.onStatusTap,
    required this.onSupplierTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search PO by ID or Name...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(child: _filterBtn(context, Icons.filter_list, selectedStatus, onStatusTap)),
                const SizedBox(width: 12),
                Expanded(child: _filterBtn(context, Icons.business, selectedSupplier ?? 'All Suppliers', onSupplierTap, active: selectedSupplier != null)),
                const SizedBox(width: 12),
                IconButton(onPressed: onClear, icon: const Icon(Icons.clear_all, color: Colors.grey), tooltip: 'Clear Filters'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool active = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(fontSize: 13, color: active || label != 'All' ? Colors.black : Colors.grey[600]))),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}

class PurchaseOrderDataTable extends StatelessWidget {
  final List<PurchaseOrderUIModel> orders;
  final Function(PurchaseOrderUIModel) onViewDetails;
  final Function(String, PurchaseOrderUIModel) onAction;
  final List<PopupMenuItem<String>> Function(PurchaseOrderUIModel) buildActions;

  const PurchaseOrderDataTable({
    super.key,
    required this.orders,
    required this.onViewDetails,
    required this.onAction,
    required this.buildActions,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))]),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 2),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              dataRowColor: WidgetStateProperty.all(Colors.white),
              horizontalMargin: 8,
              columnSpacing: 12,
              columns: _buildColumns(isMobile),
              rows: orders.map((o) => _buildRow(o, isMobile)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(bool isMobile) {
    return [
      const DataColumn(label: Text('PO Number', style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
      if (!isMobile) ...[
        const DataColumn(label: Text('Order Date', style: TextStyle(fontWeight: FontWeight.bold))),
        const DataColumn(label: Text('Expected', style: TextStyle(fontWeight: FontWeight.bold))),
        const DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
    ];
  }

  DataRow _buildRow(PurchaseOrderUIModel order, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(Text(order.poNumber, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)), onTap: () => onViewDetails(order)),
        DataCell(SizedBox(width: isMobile ? 100 : 150, child: Text(order.supplierName, overflow: TextOverflow.ellipsis))),
        if (!isMobile) ...[
          DataCell(Text(DateFormat('MMM dd, yyyy').format(order.orderDate))),
          DataCell(Text(DateFormat('MMM dd, yyyy').format(order.expectedDate))),
          DataCell(Text('${order.currency} ${NumberFormat('#,##0.00').format(order.totalAmount)}', style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
        DataCell(PurchaseOrderStatusBadge(status: order.status)),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (context) => buildActions(order),
            onSelected: (value) => onAction(value, order),
          ),
        ),
      ],
    );
  }
}

class PurchaseOrderStatusBadge extends StatelessWidget {
  final String status;
  const PurchaseOrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(50))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft': return Colors.grey;
      case 'pending': return Colors.orange;
      case 'to receive and bill': return Colors.orange;
      case 'to bill': return Colors.blue;
      case 'to receive': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class PurchaseOrderPagination extends StatelessWidget {
  final int currentPage;
  final int itemsPerPage;
  final int totalCount;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PurchaseOrderPagination({
    super.key,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / itemsPerPage).ceil();
    if (totalCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing ${((currentPage - 1) * itemsPerPage) + 1} - ${currentPage * itemsPerPage > totalCount ? totalCount : currentPage * itemsPerPage} of $totalCount', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Row(
            children: [
              IconButton(onPressed: currentPage > 1 ? onPrevious : null, icon: const Icon(Icons.chevron_left), color: currentPage > 1 ? Colors.blue : Colors.grey[400], style: IconButton.styleFrom(backgroundColor: Colors.grey[100])),
              const SizedBox(width: 8),
              Text('Page $currentPage of $totalPages', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              IconButton(onPressed: currentPage < totalPages ? onNext : null, icon: const Icon(Icons.chevron_right), color: currentPage < totalPages ? Colors.blue : Colors.grey[400], style: IconButton.styleFrom(backgroundColor: Colors.grey[100])),
            ],
          ),
        ],
      ),
    );
  }
}

class PurchaseOrderEmptyState extends StatelessWidget {
  final VoidCallback onCreateStarted;
  const PurchaseOrderEmptyState({super.key, required this.onCreateStarted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.blue.withAlpha(10), shape: BoxShape.circle), child: const Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.blue)),
          const SizedBox(height: 24),
          const Text('No Purchase Orders Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Try adjusting your filters or create a new order', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateStarted,
            icon: const Icon(Icons.add),
            label: const Text('Create First Order'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ],
      ),
    );
  }
}

class PurchaseOrderErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const PurchaseOrderErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800])),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600]))),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white)),
        ],
      ),
    );
  }
}
