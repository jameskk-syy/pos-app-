import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryMovementPatternsPage extends StatefulWidget {
  const InventoryMovementPatternsPage({super.key});

  @override
  State<InventoryMovementPatternsPage> createState() =>
      _InventoryMovementPatternsPageState();
}

class _InventoryMovementPatternsPageState
    extends State<InventoryMovementPatternsPage> {
  String companyName = '';
  DateTimeRange? selectedDateRange;
  String selectedAnalysisType = 'Trend Analysis';
  String? selectedWarehouse;

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
      _fetchData();
    }
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';
      if (mounted) {
        context.read<StoreBloc>().add(GetAllStores(company: companyName));
        _fetchData();
      }
    }
  }

  void _fetchData() {
    if (selectedDateRange != null) {
      context.read<ReportsBloc>().add(
        FetchStockMovement(
          ReportRequest(
            company: companyName,
            startDate: selectedDateRange!.start.toIso8601String().split('T')[0],
            endDate: selectedDateRange!.end.toIso8601String().split('T')[0],
            analysisType: selectedAnalysisType.toLowerCase().contains('trend')
                ? 'trend'
                : 'seasonal',
            warehouse: selectedWarehouse,
          ),
        ),
      );
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    setState(() {
      selectedDateRange = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      );
      selectedAnalysisType = 'Trend Analysis';
      selectedWarehouse = null;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Inventory Movement Patterns'),
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
            final patternData = state.patternResponse.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModernFilters(),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                  _buildTimeSeriesSection(patternData.timeSeries),
                  const SizedBox(height: 24),
                  _buildItemTrendsChartSection(patternData.trends),
                  const SizedBox(height: 24),
                  _buildMovementTrendsTable(patternData.trends),
                  const SizedBox(height: 24),
                  _buildTimeSeriesTable(patternData.timeSeries),
                ],
              ),
            );
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildModernFilters() {
    return CollapsibleReportSection(
      title: 'Filters & Actions',
      actions: [
        IconButton(
          onPressed: _fetchData,
          icon: const Icon(Icons.refresh, size: 18),
          tooltip: 'Refresh',
          color: const Color(0xFF64748B),
        ),
        TextButton.icon(
          onPressed: _resetFilters,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Reset'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
      children: [
        ReportDateFilter(
          selectedRange: selectedDateRange,
          onTap: _pickDateRange,
        ),
        _buildWarehouseDropdown(),
        _buildAnalysisDropdown(),
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
              hint: const Text("All Warehouses"),
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

  Widget _buildAnalysisDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedAnalysisType,
          items: [
            'Trend Analysis',
            'Seasonal Analysis',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedAnalysisType = val);
              _fetchData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimeSeriesSection(List<MovementTimeSeries> data) {
    return ReportSectionCard(
      title: 'Movement Time Series',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendCircle('Issued', Colors.red),
              const SizedBox(width: 16),
              _buildLegendCircle('Net Movement', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendCircle('Received', Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          if (index %
                                  (data.length > 5 ? data.length ~/ 5 : 1) ==
                              0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                data[index].date.substring(5),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.issued))
                        .toList(),
                    isCurved: true,
                    color: Colors.red,
                    dotData: const FlDotData(show: true),
                    barWidth: 2,
                  ),
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(e.key.toDouble(), e.value.netMovement),
                        )
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    dotData: const FlDotData(show: true),
                    barWidth: 2,
                  ),
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.received))
                        .toList(),
                    isCurved: true,
                    color: Colors.green,
                    dotData: const FlDotData(show: true),
                    barWidth: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCircle(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildItemTrendsChartSection(List<MovementTrend> trends) {
    if (trends.isEmpty) return const SizedBox.shrink();

    // Take top items for bar chart
    final chartTrends = trends.take(10).toList();

    return ReportSectionCard(
      title: 'Item Movement Trends',
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100, // Percentage
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartTrends.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartTrends[index].itemCode.split('-').last,
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
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
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
                barGroups: chartTrends.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.changePercentage,
                        color: Colors.orange,
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendItem('Change Percentage', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMovementTrendsTable(List<MovementTrend> trends) {
    return ReportSectionCard(
      title: 'Movement Trends by Item',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 64,
          ),
          child: DataTable(
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
                  'Trend',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Change %',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Trend Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: trends.map((t) {
              Color statusColor = t.changePercentage >= 0
                  ? Colors.green
                  : Colors.red;
              return DataRow(
                cells: [
                  DataCell(Text(t.itemCode)),
                  DataCell(Text(t.itemName)),
                  DataCell(Text(t.trend)),
                  DataCell(Text('${t.changePercentage.toStringAsFixed(2)}%')),
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
                        t.status.toUpperCase(),
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
      ),
    );
  }

  Widget _buildTimeSeriesTable(List<MovementTimeSeries> data) {
    return ReportSectionCard(
      title: 'Time Series Data',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 64,
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn(
                label: Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Received',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Issued',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Net Movement',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: data.map((d) {
              return DataRow(
                cells: [
                  DataCell(Text(d.date)),
                  DataCell(Text(d.received.toStringAsFixed(0))),
                  DataCell(Text(d.issued.toStringAsFixed(0))),
                  DataCell(Text(d.netMovement.toStringAsFixed(0))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
