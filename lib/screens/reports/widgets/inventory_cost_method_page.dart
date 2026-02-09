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

class InventoryCostMethodPage extends StatefulWidget {
  const InventoryCostMethodPage({super.key});

  @override
  State<InventoryCostMethodPage> createState() =>
      _InventoryCostMethodPageState();
}

class _InventoryCostMethodPageState extends State<InventoryCostMethodPage> {
  String companyName = '';
  String _currency = '';
  String selectedPeriod = 'Monthly';

  // Filter state
  String? selectedWarehouse = 'All Warehouses';
  final TextEditingController _searchController = TextEditingController();
  List<String> warehouses = ['All Warehouses'];

  @override
  void initState() {
    super.initState();
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

      // Fetch currency
      final posProfile = user['message']['pos_profile'] ?? {};
      final company = user['message']['company'] ?? {};
      _currency = posProfile['currency'] ?? company['default_currency'] ?? '';

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

  void _fetchData() {
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedPeriod) {
      case 'Weekly':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'Quarterly':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case 'Yearly':
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        startDate = now.subtract(const Duration(days: 30));
    }

    String formatter(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    context.read<ReportsBloc>().add(
      FetchInventoryValue(
        ReportRequest(
          company: companyName,
          period: selectedPeriod.toLowerCase(),
          startDate: formatter(startDate),
          endDate: formatter(now),
          warehouse: selectedWarehouse == 'All Warehouses'
              ? null
              : selectedWarehouse,
          searchTerm: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cost Method Comparison'), elevation: 0),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is InventoryValueLoaded) {
            final costData = state.costMethodResponse.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 16),
                  _buildMethodCards(costData),
                  const SizedBox(height: 24),
                  ReportSectionCard(
                    title: 'Cost Method Comparison',
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          height: constraints.maxWidth < 600 ? 300 : 400,
                          child: _buildBarChart(costData),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoNote(),
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
      children: [_buildWarehouseDropdown()],
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

  Widget _buildMethodCards(Map<String, CostMethodData> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Define data for the cards
        final fifoVal = data['FIFO']?.totalValue ?? 0.0;
        final lifoVal = data['LIFO']?.totalValue ?? 0.0;
        final weightedVal = data['Weighted Average']?.totalValue ?? 0.0;

        final fifoItems = data['FIFO']?.itemCount ?? 0;
        final lifoItems = data['LIFO']?.itemCount ?? 0;
        final weightedItems = data['Weighted Average']?.itemCount ?? 0;

        final cards = [
          _buildSummaryCard('FIFO', fifoVal, fifoItems, Colors.blue, null),
          _buildSummaryCard(
            'LIFO',
            lifoVal,
            lifoItems,
            Colors.teal,
            'Calculation not implemented - requires separate valuation logic',
          ),
          _buildSummaryCard(
            'Weighted Average',
            weightedVal,
            weightedItems,
            Colors.orange,
            'Calculation not implemented - requires separate valuation logic',
          ),
        ];

        if (width < 900) {
          // Mobile & Tablet: 2 columns
          const double spacing = 12.0;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: cards.map((c) {
              return SizedBox(width: (width - spacing) / 2, child: c);
            }).toList(),
          );
        }

        // Large Tablet / Desktop: 3 columns
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 16),
            Expanded(child: cards[1]),
            const SizedBox(width: 16),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    int items,
    Color color,
    String? warning,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$items items',
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
          if (warning != null) ...[
            const SizedBox(height: 8),
            Text(
              warning,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.orange, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, CostMethodData> data) {
    final fifoVal = data['FIFO']?.totalValue ?? 0.0;
    final lifoVal = data['LIFO']?.totalValue ?? 0.0;
    final weightedVal = data['Weighted Average']?.totalValue ?? 0.0;

    // Find absolute max value to scale Y axis comfortably
    double maxY = [
      fifoVal,
      lifoVal,
      weightedVal,
    ].reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 100; // default height if all zeros

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                _formatCurrency(rod.toY),
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30, // reserved size for titles
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('FIFO', style: TextStyle(fontSize: 12)),
                    );
                  case 1:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('LIFO', style: TextStyle(fontSize: 12)),
                    );
                  case 2:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Weighted Average',
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                // Abbreviate large numbers
                if (value >= 1000000) {
                  return Text(
                    '${(value / 1000000).toStringAsFixed(1)}M',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                } else if (value >= 1000) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: fifoVal,
                color: Colors.blue,
                width: 50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: lifoVal,
                color: Colors.teal,
                width: 50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: weightedVal,
                color: Colors.orange,
                width: 50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.lightBlue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Note: Currently showing FIFO method. Other methods (LIFO, Weighted Average) require separate calculation logic and may not be fully implemented.',
              style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return '$_currency ${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
