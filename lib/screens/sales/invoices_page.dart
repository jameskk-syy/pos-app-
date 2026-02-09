import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/presentation/invoices/bloc/invoices_bloc.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/widgets/sales/invoice_details.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'dart:convert';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _salesScrollController = ScrollController();
  final ScrollController _posScrollController = ScrollController();

  String? companyName;
  bool isFiltersExpanded = false;

  // Filters
  String selectedStatus = 'All';
  String? selectedCustomer;
  DateTimeRange? selectedDateRange;
  final List<String> statuses = [
    'All',
    'Paid',
    'Unpaid',
    'Cancelled',
    'Overdue',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCompany();
    _salesScrollController.addListener(
      () => _onScroll(_salesScrollController, false),
    );
    _posScrollController.addListener(
      () => _onScroll(_posScrollController, true),
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchInvoices();
      }
    });
  }

  void _onScroll(ScrollController controller, bool isPos) {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent * 0.9) {
      final state = context.read<InvoicesBloc>().state;
      if (state is InvoicesLoaded && state.hasMore) {
        _fetchInvoices(loadMore: true);
      }
    }
  }

  Future<void> _loadCompany() async {
    final storage = getIt<StorageService>();
    final userJson = await storage.getString('current_user');
    if (userJson != null) {
      final data = jsonDecode(userJson);
      setState(() {
        companyName = data['message']['company']?['name'];
      });
      _fetchInvoices();
    }
  }

  void _fetchInvoices({bool loadMore = false}) {
    if (companyName == null) return;

    final state = context.read<InvoicesBloc>().state;
    int offset = 0;
    if (loadMore && state is InvoicesLoaded) {
      offset = state.invoices.length;
    }

    context.read<InvoicesBloc>().add(
      GetInvoices(
        isPos: _tabController.index == 1,
        company: companyName!,
        offset: offset,
        status: selectedStatus,
        customer: selectedCustomer,
        fromDate: selectedDateRange?.start != null
            ? DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)
            : null,
        toDate: selectedDateRange?.end != null
            ? DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)
            : null,
        loadMore: loadMore,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _salesScrollController.dispose();
    _posScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.gray,
      appBar: AppBar(
        title: const Text(
          'Invoice Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: 'Sales Invoice'),
                  Tab(text: 'POS Invoices'),
                ],
              ),
            ),
            _buildFilterSection(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInvoiceList(false, _salesScrollController),
                  _buildInvoiceList(true, _posScrollController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => isFiltersExpanded = !isFiltersExpanded),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Search & Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(isFiltersExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (isFiltersExpanded) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                _buildDropdownFilter(
                  label: 'Status',
                  value: selectedStatus,
                  items: statuses,
                  onChanged: (val) {
                    setState(() => selectedStatus = val!);
                    _fetchInvoices();
                  },
                ),
                _buildDateFilter(),
                _buildCustomerFilter(),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedStatus = 'All';
                      selectedCustomer = null;
                      selectedDateRange = null;
                    });
                    _fetchInvoices();
                  },
                  child: const Text(
                    'Clear Filters',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceList(bool isPos, ScrollController scrollController) {
    return BlocBuilder<InvoicesBloc, InvoicesState>(
      builder: (context, state) {
        if (state is InvoicesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InvoicesError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (state is InvoicesLoaded) {
          if (state.invoices.isEmpty) {
            return const Center(child: Text('No invoices found'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isMobile = constraints.maxWidth < 700;

              return Card(
                margin: const EdgeInsets.all(16),
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: isMobile ? 20 : 40,
                        headingRowHeight: 48,
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 72,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        columns: _buildTableColumns(isMobile),
                        rows: state.invoices.map((invoice) {
                          return _buildInvoiceRow(invoice, isMobile);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: Text('Start searching for invoices'));
      },
    );
  }

  List<DataColumn> _buildTableColumns(bool isMobile) {
    if (isMobile) {
      return const [
        DataColumn(label: Text('Invoice ID')),
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Actions')),
      ];
    }
    return const [
      DataColumn(label: Text('Invoice ID')),
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('Customer')),
      DataColumn(label: Text('Amount')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Actions')),
    ];
  }

  DataRow _buildInvoiceRow(InvoiceListItem invoice, bool isMobile) {
    final amount =
        '${invoice.company} ${NumberFormat.currency(symbol: '').format(invoice.grandTotal)}';

    if (isMobile) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              invoice.name,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataCell(
            Text(
              invoice.customer,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataCell(
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  _viewInvoice(invoice);
                } else if (value == 'print') {
                  _printInvoice(invoice);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('View'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print, size: 18),
                      SizedBox(width: 8),
                      Text('Print'),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      );
    }

    return DataRow(
      cells: [
        DataCell(
          Text(
            invoice.name,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(Text(invoice.postingDate)),
        DataCell(Text(invoice.customer)),
        DataCell(
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataCell(_buildStatusBadge(invoice.status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () => _viewInvoice(invoice),
                tooltip: 'View',
              ),
              IconButton(
                icon: const Icon(Icons.print, color: Colors.blue),
                onPressed: () => _printInvoice(invoice),
                tooltip: 'Print',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partly paid' || 'partially paid':
        color = Colors.orange;
        break;
      case 'unpaid':
        color = Colors.red;
        break;
      case 'overdue':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
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

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Range',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: selectedDateRange,
              );
              if (picked != null) {
                setState(() => selectedDateRange = picked);
                _fetchInvoices();
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                suffixIcon: const Icon(
                  Icons.date_range,
                  size: 18,
                  color: Colors.blue,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
              child: Text(
                selectedDateRange == null
                    ? 'Select Dates'
                    : '${DateFormat('MMM d').format(selectedDateRange!.start)} - ${DateFormat('MMM d').format(selectedDateRange!.end)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerFilter() {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search...',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              hintStyle: const TextStyle(fontSize: 13),
            ),
            onChanged: (val) {
              selectedCustomer = val.isEmpty ? null : val;
              _fetchInvoices();
            },
          ),
        ],
      ),
    );
  }

  void _viewInvoice(InvoiceListItem invoice) {
    _showInvoiceDetails(invoice);
  }

  void _printInvoice(InvoiceListItem invoice) {
    _showInvoiceDetails(invoice);
  }

  void _showInvoiceDetails(InvoiceListItem invoice) {
    // Map InvoiceListItem to InvoiceResponse to use existing InvoiceDetailsWidget
    final invoiceResponse = InvoiceResponse(
      name: invoice.name,
      customer: invoice.customer,
      company: invoice.company,
      postingDate: invoice.postingDate,
      grandTotal: invoice.grandTotal,
      roundedTotal: invoice.roundedTotal,
      outstandingAmount: invoice.outstandingAmount,
      docstatus: invoice.docstatus,
    );

    final createInvoiceResponse = CreateInvoiceResponse(
      success: true,
      message: 'Invoice fetched successfully',
      data: invoiceResponse,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(invoice.name)),
          body: InvoiceDetailsWidget(response: createInvoiceResponse),
        ),
      ),
    );
  }
}
