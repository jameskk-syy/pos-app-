import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/responses/inventory/material_requests_response.dart';

class StockTransferDetailDialog extends StatelessWidget {
  final MaterialRequest request;

  const StockTransferDetailDialog({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final dialogWidth = isTablet ? 700.0 : width * 0.95;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Request Details: ${request.name}',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Requested By', request.requestedBy, isTablet),
                    _detailRow('Requested On', request.requestedOn, isTablet),
                    _detailRow('Status', request.status, isTablet),
                    _detailRow('Origin', request.originWarehouse, isTablet),
                    _detailRow('Destination', request.destinationWarehouse, isTablet),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 120 : 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 15 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StockTransferActionMenu extends StatelessWidget {
  final String requestName;
  final MaterialRequest materialRequest;
  final String status;
  final Function(String) onSubmit;
  final Function(String) onApprove;
  final Function(String) onDispatch;
  final Function(String) onReceive;
  final Function(MaterialRequest) onViewDetails;

  const StockTransferActionMenu({
    super.key,
    required this.requestName,
    required this.materialRequest,
    required this.status,
    required this.onSubmit,
    required this.onApprove,
    required this.onDispatch,
    required this.onReceive,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Submit for Approval'),
            enabled: status == 'Draft',
            onTap: status == 'Draft' ? () => onSubmit(requestName) : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.approval, color: Colors.purple),
            title: const Text('Approve'),
            enabled: status == 'Pending',
            onTap: status == 'Pending' ? () => onApprove(requestName) : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.blue),
            title: const Text('Dispatch'),
            enabled: status == 'Pending',
            onTap: status == 'Pending' ? () => onDispatch(requestName) : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inbox, color: Colors.orange),
            title: const Text('Receive'),
            enabled: status == 'In Transit' || status == 'Partially In Transit' || status == 'Partially Received',
            onTap: (status == 'In Transit' || status == 'Partially In Transit' || status == 'Partially Received')
                ? () => onReceive(requestName)
                : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.visibility, color: Colors.grey),
            title: const Text('View Details'),
            onTap: () => onViewDetails(materialRequest),
          ),
        ],
      ),
    );
  }
}

class StockTransferFilters extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? selectedStatus;
  final String? selectedOrigin;
  final String? selectedDestination;
  final List<String> statusOptions;
  final List<String> warehouses;
  final DateTime? fromDate;
  final DateTime? toDate;
  final Function(String?) onStatusChanged;
  final Function(String?) onOriginChanged;
  final Function(String?) onDestinationChanged;
  final VoidCallback onSelectFromDate;
  final VoidCallback onSelectToDate;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const StockTransferFilters({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.selectedStatus,
    required this.selectedOrigin,
    required this.selectedDestination,
    required this.statusOptions,
    required this.warehouses,
    required this.fromDate,
    required this.toDate,
    required this.onStatusChanged,
    required this.onOriginChanged,
    required this.onDestinationChanged,
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
            onTap: onToggle,
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
                  child: _dropdownField("Origin Warehouse", selectedOrigin, warehouses, onOriginChanged),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdownField("Destination Warehouse", selectedDestination, warehouses, onDestinationChanged),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dropdownField("Status", selectedStatus, statusOptions, onStatusChanged),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateField("From Date", fromDate, onSelectFromDate),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField("To Date", toDate, onSelectToDate),
                ),
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
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976F3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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
          hint: Text(hint),
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
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
            Text(
              date != null ? DateFormat('dd MMM yyyy').format(date) : hint,
              style: TextStyle(color: date != null ? Colors.black : Colors.grey),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.6),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.4),
    );
  }
}

class StockTransferTable extends StatelessWidget {
  final List<MaterialRequest> requests;
  final Function(BuildContext, String, MaterialRequest, String) onShowActionMenu;

  const StockTransferTable({
    super.key,
    required this.requests,
    required this.onShowActionMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF1976F3), width: 0.4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          columns: const [
            DataColumn(label: Text("Request ID")),
            DataColumn(label: Text("Requested By")),
            DataColumn(label: Text("Requested On")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Origin")),
            DataColumn(label: Text("Destination")),
            DataColumn(label: Text("Actions")),
          ],
          rows: requests.map((request) {
            final dateTime = DateTime.tryParse(request.requestedOn);
            final formattedDate = dateTime != null
                ? DateFormat('dd MMM yyyy, HH:mm').format(dateTime)
                : request.requestedOn;

            return DataRow(
              cells: [
                DataCell(Text(request.name)),
                DataCell(Text(request.requestedBy)),
                DataCell(Text(formattedDate)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                DataCell(Text(request.originWarehouse)),
                DataCell(Text(request.destinationWarehouse)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => onShowActionMenu(context, request.name, request, request.status),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'approved':
        return Colors.indigo;
      case 'in transit':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
