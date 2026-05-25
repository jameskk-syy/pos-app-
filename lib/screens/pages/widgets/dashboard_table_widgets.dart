import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/utils/themes/app_colors.dart';

class DashboardTableCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardTableCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  final bool isAlert;

  const StatusChip({super.key, required this.status, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'overdue': color = Colors.red; break;
      case 'due soon': color = Colors.orange; break;
      case 'processing': color = Colors.blue; break;
      case 'low': color = Colors.red; break;
      case 'critical': color = Colors.red.shade900; break;
      default: color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

String _formatCurrency(num amount) => NumberFormat('#,##0.00').format(amount);

class SalesDueTable extends StatelessWidget {
  final List<dynamic> salesDue;
  const SalesDueTable({super.key, required this.salesDue});

  @override
  Widget build(BuildContext context) {
    if (salesDue.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No sales due')));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
        columns: const [
          DataColumn(label: Text('Invoice', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: salesDue.map((sale) => DataRow(cells: [
          DataCell(Text(sale.id ?? '-')),
          DataCell(Text(sale.customer ?? '-')),
          DataCell(Text('KSh ${_formatCurrency(sale.amount ?? 0)}')),
          DataCell(Text(sale.dueDate ?? '-')),
          DataCell(StatusChip(status: sale.status ?? '-')),
        ])).toList(),
      ),
    );
  }
}

class PurchasesDueTable extends StatelessWidget {
  final List<dynamic> purchasesDue;
  const PurchasesDueTable({super.key, required this.purchasesDue});

  @override
  Widget build(BuildContext context) {
    if (purchasesDue.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No purchases due')));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
        columns: const [
          DataColumn(label: Text('Invoice', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: purchasesDue.map((purchase) => DataRow(cells: [
          DataCell(Text(purchase.id ?? '-')),
          DataCell(Text(purchase.supplier ?? '-')),
          DataCell(Text('KSh ${_formatCurrency(purchase.amount ?? 0)}')),
          DataCell(Text(purchase.dueDate ?? '-')),
          DataCell(StatusChip(status: purchase.status ?? '-')),
        ])).toList(),
      ),
    );
  }
}

class StockAlertsTable extends StatelessWidget {
  final List<dynamic> stockAlerts;
  const StockAlertsTable({super.key, required this.stockAlerts});

  @override
  Widget build(BuildContext context) {
    if (stockAlerts.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No stock alerts')));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.red.shade50),
        columns: const [
          DataColumn(label: Text('Item ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Current Stock', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Min Stock', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: stockAlerts.map((stock) => DataRow(cells: [
          DataCell(Text(stock.id ?? '-')),
          DataCell(Text(stock.product ?? '-')),
          DataCell(Text(stock.currentStock?.toStringAsFixed(0) ?? '0')),
          DataCell(Text(stock.minStock?.toStringAsFixed(0) ?? '0')),
          DataCell(StatusChip(status: stock.status ?? '-', isAlert: true)),
        ])).toList(),
      ),
    );
  }
}

class ShipmentsTable extends StatelessWidget {
  final List<dynamic> shipments;
  const ShipmentsTable({super.key, required this.shipments});

  @override
  Widget build(BuildContext context) {
    if (shipments.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No pending shipments')));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
        columns: const [
          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Items', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Est. Delivery', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: shipments.map((shipment) => DataRow(cells: [
          DataCell(Text(shipment.id ?? '-')),
          DataCell(Text(shipment.orderId ?? '-')),
          DataCell(Text(shipment.customer ?? '-')),
          DataCell(Text('${shipment.items ?? 0}')),
          DataCell(StatusChip(status: shipment.status ?? '-')),
          DataCell(Text(shipment.estDelivery ?? '-')),
        ])).toList(),
      ),
    );
  }
}
