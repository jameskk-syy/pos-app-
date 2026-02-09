import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_event.dart';
import 'package:pos/presentation/categories/bloc/categories_state.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryDaysOnHandPage extends StatefulWidget {
  const InventoryDaysOnHandPage({super.key});

  @override
  State<InventoryDaysOnHandPage> createState() =>
      _InventoryDaysOnHandPageState();
}

class _InventoryDaysOnHandPageState extends State<InventoryDaysOnHandPage> {
  String companyName = '';
  final TextEditingController _periodController = TextEditingController(
    text: '30',
  );
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? selectedWarehouse;
  String? selectedItemGroup;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  @override
  void dispose() {
    _periodController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';

      if (mounted) {
        _fetchFilterData();
        _fetchData();
      }
    }
  }

  void _fetchFilterData() {
    context.read<StoreBloc>().add(GetAllStores(company: companyName));
    context.read<CategoriesBloc>().add(LoadCategories());
  }

  void _fetchData() {
    if (mounted) {
      final periodText = _periodController.text.trim();
      final period = int.tryParse(periodText) ?? 30;
      context.read<ReportsBloc>().add(
        FetchStockMovement(
          ReportRequest(
            company: companyName,
            periodDays: period,
            warehouse: selectedWarehouse,
            itemGroup: selectedItemGroup,
          ),
        ),
      );
    }
  }

  void _resetFilters() {
    setState(() {
      selectedWarehouse = null;
      selectedItemGroup = null;
      _periodController.text = '30';
      _searchController.clear();
    });
    _fetchData();
  }

  Future<void> _exportPdf(List<DaysOnHandData> daysOnHandData) async {
    try {
      await ReportPdfGenerator().generateStockMovementPdf(
        [],
        daysOnHandData,
        companyName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Inventory Days on Hand'),
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
          } else if (state is StockMovementLoaded) {
            final daysOnHandData = state.daysOnHandResponse.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterSection(daysOnHandData),
                  const SizedBox(height: 24),
                  _buildSummaryMetrics(daysOnHandData),
                  const SizedBox(height: 24),
                  _buildChartSection(daysOnHandData),
                  const SizedBox(height: 24),
                  ReportSectionCard(
                    title: 'Days on Hand Analysis',
                    child: _buildDaysOnHandList(daysOnHandData),
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

  Widget _buildFilterSection(List<DaysOnHandData> daysOnHandData) {
    return CollapsibleReportSection(
      title: 'Filters & Actions',
      actions: [
        IconButton(
          onPressed: () => _exportPdf(daysOnHandData),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          tooltip: 'Export PDF',
          color: const Color(0xFF64748B),
        ),
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
      children: [
        _buildWarehouseDropdown(),
        _buildItemGroupDropdown(),
        _buildPeriodCard(),
      ],
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        List<String> warehouses = [];
        if (state is StoreStateSuccess) {
          warehouses = state.storeGetResponse.message.data
              .map((e) => e.name)
              .toList();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: selectedWarehouse,
              hint: const Text("Select Warehouse"),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text("All Warehouses"),
                ),
                ...warehouses.map(
                  (w) => DropdownMenuItem(value: w, child: Text(w)),
                ),
              ],
              onChanged: (val) {
                setState(() => selectedWarehouse = val);
                _fetchData();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemGroupDropdown() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        List<String> groups = [];
        if (state is CategoriesLoaded) {
          groups = state.allCategories.map((e) => e.name).toList();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: selectedItemGroup,
              hint: const Text("Select Item Group"),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text("All Item Groups"),
                ),
                ...groups.map(
                  (g) => DropdownMenuItem(value: g, child: Text(g)),
                ),
              ],
              onChanged: (val) {
                setState(() => selectedItemGroup = val);
                _fetchData();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Period Days (for average consumption calculation)',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _periodController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onSubmitted: (_) => _fetchData(),
          ),
          const SizedBox(height: 4),
          const Text(
            'Number of days to calculate average consumption (default: 30)',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics(List<DaysOnHandData> data) {
    final totalItems = data.length;
    final normalCount = data.where((e) => e.status == 'normal').length;
    final lowCount = data.where((e) => e.status == 'low').length;
    final criticalCount = data.where((e) => e.status == 'critical').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'TOTAL ITEMS',
              totalItems.toString(),
              const Color(0xFFF1F5F9),
              const Color(0xFF475569),
            ),
            _buildMetricCard(
              'NORMAL STATUS',
              normalCount.toString(),
              const Color(0xFF4CAF50),
              Colors.white,
            ),
            _buildMetricCard(
              'LOW STATUS',
              lowCount.toString(),
              const Color(0xFFFF9800),
              Colors.white,
            ),
            _buildMetricCard(
              'CRITICAL STATUS',
              criticalCount.toString(),
              const Color(0xFFF44336),
              Colors.white,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: title == 'TOTAL ITEMS' ? Colors.blue : textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<DaysOnHandData> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Take top 5 or 10 for the chart
    final chartData = data.take(10).toList();

    return ReportSectionCard(
      title: 'Days on Hand by Item',
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY:
                chartData
                    .map((e) => e.daysOnHand)
                    .reduce((a, b) => a > b ? a : b) +
                5,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < chartData.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          chartData[index].itemCode.split('-').last,
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            barGroups: chartData.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.daysOnHand,
                    color: const Color(0xFF2E7D32),
                    width: 40,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysOnHandList(List<DaysOnHandData> data) {
    if (data.isEmpty) return const Center(child: Text('No days on hand data'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width > 1000
              ? MediaQuery.of(context).size.width - 64
              : 800,
        ),
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
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
                'Current Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Avg Daily Sales',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Days On Hand',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: data.map((item) {
            Color statusColor = Colors.green;
            if (item.status == 'critical') {
              statusColor = Colors.red;
            } else if (item.status == 'low') {
              statusColor = Colors.orange;
            }

            return DataRow(
              cells: [
                DataCell(Text(item.itemCode)),
                DataCell(Text(item.itemName)),
                DataCell(Text(item.warehouse)),
                DataCell(Text(item.currentStock.toStringAsFixed(0))),
                DataCell(Text(item.avgDailySales.toStringAsFixed(2))),
                DataCell(Text(item.daysOnHand.toStringAsFixed(0))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
