import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/responses/purchase/grn_response.dart';
import 'package:pos/presentation/grn/bloc/grn_bloc.dart';
import 'package:pos/screens/purchase/grn_detail_screen.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;
}

class GrnListScreen extends StatefulWidget {
  const GrnListScreen({super.key});

  @override
  State<GrnListScreen> createState() => _GrnListScreenState();
}

class _GrnListScreenState extends State<GrnListScreen> {
  int currentPage = 1;
  final int pageSize = 20;
  String? searchTerm;
  String? selectedSupplier;

  @override
  void initState() {
    super.initState();
    _fetchGrns();
  }

  void _fetchGrns() {
    context.read<GrnBloc>().add(
      FetchGrnListEvent(
        page: currentPage,
        pageSize: pageSize,
        searchTerm: searchTerm,
        supplier: selectedSupplier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Goods Received Notes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchGrns(),
              child: BlocBuilder<GrnBloc, GrnState>(
                builder: (context, state) {
                  if (state is GrnListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GrnListError) {
                    return _buildErrorState(state.message);
                  } else if (state is GrnListEmpty) {
                    return _buildEmptyState();
                  } else if (state is GrnListLoaded) {
                    return _buildGrnTable(state.response.data);
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search GRNs...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  searchTerm = value.isEmpty ? null : value;
                  currentPage = 1;
                });
                _fetchGrns();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrnTable(List<GrnData> grns) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 16,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              horizontalMargin: 12,
              columnSpacing: 16,
              columns: [
                const DataColumn(
                  label: Text(
                    'GRN No',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Supplier',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isMobile)
                  const DataColumn(
                    label: Text(
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (!isMobile)
                  const DataColumn(
                    label: Text(
                      'Amount',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Action',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: grns
                  .map(
                    (grn) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            grn.name,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => _viewDetails(grn.name),
                        ),
                        DataCell(
                          SizedBox(
                            width: isMobile ? 100 : 150,
                            child: Text(
                              grn.supplierName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (!isMobile) DataCell(Text(grn.postingDate)),
                        if (!isMobile)
                          DataCell(
                            Text(
                              NumberFormat('#,##0.00').format(grn.grandTotal),
                            ),
                          ),
                        DataCell(_buildStatusBadge(grn.status)),
                        DataCell(
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.blue,
                            ),
                            onPressed: () => _viewDetails(grn.name),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _viewDetails(String grnNo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GrnDetailScreen(grnNo: grnNo)),
    );
  }

  Widget _buildPagination() {
    return BlocBuilder<GrnBloc, GrnState>(
      builder: (context, state) {
        if (state is GrnListLoaded) {
          final totalCount = state.response.meta.total;
          final totalPages = (totalCount / pageSize).ceil();
          if (totalPages <= 1) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 1
                      ? () {
                          setState(() => currentPage--);
                          _fetchGrns();
                        }
                      : null,
                ),
                Text('Page $currentPage of $totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages
                      ? () {
                          setState(() => currentPage++);
                          _fetchGrns();
                        }
                      : null,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No GRNs found'));
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }
}
