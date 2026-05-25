import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos/utils/themes/app_colors.dart';

class SalesPerformanceChart extends StatelessWidget {
  final List<dynamic> salesData;
  final String selectedPeriod;

  const SalesPerformanceChart({
    super.key,
    required this.salesData,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sales Performance - Last $selectedPeriod", style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: salesData.isEmpty
                ? const Center(child: Text('No sales data available'))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: _calculateInterval(salesData),
                            getTitlesWidget: (value, _) => Text(_formatAxisValue(value), style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            getTitlesWidget: (v, _) {
                              if (v.toInt() >= salesData.length) return const Text('');
                              final date = salesData[v.toInt()].date ?? '';
                              return Text(date.length >= 10 ? date.substring(8, 10) : '', style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      minY: 0,
                      maxY: salesData.isEmpty ? 400 : _getMaxSales(salesData) * 1.2,
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          barWidth: 2,
                          color: const Color(0xFF3B82F6),
                          dotData: const FlDotData(show: false),
                          spots: salesData.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), (entry.value.sales ?? 0).toDouble())).toList(),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _calculateInterval(List salesData) {
    if (salesData.isEmpty) return 100;
    double max = _getMaxSales(salesData);
    if (max <= 100) return 20;
    if (max <= 500) return 100;
    if (max <= 1000) return 200;
    if (max <= 5000) return 1000;
    return (max / 5).roundToDouble();
  }

  String _formatAxisValue(double value) {
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(0)}K";
    return value.toInt().toString();
  }

  double _getMaxSales(List salesData) {
    double max = 0;
    for (var sale in salesData) {
      if (sale.sales != null && sale.sales > max) max = sale.sales.toDouble();
    }
    return max == 0 ? 100 : max;
  }
}

class MonthlySalesChart extends StatelessWidget {
  final List<dynamic> monthlyData;

  const MonthlySalesChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Monthly Sales Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: screenWidth < 600 ? 720 : screenWidth - 64,
              height: 240,
              child: monthlyData.isEmpty
                  ? const Center(child: Text('No monthly data available'))
                  : BarChart(
                      BarChartData(
                        maxY: _getMaxMonthlySales(monthlyData) > 0 ? _getMaxMonthlySales(monthlyData) * 1.2 : 100,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, _) => Text(_formatAxisValue(value), style: const TextStyle(fontSize: 10)),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                if (value.toInt() >= monthlyData.length) return const Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(monthlyData[value.toInt()].month ?? '', style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: monthlyData.asMap().entries.map((entry) {
                          final data = entry.value;
                          return BarChartGroupData(
                            x: entry.key,
                            barsSpace: 4,
                            barRods: [
                              BarChartRodData(toY: (data.net ?? 0).toDouble(), width: 10, borderRadius: BorderRadius.circular(4), color: const Color(0xFF22C55E)),
                              BarChartRodData(toY: (data.returns ?? 0).toDouble(), width: 10, borderRadius: BorderRadius.circular(4), color: const Color(0xFFF97316)),
                              BarChartRodData(toY: (data.sales ?? 0).toDouble(), width: 10, borderRadius: BorderRadius.circular(4), color: const Color(0xFF3B82F6)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              ChartLegend(color: Color(0xFF22C55E), text: "Net Sales"),
              ChartLegend(color: Color(0xFFF97316), text: "Returns"),
              ChartLegend(color: Color(0xFF3B82F6), text: "Total Sales"),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAxisValue(double value) {
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(0)}K";
    return value.toInt().toString();
  }

  double _getMaxMonthlySales(List monthlyData) {
    double max = 0;
    for (var data in monthlyData) {
      final sales = data.sales ?? 0;
      if (sales > max) max = sales.toDouble();
    }
    return max;
  }
}

class ChartLegend extends StatelessWidget {
  final Color color;
  final String text;

  const ChartLegend({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
