import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventorySummaryTab extends StatefulWidget {
  const InventorySummaryTab({super.key});

  @override
  State<InventorySummaryTab> createState() => _InventorySummaryTabState();
}

class _InventorySummaryTabState extends State<InventorySummaryTab> {
  String companyName = '';

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

      if (mounted) {
        context.read<ReportsBloc>().add(
          FetchInventorySummary(ReportRequest(company: companyName)),
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
        } else if (state is InventorySummaryLoaded) {
          final data = state.response.data;

          if (data.isEmpty) {
            return const Center(
              child: Text('No inventory summary data available.'),
            );
          }

          final bool isMobile = MediaQuery.of(context).size.width < 600;

          return SingleChildScrollView(
            padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(16),
            child: Card(
              margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(16),
              color: Colors.white,
              elevation: isMobile ? 0 : 1,
              shape: isMobile
                  ? const RoundedRectangleBorder()
                  : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Inventory Summary by Warehouse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: isMobile
                              ? MediaQuery.of(context).size.width - 32
                              : 0,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey.shade100,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Warehouse',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total Qty',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(
                                'Total Value',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              numeric: true,
                            ),
                          ],
                          rows: data.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item.warehouse)),
                                DataCell(
                                  Text(item.totalQty.toStringAsFixed(2)),
                                ),
                                DataCell(
                                  Text(item.totalValue.toStringAsFixed(2)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Center(child: Text('Load Data'));
      },
    );
  }
}
