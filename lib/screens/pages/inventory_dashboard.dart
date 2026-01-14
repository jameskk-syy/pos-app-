import 'package:flutter/material.dart';

class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        StockAlertCard(),
        SizedBox(height: 16),
        PendingShipmentCard(),
      ],
    );
  }
}
class StockAlertCard extends StatelessWidget {
  const StockAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: "Stock Alerts",
      child: Column(
        children: const [
          _StockHeader(),
          Divider(color: Colors.blue),
          _StockRow("Laptop", "12", "10", StockStatus.low),
          _StockRow("Mouse", "12", "15", StockStatus.low),
          _StockRow("Wireless Mouse", "4", "12", StockStatus.critical),
          _StockRow("Phone", "12", "12", StockStatus.warning),
        ],
      ),
    );
  }
}

class _StockHeader extends StatelessWidget {
  const _StockHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Cell("Product", bold: true),
        _Cell("Current", bold: true),
        _Cell("Minimum", bold: true),
        SizedBox(width: 90, child: _Cell("Status", bold: true)),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  final String product;
  final String current;
  final String minimum;
  final StockStatus status;

  const _StockRow(this.product, this.current, this.minimum, this.status);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _Cell(product),
          _Cell(current),
          _Cell(minimum),
          SizedBox(width: 90, child: _StatusChip(status)),
        ],
      ),
    );
  }
}


class PendingShipmentCard extends StatelessWidget {
  const PendingShipmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: "Pending Shipments",
      child: Column(
        children: const [
          _ShipmentHeader(),
          Divider(color: Colors.blue),
          _ShipmentRow("ORD-001", "John Doe", "10", ShipmentStatus.processing, "16/12/2025eeee"),
          _ShipmentRow("ORD-002", "John Doe", "15", ShipmentStatus.shipped, "16/12/2025"),
          _ShipmentRow("ORD-003", "John Doe", "11", ShipmentStatus.processing, "16/12/2025"),
        ],
      ),
    );
  }
}

class _ShipmentHeader extends StatelessWidget {
  const _ShipmentHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Cell("Order ID", bold: true),
        _Cell("Customer", bold: true),
        _Cell("Items", bold: true),
        SizedBox(width: 110, child: _Cell("Status", bold: true)),
        _Cell("Est Delivery", bold: true),
      ],
    );
  }
}

class _ShipmentRow extends StatelessWidget {
  final String id;
  final String customer;
  final String items;
  final ShipmentStatus status;
  final String delivery;

  const _ShipmentRow(this.id, this.customer, this.items, this.status, this.delivery);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _Cell(id),
          _Cell(customer),
          _Cell(items),
          SizedBox(width: 110, child: _ShipmentStatusChip(status)),
          _Cell(delivery),
        ],
      ),
    );
  }
}

class _CardWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool bold;

  const _Cell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

enum StockStatus { low, warning, critical }

class _StatusChip extends StatelessWidget {
  final StockStatus status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final map = {
      StockStatus.low: Colors.orange,
      StockStatus.warning: Colors.pink,
      StockStatus.critical: Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: map[status],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          status.name.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}

enum ShipmentStatus { processing, shipped }

class _ShipmentStatusChip extends StatelessWidget {
  final ShipmentStatus status;

  const _ShipmentStatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: status == ShipmentStatus.shipped ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          status == ShipmentStatus.shipped ? "Shipped" : "Processing",
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
