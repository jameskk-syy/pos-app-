import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AgingStockTab extends StatefulWidget {
  const AgingStockTab({super.key});

  @override
  State<AgingStockTab> createState() => _AgingStockTabState();
}

class _AgingStockTabState extends State<AgingStockTab> {
  String companyName = '';
  String _currency = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
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

      if (mounted) {
        context.read<ReportsBloc>().add(
          FetchAgingStock(ReportRequest(company: companyName)),
        );
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
        } else if (state is AgingStockLoaded) {
          final summaryData = state.summaryResponse.data;
          final detailsData = state.detailsResponse.data;
          final expiryData = state.expiryResponse.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (expiryData.isNotEmpty) ...[
                _buildExpiryAlert(expiryData),
                const SizedBox(height: 24),
              ],

              ReportSectionCard(
                title: 'Stock Value by Age',
                child: _buildAgingChart(summaryData),
              ),

              const SizedBox(height: 24),
              ReportSectionCard(
                title: 'Aging Stock Details',
                child: _buildDetailsTable(detailsData),
              ),
            ],
          );
        }
        return const Center(child: Text('Load Data'));
      },
    );
  }

  Widget _buildExpiryAlert(List<ExpiryItemData> data) {
    // Filter for items expiring soon or expired
    final criticalItems = data.where((e) => e.daysToExpiry <= 30).toList();
    if (criticalItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expiry Alert',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  Text(
                    '${criticalItems.length} items expiring soon',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...criticalItems.take(3).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      item.daysToExpiry < 0
                          ? 'Expired'
                          : '${item.daysToExpiry} days',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.daysToExpiry < 0
                            ? Colors.red
                            : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (criticalItems.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '+ ${criticalItems.length - 3} more items',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgingChart(List<AgingSummaryData> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No aging data')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: data.map((item) {
                return PieChartSectionData(
                  value: item.totalValue,
                  title: '${item.percentage.toStringAsFixed(1)}%',
                  color: [Colors.blue, Colors.black][data.indexOf(item) % 2],
                  radius: 70,
                  showTitle: true,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: data.map((item) {
            final color = [Colors.blue, Colors.black][data.indexOf(item) % 2];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(item.ageRange, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsTable(List<AgingItemData> data) {
    if (data.isEmpty) return const Text('No detailed data');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columns: const [
          DataColumn(
            label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Range', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Days', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: data.take(20).map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.itemName)),
              DataCell(Text(item.ageRange)),
              DataCell(Text('${item.ageDays}')),
              DataCell(Text('${item.quantity}')),
              DataCell(Text('$_currency ${_formatCurrency(item.value)}')),
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
