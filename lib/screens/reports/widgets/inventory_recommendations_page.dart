import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryRecommendationsPage extends StatefulWidget {
  const InventoryRecommendationsPage({super.key});

  @override
  State<InventoryRecommendationsPage> createState() =>
      _InventoryRecommendationsPageState();
}

class _InventoryRecommendationsPageState
    extends State<InventoryRecommendationsPage> {
  String companyName = '';
  String? selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';
      _fetchData();
    }
  }

  void _fetchData() {
    if (mounted) {
      context.read<ReportsBloc>().add(
        FetchAgingStock(
          ReportRequest(company: companyName, warehouse: selectedWarehouse),
        ),
      );
    }
  }

  void _resetFilters() {
    setState(() {
      selectedWarehouse = null;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Inventory Recommendations'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AgingStockLoaded) {
            final data = state.recommendationResponse.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterBar(),
                  const SizedBox(height: 24),
                  _buildPrioritySummary(data),
                  const SizedBox(height: 24),
                  _buildActionSummary(data),
                  const SizedBox(height: 24),
                  ReportSectionCard(
                    title: 'Aging Recommendations',
                    child: _buildRecommendationsTable(data),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return CollapsibleReportSection(
      title: 'Filters & Actions',
      actions: [
        TextButton.icon(
          onPressed: _resetFilters,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reset'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
      children: [_buildWarehouseDropdown()],
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        List<String> warehouses = [];
        if (state is StoreStateSuccess) {
          warehouses = state.storeGetResponse.message.data
              .map((w) => w.name)
              .toList();
        }

        return DropdownButtonFormField<String>(
          initialValue: selectedWarehouse,
          decoration: InputDecoration(
            hintText: "Warehouse",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
          items: warehouses
              .map(
                (w) => DropdownMenuItem(
                  value: w,
                  child: Text(w, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => selectedWarehouse = val);
            _fetchData();
          },
        );
      },
    );
  }

  Widget _buildPrioritySummary(List<AgingRecommendationData> data) {
    int total = data.length;
    int high = data.where((i) => i.priority.toLowerCase() == 'high').length;
    int medium = data.where((i) => i.priority.toLowerCase() == 'medium').length;
    int low = data.where((i) => i.priority.toLowerCase() == 'low').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _buildMetricGrid([
          _MetricData(
            'TOTAL ITEMS',
            total.toString(),
            const Color(0xFFF8FAFC),
            Colors.blue,
          ),
          _MetricData(
            'HIGH PRIORITY',
            high.toString(),
            const Color(0xFFEF4444),
            Colors.white,
          ),
          _MetricData(
            'MEDIUM PRIORITY',
            medium.toString(),
            const Color(0xFFF59E0B),
            Colors.white,
          ),
          _MetricData(
            'LOW PRIORITY',
            low.toString(),
            const Color(0xFF0EA5E9),
            Colors.white,
          ),
        ]),
      ],
    );
  }

  Widget _buildActionSummary(List<AgingRecommendationData> data) {
    int dispose = data
        .where((i) => i.recommendedAction.toLowerCase() == 'dispose')
        .length;
    int discount = data
        .where((i) => i.recommendedAction.toLowerCase() == 'discount')
        .length;
    int transfer = data
        .where((i) => i.recommendedAction.toLowerCase() == 'transfer')
        .length;
    int monitor = data
        .where((i) => i.recommendedAction.toLowerCase() == 'monitor')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Actions Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _buildMetricGrid([
          _MetricData(
            'DISPOSE',
            dispose.toString(),
            const Color(0xFFEF4444),
            Colors.white,
          ),
          _MetricData(
            'DISCOUNT',
            discount.toString(),
            const Color(0xFFF59E0B),
            Colors.white,
          ),
          _MetricData(
            'TRANSFER',
            transfer.toString(),
            const Color(0xFF0EA5E9),
            Colors.white,
          ),
          _MetricData(
            'MONITOR',
            monitor.toString(),
            const Color(0xFF48BB78),
            Colors.white,
          ),
        ]),
      ],
    );
  }

  Widget _buildMetricGrid(List<_MetricData> metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth < 600 ? 1.8 : 2.2,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) => _buildMetricCard(metrics[index]),
        );
      },
    );
  }

  Widget _buildMetricCard(_MetricData metric) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: metric.bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: metric.bgColor == const Color(0xFFF8FAFC)
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
        border: metric.bgColor == const Color(0xFFF8FAFC)
            ? Border.all(color: const Color(0xFFE2E8F0))
            : null,
      ),
      child: Column(
        children: [
          Text(
            metric.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: metric.textColor.withAlpha(
                metric.textColor == Colors.white ? 204 : 153,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: metric.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTable(List<AgingRecommendationData> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        columnSpacing: 24,
        columns: const [
          DataColumn(
            label: Text(
              'Item Code',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Item Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Warehouse',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Age Bracket',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Age (Days)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Current Stock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Priority',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Recommended Action',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Reason',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: data.map((item) {
          return DataRow(
            cells: [
              DataCell(
                Text(item.itemCode, style: const TextStyle(fontSize: 13)),
              ),
              DataCell(
                Text(item.itemName, style: const TextStyle(fontSize: 13)),
              ),
              DataCell(
                Text(item.warehouse, style: const TextStyle(fontSize: 13)),
              ),
              DataCell(
                Text(item.ageBracket, style: const TextStyle(fontSize: 13)),
              ),
              DataCell(
                Text('${item.ageDays}', style: const TextStyle(fontSize: 13)),
              ),
              DataCell(
                Text(
                  '${item.currentStock}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              DataCell(
                _buildStatusBadge(
                  item.priority,
                  _getPriorityColor(item.priority),
                ),
              ),
              DataCell(
                _buildStatusBadge(
                  item.recommendedAction,
                  _getActionColor(item.recommendedAction),
                ),
              ),
              DataCell(
                Text(
                  item.reason,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF0EA5E9);
    }
  }

  Color _getActionColor(String a) {
    switch (a.toLowerCase()) {
      case 'dispose':
        return const Color(0xFFEF4444);
      case 'discount':
        return const Color(0xFFF59E0B);
      case 'transfer':
        return const Color(0xFF0EA5E9);
      case 'monitor':
        return const Color(0xFF48BB78);
      default:
        return Colors.grey;
    }
  }
}

class _MetricData {
  final String label;
  final String value;
  final Color bgColor;
  final Color textColor;
  _MetricData(this.label, this.value, this.bgColor, this.textColor);
}
