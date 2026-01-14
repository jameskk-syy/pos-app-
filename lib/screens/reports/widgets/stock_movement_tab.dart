import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StockMovementTab extends StatefulWidget {
  const StockMovementTab({super.key});

  @override
  State<StockMovementTab> createState() => _StockMovementTabState();
}

class _StockMovementTabState extends State<StockMovementTab> {
  String companyName = '';
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
      if (mounted && selectedDateRange != null) {
        context.read<ReportsBloc>().add(
          FetchStockMovement(
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
    List<InventoryTurnoverData> turnoverData,
    List<DaysOnHandData> daysOnHandData,
  ) async {
    try {
      await ReportPdfGenerator().generateStockMovementPdf(
        turnoverData,
        daysOnHandData,
        companyName, // Using company name as currency isn't ideal but signature matches string
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
        } else if (state is StockMovementLoaded) {
          final turnoverData = state.turnoverResponse.data;
          final daysOnHandData = state.daysOnHandResponse.data;

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
                      onTap: () => _exportPdf(turnoverData, daysOnHandData),
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
              const SizedBox(height: 24),
              ReportSectionCard(
                title: 'Inventory Turnover',
                child: _buildTurnoverList(turnoverData),
              ),
              const SizedBox(height: 24),
              ReportSectionCard(
                title: 'Days On Hand',
                child: _buildDaysOnHandList(daysOnHandData),
              ),
            ],
          );
        }
        return const Center(child: Text('Load Data'));
      },
    );
  }

  Widget _buildTurnoverList(List<InventoryTurnoverData> data) {
    if (data.isEmpty) return const Text('No turnover data');

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
              'Avg Stock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Turnover Rate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Days', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: data.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.itemName)),
              DataCell(Text(item.averageStock.toStringAsFixed(1))),
              DataCell(Text(item.turnoverRate.toStringAsFixed(2))),
              DataCell(Text(item.turnoverDays.toStringAsFixed(1))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaysOnHandList(List<DaysOnHandData> data) {
    if (data.isEmpty) return const Text('No days on hand data');

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
              'Current Stock',
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
          Color statusColor = Colors.black;
          if (item.status == 'critical') {
            statusColor = Colors.red;
          } else if (item.status == 'low') {
            statusColor = Colors.orange;
          } else {
            statusColor = Colors.green;
          }

          return DataRow(
            cells: [
              DataCell(Text(item.itemName)),
              DataCell(Text(item.currentStock.toStringAsFixed(1))),
              DataCell(Text(item.daysOnHand.toStringAsFixed(1))),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
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
    );
  }
}
