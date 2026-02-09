import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';
import 'package:pos/presentation/purchase_invoice/bloc/purchase_invoice_bloc.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
import 'package:pos/screens/purchase/purchase_invoice_details.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;
}

class PurchaseInvoiceListScreen extends StatefulWidget {
  const PurchaseInvoiceListScreen({super.key});

  @override
  State<PurchaseInvoiceListScreen> createState() =>
      _PurchaseInvoiceListScreenState();
}

class _PurchaseInvoiceListScreenState extends State<PurchaseInvoiceListScreen> {
  final List<String> statusOptions = [
    'All',
    'Draft',
    'Unpaid',
    'Paid',
    'Overdue',
    'Cancelled',
  ];
  String selectedStatus = 'All';
  String? selectedSupplier;
  CurrentUserResponse? currentUserResponse;
  int currentPage = 1;
  final int itemsPerPage = 20;
  String company = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;

    setState(() {
      currentUserResponse = savedUser;
      company = savedUser.message.company.name;
    });

    _loadPurchaseInvoices();
    _fetchSuppliers();
  }

  void _fetchSuppliers({String? searchTerm}) {
    context.read<SuppliersBloc>().add(
      GetSuppliers(
        company: company,
        limit: 50,
        offset: 0,
        searchTerm: searchTerm,
      ),
    );
  }

  void _loadPurchaseInvoices() {
    context.read<PurchaseInvoiceBloc>().add(
      FetchPurchaseInvoicesEvent(
        company: company,
        page: currentPage,
        pageSize: itemsPerPage,
        status: selectedStatus == 'All' ? null : selectedStatus,
        supplier: selectedSupplier,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedStatus = 'All';
      selectedSupplier = null;
      currentPage = 1;
    });
    _loadPurchaseInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Purchase Invoices'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildStatusFilterButton()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSupplierFilterButton()),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear_all, color: Colors.grey),
                        tooltip: 'Clear Filters',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadPurchaseInvoices();
              },
              child: BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
                builder: (context, state) {
                  if (state is PurchaseInvoiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PurchaseInvoiceError) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: _buildErrorState(state.message),
                      ),
                    );
                  } else if (state is PurchaseInvoiceEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: _buildEmptyState(),
                      ),
                    );
                  } else if (state is PurchaseInvoiceLoaded) {
                    return _buildInvoiceTable(state.purchaseInvoices);
                  }
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: _buildEmptyState(),
                    ),
                  );
                },
              ),
            ),
          ),
          BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
            builder: (context, state) {
              if (state is PurchaseInvoiceLoaded) {
                return _buildPagination(state.totalCount);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          hint: const Text('Status'),
          items: statusOptions.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                selectedStatus = newValue;
                currentPage = 1;
              });
              _loadPurchaseInvoices();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSupplierFilterButton() {
    return InkWell(
      onTap: _showSupplierPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedSupplier ?? 'Supplier',
                style: TextStyle(
                  color: selectedSupplier != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSupplierPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SupplierPicker(
        company: company,
        selectedSupplier: selectedSupplier,
        onSupplierSelected: (supplierName) {
          setState(() {
            selectedSupplier = supplierName;
            currentPage = 1;
          });
          _loadPurchaseInvoices();
        },
      ),
    );
  }

  Widget _buildInvoiceTable(List<PurchaseInvoiceData> invoices) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 2,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              horizontalMargin: 8,
              columnSpacing: 12,
              columns: _buildTableColumns(isMobile),
              rows: invoices
                  .map((invoice) => _buildDataRow(invoice, isMobile))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns(bool isMobile) {
    return [
      const DataColumn(
        label: Text(
          'Invoice No',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn(
        label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      if (!isMobile) ...[
        const DataColumn(
          label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text(
            'Grand Total',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      const DataColumn(
        label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  DataRow _buildDataRow(PurchaseInvoiceData invoice, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            invoice.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(Text(invoice.supplierName)),
        if (!isMobile) ...[
          DataCell(Text(invoice.postingDate)),
          DataCell(
            Text(
              '${invoice.currency} ${NumberFormat('#,##0.00').format(invoice.grandTotal)}',
            ),
          ),
        ],
        DataCell(_buildStatusBadge(invoice.status)),
        DataCell(_buildActionMenu(invoice)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'unpaid':
        color = Colors.orange;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionMenu(PurchaseInvoiceData invoice) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handlePopupAction(value, invoice),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert, color: Colors.grey),
    );
  }

  void _handlePopupAction(String action, PurchaseInvoiceData invoice) {
    if (action == 'view') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PurchaseInvoiceDetailsScreen(invoiceNo: invoice.name),
        ),
      );
    }
  }

  Widget _buildPagination(int totalCount) {
    final totalPages = (totalCount / itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: $totalCount Invoices'),
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 1
                    ? () {
                        setState(() => currentPage--);
                        _loadPurchaseInvoices();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Page $currentPage of $totalPages'),
              IconButton(
                onPressed: currentPage < totalPages
                    ? () {
                        setState(() => currentPage++);
                        _loadPurchaseInvoices();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error Loading Invoices',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPurchaseInvoices,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, color: Colors.grey, size: 64),
          SizedBox(height: 16),
          Text(
            'No Invoices Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or pull to refresh',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SupplierPicker extends StatefulWidget {
  final String company;
  final String? selectedSupplier;
  final Function(String) onSupplierSelected;

  const _SupplierPicker({
    required this.company,
    this.selectedSupplier,
    required this.onSupplierSelected,
  });

  @override
  State<_SupplierPicker> createState() => _SupplierPickerState();
}

class _SupplierPickerState extends State<_SupplierPicker> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  void _fetchSuppliers({String? searchTerm}) {
    context.read<SuppliersBloc>().add(
      GetSuppliers(
        company: widget.company,
        limit: 50,
        offset: 0,
        searchTerm: searchTerm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Supplier',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) => _fetchSuppliers(searchTerm: val),
            ),
          ),
          Expanded(
            child: BlocBuilder<SuppliersBloc, SuppliersState>(
              builder: (context, state) {
                if (state is SuppliersLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SuppliersLoaded) {
                  return ListView.builder(
                    itemCount: state.response.data.suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = state.response.data.suppliers[index];
                      final isSelected =
                          widget.selectedSupplier == supplier.supplierName;
                      return ListTile(
                        onTap: () {
                          widget.onSupplierSelected(supplier.supplierName);
                          Navigator.pop(context);
                        },
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        title: Text(supplier.supplierName),
                        subtitle: Text(supplier.name),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
