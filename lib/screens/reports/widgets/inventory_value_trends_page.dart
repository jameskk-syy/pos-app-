import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/repository/store_repo.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryValueTrendsPage extends StatefulWidget {
  const InventoryValueTrendsPage({super.key});

  @override
  State<InventoryValueTrendsPage> createState() =>
      _InventoryValueTrendsPageState();
}

class _InventoryValueTrendsPageState extends State<InventoryValueTrendsPage> {
  String companyName = '';
  String selectedPeriod = 'Monthly';
  DateTimeRange? selectedDateRange;

  // Filter state
  String? selectedWarehouse = 'All Warehouses';
  List<String> warehouses = ['All Warehouses'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.year, 1, 1),
      end: now,
    );
    _loadUserAndFetch();
  }

  @override
  void dispose() {
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
        _fetchWarehouses();
        _fetchData();
      }
    }
  }

  Future<void> _fetchWarehouses() async {
    try {
      final storeResponse = await getIt<StoreRepo>().getAllStores(companyName);
      if (storeResponse.message.success == true) {
        if (mounted) {
          setState(() {
            final fetched = storeResponse.message.data
                .map((w) => w.warehouseName)
                .where((name) => name.isNotEmpty)
                .toList();
            warehouses = {'All Warehouses', ...fetched}.toList();

            if (!warehouses.contains(selectedWarehouse)) {
              selectedWarehouse = 'All Warehouses';
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching warehouses: $e');
    }
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

  void _fetchData() {
    if (selectedDateRange == null) return;

    String formatter(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    context.read<ReportsBloc>().add(
      FetchInventoryValue(
        ReportRequest(
          company: companyName,
          period: selectedPeriod.toLowerCase(),
          startDate: formatter(selectedDateRange!.start),
          endDate: formatter(selectedDateRange!.end),
          warehouse: selectedWarehouse == 'All Warehouses'
              ? null
              : selectedWarehouse,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Value Trends'), elevation: 0),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is InventoryValueLoaded) {
            final trendData = state.trendsResponse.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildTrendChart(trendData),
                ],
              ),
            );
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildFilters() {
    return CollapsibleReportSection(
      title: 'Filters & Actions',
      actions: [
        IconButton(
          onPressed: _fetchData,
          icon: const Icon(Icons.refresh, size: 18),
          tooltip: 'Refresh',
          color: const Color(0xFF64748B),
        ),
      ],
      children: [
        ReportDateFilter(
          selectedRange: selectedDateRange,
          onTap: _pickDateRange,
        ),
        _buildWarehouseDropdown(),
        _buildPeriodDropdown(),
      ],
    );
  }

  Widget _buildWarehouseDropdown() {
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
          value: selectedWarehouse,
          onChanged: (val) {
            setState(() => selectedWarehouse = val);
            _fetchData();
          },
          items: warehouses.map((w) {
            return DropdownMenuItem(
              value: w,
              child: Text(w, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown() {
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
          value: selectedPeriod,
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedPeriod = val);
              _fetchData();
            }
          },
          items: ['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<InventoryTrendData> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No trend data available')),
      );
    }
    return ReportSectionCard(
      title: 'Inventory Value Trends',
      child: AspectRatio(
        aspectRatio: 1.7,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18.0,
            left: 12.0,
            top: 24,
            bottom: 12,
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(data),
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: const Color(0xffe7e8ec), strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            data[index].period,
                            style: const TextStyle(
                              color: Color(0xff68737d),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
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
                    interval: _calculateInterval(data),
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatCompact(value),
                        style: const TextStyle(
                          color: Color(0xff67727d),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.left,
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 0),
              ),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              maxY: _calculateMaxY(data),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.totalValue);
                  }).toList(),
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF23b6e6), Color(0xFF02d39a)],
                  ),
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF23b6e6).withValues(alpha: 0.3),
                        const Color(0xFF02d39a).withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateInterval(List<InventoryTrendData> data) {
    if (data.isEmpty) return 1000;
    double maxVal = data
        .map((e) => e.totalValue)
        .reduce((a, b) => a > b ? a : b);
    return maxVal / 5;
  }

  double _calculateMaxY(List<InventoryTrendData> data) {
    if (data.isEmpty) return 1000;
    double maxVal = data
        .map((e) => e.totalValue)
        .reduce((a, b) => a > b ? a : b);
    return maxVal * 1.2;
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }
}
