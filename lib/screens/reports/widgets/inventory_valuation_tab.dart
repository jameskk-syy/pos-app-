import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InventoryValuationTab extends StatefulWidget {
  const InventoryValuationTab({super.key});

  @override
  State<InventoryValuationTab> createState() => _InventoryValuationTabState();
}

class _InventoryValuationTabState extends State<InventoryValuationTab> {
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
          FetchInventoryValue(ReportRequest(company: companyName)),
        );
      }
    }
  }

  Future<void> _exportPdf(List<InventoryCategoryValue> data) async {
    try {
      await ReportPdfGenerator().generateInventoryValuationPdf(data, _currency);
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
        } else if (state is InventoryValueLoaded) {
          final data = state.response.data;

          double totalValue = 0;
          for (var item in data) {
            totalValue += item.totalValue;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _exportPdf(data),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.picture_as_pdf_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Export PDF',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MetricCard(
                title: 'Total Inventory Value',
                value: '$_currency ${_formatCurrency(totalValue)}',
                icon: Icons.inventory_2,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),

              ReportSectionCard(
                title: 'Value by Category',
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: data.map((item) {
                            final percentage =
                                (item.totalValue / totalValue) * 100;
                            return PieChartSectionData(
                              value: item.totalValue,
                              title: '${percentage.toStringAsFixed(1)}%',
                              color: [
                                Colors.blue,
                                Colors.black,
                              ][data.indexOf(item) % 2],
                              radius: 80,
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
                    const SizedBox(height: 24),
                    // Legend List
                    ...data.map((item) {
                      final color = [
                        Colors.blue,
                        Colors.black,
                      ][data.indexOf(item) % 2];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item.itemGroup,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$_currency ${_formatCurrency(item.totalValue)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('Load Data'));
      },
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
