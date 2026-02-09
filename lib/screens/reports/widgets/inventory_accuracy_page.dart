import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryAccuracyPage extends StatefulWidget {
  const InventoryAccuracyPage({super.key});

  @override
  State<InventoryAccuracyPage> createState() => _InventoryAccuracyPageState();
}

class _InventoryAccuracyPageState extends State<InventoryAccuracyPage> {
  String companyName = '';
  String _currency = '';
  DateTimeRange? selectedDateRange;
  double _varianceThreshold = 5.0;
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
              varianceThreshold: _varianceThreshold,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Accuracy'), elevation: 0),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PerformanceMetricsLoaded) {
            final accuracyData = state.accuracyResponse.data;
            final varianceData = state.varianceResponse.data;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilterBar(),
                const SizedBox(height: 24),
                _buildAccuracyDashboard(accuracyData),
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
      ),
    );
  }

  Widget _buildFilterBar() {
    return CollapsibleReportSection(
      title: 'Filters & Actions',
      actions: [
        IconButton(
          onPressed: () {
            final state = context.read<ReportsBloc>().state;
            if (state is PerformanceMetricsLoaded) {
              _exportPdf(
                state.accuracyResponse.data,
                state.varianceResponse.data,
              );
            }
          },
          icon: const Icon(Icons.picture_as_pdf_outlined),
          tooltip: 'Export PDF',
          color: const Color(0xFF64748B),
        ),
      ],
      children: [
        ReportDateFilter(
          selectedRange: selectedDateRange,
          onTap: _pickDateRange,
        ),
        _buildWarehouseDropdown(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Thresh:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                  value: _varianceThreshold,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                  items: [1.0, 5.0, 10.0, 20.0]
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text("$e%")),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _varianceThreshold = val);
                      _loadUserAndFetch();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildAccuracyDashboard(InventoryAccuracyData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // 2 columns on mobile, 4 on desktop
        int crossAxisCount = w < 600 ? 2 : (w < 1100 ? 3 : 4);
        double childAspectRatio = w < 600 ? 1.5 : 2.0;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildMetricCard(
              'Accuracy Rate',
              '${data.accuracyRate.toStringAsFixed(1)}%',
              Colors.blue,
            ),
            _buildMetricCard(
              'Total Variance',
              '$_currency ${_formatCurrency(data.totalVarianceValue)}',
              Colors.red,
            ),
            _buildMetricCard(
              'Items Counted',
              data.totalItemsCounted.toString(),
              Colors.green,
            ),
            _buildMetricCard(
              'Variances Found',
              data.varianceCount.toString(),
              Colors.orange,
            ),
            _buildMetricCard(
              'Affected Items',
              data.itemsWithVariance.toString(),
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
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
