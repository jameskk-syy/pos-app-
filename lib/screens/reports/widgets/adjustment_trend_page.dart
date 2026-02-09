import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class AdjustmentTrendPage extends StatefulWidget {
  const AdjustmentTrendPage({super.key});

  @override
  State<AdjustmentTrendPage> createState() => _AdjustmentTrendPageState();
}

class _AdjustmentTrendPageState extends State<AdjustmentTrendPage> {
  String companyName = '';
  String _currency = '';
  DateTimeRange? selectedDateRange;
  String? selectedWarehouse;
  String selectedAdjustmentType = 'all';

  final List<Map<String, String>> _adjustmentTypes = [
    {'value': 'all', 'label': 'All Adjustments'},
    {'value': 'increase', 'label': 'Increase Only'},
    {'value': 'decrease', 'label': 'Decrease Only'},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    _loadUserAndFetch();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(3000),
      initialDateRange: selectedDateRange,
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      _loadUserAndFetch();
    }
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';

      final posProfile = user['message']['pos_profile'] ?? {};
      final company = user['message']['company'] ?? {};
      _currency = posProfile['currency'] ?? company['default_currency'] ?? '';

      if (mounted && selectedDateRange != null) {
        context.read<ReportsBloc>().add(
          FetchPerformanceMetrics(
            ReportRequest(
              company: companyName,
              startDate: selectedDateRange!.start.toIso8601String().split(
                'T',
              )[0],
              endDate: selectedDateRange!.end.toIso8601String().split('T')[0],
              warehouse: selectedWarehouse,
              adjustmentType: selectedAdjustmentType,
              groupBy: 'date',
              itemGroup: '',
              customer: '',
              searchTerm: '',
            ),
          ),
        );
      }
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    setState(() {
      selectedDateRange = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      );
      selectedWarehouse = null;
      selectedAdjustmentType = 'all';
    });
    _loadUserAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Adjustment Trends'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PerformanceMetricsLoaded) {
            final trendsData = state.trendsResponse.data;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilterSection(),
                const SizedBox(height: 16),
                _buildChartContainer(
                  'Adjustment Count Trends',
                  _buildCountLineChart(trendsData),
                ),
                const SizedBox(height: 16),
                _buildChartContainer(
                  'Increases vs Decreases',
                  _buildIncDecBarChart(trendsData),
                ),
                const SizedBox(height: 16),
                _buildChartContainer(
                  'Adjusted Value Trends',
                  _buildValueLineChart(trendsData),
                ),
                const SizedBox(height: 16),
                _buildDataTable(trendsData),
              ],
            );
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildFilterSection() {
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
      children: [
        _buildDateFilter(),
        _buildWarehouseDropdown(),
        _buildAdjustmentTypeDropdown(),
      ],
    );
  }

  Widget _buildDateFilter() {
    return ReportDateFilter(
      selectedRange: selectedDateRange,
      onTap: _pickDateRange,
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
              hint: const Text(
                "All Warehouses",
                style: TextStyle(fontSize: 14),
              ),
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
                _loadUserAndFetch();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdjustmentTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedAdjustmentType,
          items: _adjustmentTypes.map((type) {
            return DropdownMenuItem(
              value: type['value'],
              child: Text(type['label']!, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedAdjustmentType = val);
              _loadUserAndFetch();
            }
          },
        ),
      ),
    );
  }

  Widget _buildChartContainer(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 250, child: chart),
        ],
      ),
    );
  }

  Widget _buildCountLineChart(List<AdjustmentTrendData> data) {
    if (data.isEmpty) return const Center(child: Text('No data'));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1),
        ),
        titlesData: _buildChartTitles(data),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(
                e.key.toDouble(),
                e.value.adjustmentCount.toDouble(),
              );
            }).toList(),
            isCurved: false,
            color: Colors.orange,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildIncDecBarChart(List<AdjustmentTrendData> data) {
    if (data.isEmpty) return const Center(child: Text('No data'));

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: _buildChartTitles(data),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.increaseCount.toDouble(),
                color: const Color(0xFF48BB78),
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: e.value.decreaseCount.toDouble(),
                color: const Color(0xFFF56565),
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildValueLineChart(List<AdjustmentTrendData> data) {
    if (data.isEmpty) return const Center(child: Text('No data'));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1),
        ),
        titlesData: _buildChartTitles(data),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.totalAdjustedValue);
            }).toList(),
            isCurved: false,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  FlTitlesData _buildChartTitles(List<AdjustmentTrendData> data) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            if (value == meta.max || value == meta.min) {
              return const SizedBox.shrink();
            }
            return Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.black45, fontSize: 10),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            int idx = value.toInt();
            if (idx >= 0 && idx < data.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  data[idx].period.split('-').last,
                  style: const TextStyle(color: Colors.black45, fontSize: 10),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildDataTable(List<AdjustmentTrendData> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adjustment Trends Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              horizontalMargin: 0,
              columnSpacing: 32,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(
                  label: Text(
                    'Period',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Adjustment Count',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Adjusted Qty',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Adjusted Value',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Increases',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Decreases',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.period)),
                    DataCell(Text(item.adjustmentCount.toString())),
                    DataCell(Text(item.totalAdjustedQty.toStringAsFixed(0))),
                    DataCell(
                      Text(
                        '$_currency ${_formatCurrency(item.totalAdjustedValue)}',
                      ),
                    ),
                    DataCell(Text(item.increaseCount.toString())),
                    DataCell(Text(item.decreaseCount.toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return value
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
