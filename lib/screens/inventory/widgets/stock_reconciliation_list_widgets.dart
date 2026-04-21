import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/responses/inventory/stock_reconciliations_response.dart' as pos;
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/screens/inventory/create_stock_taking.dart';
import 'package:pos/domain/requests/inventory/add_stock_take_request.dart';

class StockReconciliation {
  final String name;
  final String company;
  final String warehouse;
  final String postingDate;
  final String postingTime;
  final String purpose;
  final int docstatus;
  final String workflowStatus;
  final String creation;
  final String modified;
  final String owner;
  final int itemsCount;
  final List<String> warehouses;

  StockReconciliation({
    required this.name,
    required this.company,
    required this.warehouse,
    required this.postingDate,
    required this.postingTime,
    required this.purpose,
    required this.docstatus,
    required this.workflowStatus,
    required this.creation,
    required this.modified,
    required this.owner,
    required this.itemsCount,
    required this.warehouses,
  });

  String get workflowState => workflowStatus;
  String get expenseAccount => 'Stock Adjustment - ${company.split(' ').last}';
  String get costCenter => 'Main - ${company.split(' ').last}';

  factory StockReconciliation.fromApiModel(pos.StockReconciliation apiModel) {
    return StockReconciliation(
      name: apiModel.name,
      company: apiModel.company,
      warehouse: apiModel.warehouse,
      postingDate: apiModel.postingDate,
      postingTime: apiModel.postingTime,
      purpose: apiModel.purpose,
      docstatus: apiModel.docstatus,
      workflowStatus: apiModel.workflowStatus,
      creation: apiModel.creation,
      modified: apiModel.modified,
      owner: apiModel.owner,
      itemsCount: apiModel.itemsCount,
      warehouses: apiModel.warehouses,
    );
  }
}

class StockReconciliationFilters extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final String? selectedWarehouse;
  final List<Warehouse> warehouses;
  final bool warehousesLoaded;
  final String? selectedWorkflowState;
  final List<String> workflowStateOptions;
  final String? selectedPurpose;
  final List<String> purposeOptions;
  final DateTime? fromDate;
  final DateTime? toDate;
  final Function(String?) onWarehouseChanged;
  final Function(String?) onWorkflowStateChanged;
  final Function(String?) onPurposeChanged;
  final VoidCallback onSelectFromDate;
  final VoidCallback onSelectToDate;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const StockReconciliationFilters({
    super.key,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.selectedWarehouse,
    required this.warehouses,
    required this.warehousesLoaded,
    required this.selectedWorkflowState,
    required this.workflowStateOptions,
    required this.selectedPurpose,
    required this.purposeOptions,
    required this.fromDate,
    required this.toDate,
    required this.onWarehouseChanged,
    required this.onWorkflowStateChanged,
    required this.onPurposeChanged,
    required this.onSelectFromDate,
    required this.onSelectToDate,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: Row(
              children: [
                const Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: warehousesLoaded
                      ? _dropdownField("Warehouse", selectedWarehouse, warehouses.map((w) => w.name).toList(), onWarehouseChanged)
                      : _loadingField('Loading warehouses...'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdownField("Workflow State", selectedWorkflowState, workflowStateOptions, onWorkflowStateChanged),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dropdownField("Purpose", selectedPurpose, purposeOptions, onPurposeChanged),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _dateField("From Date", fromDate, onSelectFromDate)),
                const SizedBox(width: 12),
                Expanded(child: _dateField("To Date", toDate, onSelectToDate)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text("Reset Filters", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976F3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropdownField(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _inputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint), value: value, isExpanded: true,
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _dateField(String hint, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: _inputDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date != null ? DateFormat('dd MMM yyyy').format(date) : hint, style: TextStyle(color: date != null ? Colors.black : Colors.grey)),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _loadingField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: _inputDecoration(),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  BoxDecoration _inputDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1976F3), width: 0.6));
  BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF1976F3), width: 0.4));
}

class StockReconciliationTable extends StatelessWidget {
  final List<StockReconciliation> reconciliations;
  final Function(StockReconciliation) onShowActions;

  const StockReconciliationTable({
    super.key,
    required this.reconciliations,
    required this.onShowActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF1976F3), width: 0.4)),
      child: reconciliations.isEmpty
          ? const _EmptyTable()
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                columns: const [
                  DataColumn(label: Text("Reconciliation ID")),
                  DataColumn(label: Text("Warehouse")),
                  DataColumn(label: Text("Posting Date")),
                  DataColumn(label: Text("Posting Time")),
                  DataColumn(label: Text("Purpose")),
                  DataColumn(label: Text("Workflow State")),
                  DataColumn(label: Text("Expense Account")),
                  DataColumn(label: Text("Cost Center")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: reconciliations.map((rec) => _buildDataRow(rec)).toList(),
              ),
            ),
    );
  }

  DataRow _buildDataRow(StockReconciliation rec) {
    final dateTime = DateTime.tryParse(rec.postingDate);
    final formattedDate = dateTime != null ? DateFormat('dd MMM yyyy').format(dateTime) : rec.postingDate;

    return DataRow(
      cells: [
        DataCell(Text(rec.name)),
        DataCell(Text(rec.warehouse)),
        DataCell(Text(formattedDate)),
        DataCell(Text(rec.postingTime)),
        DataCell(Text(rec.purpose)),
        DataCell(_StatusBadge(status: rec.workflowState)),
        DataCell(Text(rec.expenseAccount)),
        DataCell(Text(rec.costCenter)),
        DataCell(IconButton(icon: const Icon(Icons.more_vert), onPressed: () => onShowActions(rec))),
      ],
    );
  }
}

class _EmptyTable extends StatelessWidget {
  const _EmptyTable();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No stock reconciliations found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _getStatusColor(status), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Color _getStatusColor(String workflowState) {
    switch (workflowState.toLowerCase()) {
      case 'draft': return Colors.grey;
      case 'pending sales user':
      case 'pending sale': return Colors.orange;
      case 'approved': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class StockReconciliationDetailDialog extends StatelessWidget {
  final StockReconciliation reconciliation;
  const StockReconciliationDetailDialog({super.key, required this.reconciliation});

  static Future<void> show(BuildContext context, StockReconciliation reconciliation) {
    return showDialog(
      context: context,
      builder: (ctx) => StockReconciliationDetailDialog(reconciliation: reconciliation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 800, minWidth: 600),
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Color(0xFF1976F3)),
                const SizedBox(width: 12),
                const Text('Reconciliation Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow('Reconciliation ID', reconciliation.name),
                    const Divider(height: 24),
                    _DetailRow('Company', reconciliation.company),
                    const Divider(height: 24),
                    _DetailRow('Warehouse', reconciliation.warehouse),
                    const Divider(height: 24),
                    _DetailRow('Posting Date', reconciliation.postingDate),
                    const Divider(height: 24),
                    _DetailRow('Posting Time', reconciliation.postingTime),
                    const Divider(height: 24),
                    _DetailRow('Purpose', reconciliation.purpose),
                    const Divider(height: 24),
                    _DetailRow('Workflow State', reconciliation.workflowState, isStatus: true),
                    const Divider(height: 24),
                    _DetailRow('Expense Account', reconciliation.expenseAccount),
                    const Divider(height: 24),
                    _DetailRow('Cost Center', reconciliation.costCenter),
                    const Divider(height: 24),
                    _DetailRow('Items Count', '${reconciliation.itemsCount}'),
                    const Divider(height: 24),
                    _DetailRow('Owner', reconciliation.owner),
                    const Divider(height: 24),
                    _DetailRow('Created', reconciliation.creation),
                    const Divider(height: 24),
                    _DetailRow('Modified', reconciliation.modified),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  const _DetailRow(this.label, this.value, {this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 14))),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isStatus ? _getStatusColor(value) : Colors.black87, fontSize: 14))),
        ],
      ),
    );
  }

  Color _getStatusColor(String workflowState) {
    switch (workflowState.toLowerCase()) {
      case 'draft': return Colors.grey;
      case 'pending sales user':
      case 'pending sale': return Colors.orange;
      case 'approved': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class StockReconciliationActionMenu extends StatelessWidget {
  final StockReconciliation reconciliation;
  final VoidCallback onViewDetails;

  const StockReconciliationActionMenu({
    super.key,
    required this.reconciliation,
    required this.onViewDetails,
  });

  static void show(BuildContext context, StockReconciliation reconciliation, VoidCallback onViewDetails) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => StockReconciliationActionMenu(reconciliation: reconciliation, onViewDetails: onViewDetails),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility, color: Colors.blue),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              onViewDetails();
            },
          ),
          const Divider(),
          _buildActionItem(context, Icons.add_box, Colors.green, 'Add Stock Take (Sales)', StockTakeRole.salesPerson),
          _buildActionItem(context, Icons.add_box, Colors.orange, 'Add Stock Take (Quality/Controller)', StockTakeRole.stockController),
          _buildActionItem(context, Icons.add_box, Colors.purple, 'Submit Reconciliation (Manager)', StockTakeRole.stockManager),
        ],
      ),
    );
  }

  ListTile _buildActionItem(BuildContext context, IconData icon, Color color, String title, StockTakeRole role) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => StockTakePage(reconciliationName: reconciliation.name, role: role)));
      },
    );
  }
}
