import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/payment_method_model.dart';

class SessionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const SessionHeader({super.key, required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.blue[900])),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600], size: 24),
                onPressed: onClose, padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SessionInfoContainer extends StatelessWidget {
  final String label;
  final String content;
  final IconData icon;

  const SessionInfoContainer({super.key, required this.label, required this.content, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700], letterSpacing: 0.2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue[500], size: 18),
              const SizedBox(width: 12),
              Expanded(child: Text(content, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ],
    );
  }
}

class OpeningBalanceDetailsHeader extends StatelessWidget {
  const OpeningBalanceDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.account_balance_wallet, color: Colors.blue[700], size: 20),
        const SizedBox(width: 8),
        Text('Opening Balance Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey[800])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(4)),
          child: Text('Optional', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange[700])),
        ),
      ],
    );
  }
}

class PaymentMethodInputRow extends StatelessWidget {
  final String? selectedMethod;
  final List<PaymentMethod> methods;
  final TextEditingController amountController;
  final Function(String?) onMethodChanged;
  final VoidCallback onAdd;

  const PaymentMethodInputRow({
    super.key,
    required this.selectedMethod,
    required this.methods,
    required this.amountController,
    required this.onMethodChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: selectedMethod,
              decoration: _inputDecoration(),
              items: methods.map((method) => DropdownMenuItem(value: method.name, child: _MethodMenuItem(method: method))).toList(),
              onChanged: onMethodChanged,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(hint: '0.00'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle, color: Colors.green), tooltip: 'Add', iconSize: 28),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint, filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue[400]!, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}

class BalanceDetailListItem extends StatelessWidget {
  final Map<String, dynamic> detail;
  final String paymentType;
  final VoidCallback onDelete;

  const BalanceDetailListItem({super.key, required this.detail, required this.paymentType, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _PaymentIcon(type: paymentType),
                const SizedBox(width: 12),
                Expanded(child: Text(detail['method'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(NumberFormat('#,##0.00').format(detail['amount']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20), onPressed: onDelete, splashRadius: 20),
        ],
      ),
    );
  }
}

class OpeningBalanceTotalRow extends StatelessWidget {
  final double total;

  const OpeningBalanceTotalRow({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Total Opening Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue[900]))
          ),
          const SizedBox(width: 12),
          Expanded(
             flex: 2,
             child: Text(NumberFormat('#,##0.00').format(total), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.blue[900]))
          ),
          const SizedBox(width: 60), // Space to align under amount when considering delete button
        ],
      ),
    );
  }
}

class _MethodMenuItem extends StatelessWidget {
  final PaymentMethod method;
  const _MethodMenuItem({required this.method});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PaymentIcon(type: method.type, isSmall: true),
        const SizedBox(width: 8),
        Expanded(child: Text(method.name, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  final String type;
  final bool isSmall;

  const _PaymentIcon({required this.type, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(type);
    return Container(
      width: isSmall ? 20 : 28, height: isSmall ? 20 : 28,
      decoration: BoxDecoration(color: color.withAlpha(10), borderRadius: BorderRadius.circular(isSmall ? 4 : 6)),
      child: Icon(_getIcon(type), size: isSmall ? 12 : 14, color: color),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash': return Icons.currency_exchange;
      case 'bank': return Icons.account_balance;
      case 'credit': return Icons.credit_card;
      default: return Icons.payment;
    }
  }

  Color _getColor(String type) {
    switch (type.toLowerCase()) {
      case 'cash': return Colors.green[600]!;
      case 'bank': return Colors.blue[600]!;
      case 'credit': return Colors.orange[600]!;
      default: return Colors.purple[600]!;
    }
  }
}
