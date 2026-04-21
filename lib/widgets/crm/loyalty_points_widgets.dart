import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/crm/loyalty_history_models.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';

class LoyaltyHeader extends StatelessWidget {
  final Customer customer;
  final bool isExpanded;
  final VoidCallback onToggle;

  const LoyaltyHeader({
    super.key,
    required this.customer,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Points History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 6),
                        Text(
                          customer.customerName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20, color: Colors.grey[700]),
                  onPressed: onToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoyaltyFilterSection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedType;
  final List<String> typeOptions;
  final Function(DateTime?, bool) onDateSelected;
  final Function(String?) onTypeSelected;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const LoyaltyFilterSection({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectedType,
    required this.typeOptions,
    required this.onDateSelected,
    required this.onTypeSelected,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton(icon: const Icon(Icons.filter_alt_outlined, size: 20), onPressed: onApply),
            ],
          ),
          const SizedBox(height: 16),
          _buildDateRange(context),
          const SizedBox(height: 20),
          _buildTypeFilter(),
          const SizedBox(height: 20),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildDateRange(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATE RANGE', style: _labelStyle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: _boxDecoration,
          child: Row(
            children: [
              Expanded(child: _dateField('From', startDate, () => onDateSelected(startDate, true), context)),
              Container(width: 24, height: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 12)),
              Expanded(child: _dateField('To', endDate, () => onDateSelected(endDate, false), context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateField(String label, DateTime? date, VoidCallback onTap, BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? DateFormat('dd MMM yyyy').format(date) : 'Select date',
                    style: TextStyle(fontSize: 14, color: date != null ? Colors.black87 : Colors.grey[400], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TRANSACTION TYPE', style: _labelStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: typeOptions.map((type) {
            final isSelected = selectedType == type;
            return ChoiceChip(
              label: Text(type, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w500)),
              selected: isSelected,
              onSelected: (selected) => onTypeSelected(selected ? type : null),
              selectedColor: Colors.blue[500], backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              elevation: 0, pressElevation: 0,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh, size: 18, color: Colors.grey),
            label: const Text('Clear All', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Apply Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[500], foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _labelStyle => TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[600], letterSpacing: 0.5);
  BoxDecoration get _boxDecoration => BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!));
}

class TransactionCard extends StatelessWidget {
  final LoyaltyHistoryTransaction transaction;
  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isEarn = transaction.transactionType.toLowerCase() == 'earn';
    final Color color = isEarn ? Colors.green[400]! : Colors.red[400]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: Icon(isEarn ? Icons.add_rounded : Icons.remove_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _rowIconText(Icons.calendar_today_outlined, transaction.date),
                  if (transaction.referenceDocument != null) ...[
                    const SizedBox(height: 6),
                    _badge('Ref: ${transaction.referenceDocument}'),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _typeBadge(transaction.transactionType, color),
                const SizedBox(height: 8),
                Text('${isEarn ? '+' : '-'}${transaction.pointsEarned} pts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 6),
                Text('KSh ${transaction.purchaseAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowIconText(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 12, color: Colors.grey[500]), const SizedBox(width: 6), Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500))]);
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
    );
  }

  Widget _typeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
      child: Text(type.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
    );
  }
}
