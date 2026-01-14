import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PerformanceMetricsTab extends StatefulWidget {
  const PerformanceMetricsTab({super.key});

  @override
  State<PerformanceMetricsTab> createState() => _PerformanceMetricsTabState();
}

class _PerformanceMetricsTabState extends State<PerformanceMetricsTab> {
  String companyName = '';
  String _currency = '';
  DateTimeRange? selectedDateRange;

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
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';

      // Fetch currency
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
            ),
          ),
        );
      }
    }
  }

  Future<void> _exportPdf(
    InventoryAccuracyData accuracyData,
    List<InventoryVarianceData> varianceData,
  ) async {
    try {
      await ReportPdfGenerator().generatePerformanceMetricsPdf(
        accuracyData,
        varianceData,
        _currency,
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
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ReportsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is PerformanceMetricsLoaded) {
          final accuracyData = state.accuracyResponse.data;
          final varianceData = state.varianceResponse.data;
          final trendsData = state.trendsResponse.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: ReportDateFilter(
                      selectedRange: selectedDateRange,
                      onTap: _pickDateRange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _exportPdf(accuracyData, varianceData),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        height: 52,
                        width: 52,
                        child: const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Accuracy Card
              _buildAccuracyCard(accuracyData, _currency),

              const SizedBox(height: 24),
              ReportSectionCard(
                title: 'Adjustment Trends',
                child: _buildTrendsChart(trendsData),
              ),

              const SizedBox(height: 24),
              ReportSectionCard(
                title: 'Inventory Variances',
                child: _buildVarianceTable(varianceData),
              ),
            ],
          );
        }
        return const Center(child: Text('Load Data'));
      },
    );
  }

  Widget _buildAccuracyCard(InventoryAccuracyData data, String currency) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory Accuracy',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${data.accuracyRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total Variance',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '$currency ${_formatCurrency(data.totalVarianceValue)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: data.accuracyRate / 100,
              backgroundColor: Colors.black12,
              color: Colors.white,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsChart(List<AdjustmentTrendData> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No trend data')),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[value.toInt()].period,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.increaseCount.toDouble(),
                  color: Colors.green,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: e.value.decreaseCount.toDouble(),
                  color: Colors.red,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVarianceTable(List<InventoryVarianceData> data) {
    if (data.isEmpty) return const Text('No variance data');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columns: const [
          DataColumn(
            label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Book Qty',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Counted',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Variance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('%', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: data.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.itemName)),
              DataCell(Text(item.bookQty.toString())),
              DataCell(Text(item.countedQty.toString())),
              DataCell(
                Text(
                  item.varianceQty.toString(),
                  style: TextStyle(
                    color: item.varianceQty < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(Text('${item.variancePercentage.toStringAsFixed(1)}%')),
            ],
          );
        }).toList(),
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
