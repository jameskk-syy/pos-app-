import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/domain/repository/store_repo.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryValueByCategoryPage extends StatefulWidget {
  const InventoryValueByCategoryPage({super.key});

  @override
  State<InventoryValueByCategoryPage> createState() =>
      _InventoryValueByCategoryPageState();
}

class _InventoryValueByCategoryPageState
    extends State<InventoryValueByCategoryPage> {
  String companyName = '';
  String _currency = '';
  String selectedPeriod = 'Monthly';

  // Filter state
  String? selectedWarehouse = 'All Warehouses';
  String? selectedItemGroup = 'All Item Groups';
  final TextEditingController _searchController = TextEditingController();

  List<String> warehouses = ['All Warehouses'];
  List<String> itemGroups = ['All Item Groups'];

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
        _fetchFilterOptions();
        _fetchData();
      }
    }
  }

  Future<void> _fetchFilterOptions() async {
    try {
      final results = await Future.wait([
        getIt<StoreRepo>().getAllStores(companyName),
        getIt<ProductsRepo>().getItemGroup(),
      ]);

      if (mounted) {
        setState(() {
          // Warehouses
          try {
            final storeResponse = results[0] as dynamic;
            if (storeResponse != null &&
                storeResponse.message != null &&
                storeResponse.message.success == true) {
              final fetched = (storeResponse.message.data as List)
                  .map((w) => w.warehouseName as String?)
                  .where((name) => name != null && name.isNotEmpty)
                  .cast<String>()
                  .toList();
              warehouses = {'All Warehouses', ...fetched}.toList();

              if (!warehouses.contains(selectedWarehouse)) {
                selectedWarehouse = 'All Warehouses';
              }
            }
          } catch (e) {
            debugPrint('Error parsing warehouses: $e');
          }

          // Item Groups
          try {
            final itemGroupResponse = results[1] as dynamic;
            if (itemGroupResponse != null &&
                itemGroupResponse.message != null &&
                itemGroupResponse.message.itemGroups != null) {
              final fetched = (itemGroupResponse.message.itemGroups as List)
                  .map((ig) => ig.itemGroupName as String?)
                  .where((name) => name != null && name.isNotEmpty)
                  .cast<String>()
                  .toList();
              itemGroups = {'All Item Groups', ...fetched}.toList();

              if (!itemGroups.contains(selectedItemGroup)) {
                selectedItemGroup = 'All Item Groups';
              }
            }
          } catch (e) {
            debugPrint('Error parsing item groups: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching filter options: $e');
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
          itemGroup: selectedItemGroup == 'All Item Groups'
              ? null
              : selectedItemGroup,
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
      appBar: AppBar(title: const Text('Value by Category'), elevation: 0),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is InventoryValueLoaded) {
            final categoryData = state.categoryResponse.data;

            // Calculate totals
            double totalValue = 0;
            double totalQty = 0;
            int totalItems = 0;

            for (var item in categoryData) {
              totalValue += item.totalValue;
              totalQty += item.totalQty;
              totalItems += item.itemCount;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 16),
                  if (categoryData.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No data available for selected filters'),
                      ),
                    )
                  else ...[
                    _buildSummaryCards(totalValue, totalQty, totalItems),
                    const SizedBox(height: 24),
                    ReportSectionCard(
                      title: 'Value Distribution by Category',
                      child: _buildPieChart(categoryData, totalValue),
                    ),
                    const SizedBox(height: 24),
                    ReportSectionCard(
                      title: 'Value by Category (Bar Chart)',
                      child: _buildBarChart(categoryData),
                    ),
                    const SizedBox(height: 24),
                    ReportSectionCard(
                      title: 'Category Breakdown',
                      child: _buildDetailTable(categoryData),
                    ),
                  ],
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
      children: [_buildWarehouseDropdown(), _buildItemGroupDropdown()],
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

  Widget _buildItemGroupDropdown() {
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
          value: selectedItemGroup,
          onChanged: (val) {
            setState(() => selectedItemGroup = val);
            _fetchData();
          },
          items: itemGroups.map((ig) {
            return DropdownMenuItem(
              value: ig,
              child: Text(ig, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    double totalValue,
    double totalQty,
    int totalItems,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust column count based on width
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
        double childAspectRatio = constraints.maxWidth < 600 ? 1.6 : 1.8;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          children: [
            _buildSummaryCard(
              'TOTAL VALUE',
              '$_currency ${_formatCurrency(totalValue)}',
              Colors.blue,
            ),
            _buildSummaryCard(
              'TOTAL QUANTITY',
              _formatNumber(totalQty),
              Colors.green,
            ),
            _buildSummaryCard(
              'TOTAL ITEMS',
              totalItems.toString(),
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<InventoryCategoryValue> data, double totalValue) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Column(
          children: [
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: data.map((item) {
                    final percentage = totalValue > 0
                        ? (item.totalValue / totalValue) * 100
                        : 0.0;
                    return PieChartSectionData(
                      value: item.totalValue,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: _getColor(data.indexOf(item)),
                      radius: isMobile ? 80 : 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: isMobile ? 30 : 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: data.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColor(data.indexOf(item)),
                        shape: BoxShape
                            .rectangle, // Square legend as per likely design
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item.itemGroup),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarChart(List<InventoryCategoryValue> data) {
    // Sort data by value for better visualization
    final sortedData = List<InventoryCategoryValue>.from(data)
      ..sort((a, b) => b.totalValue.compareTo(a.totalValue));

    // Limit to top 10 for bar chart to avoid clutter
    final displayData = sortedData.take(10).toList();
    double maxY = displayData.isNotEmpty
        ? displayData.first.totalValue * 1.2
        : 100;

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${displayData[group.x.toInt()].itemGroup}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: _formatCurrency(rod.toY),
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < displayData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        displayData[index].itemGroup,
                        style: const TextStyle(
                          color: Color(0xff7589a2),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ), // Hide left titles for cleaner look as per design usually
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: const Color(0xffe7e8ec), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: displayData.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.totalValue,
                  color: _getColor(data.indexOf(e.value)),
                  width: 30, // Thicker bars
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
    );
  }

  Widget _buildDetailTable(List<InventoryCategoryValue> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 800,
        ), // Ensure table has minimum width
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(
              label: Text(
                'Item Group',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Total Value',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Total Quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Item Count',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Percentage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
          ],
          rows: data.map((item) {
            // Need total value again for percentage calculation if not in item
            // However item has percentage
            return DataRow(
              cells: [
                DataCell(Text(item.itemGroup)),
                DataCell(Text(_formatCurrency(item.totalValue))),
                DataCell(Text(_formatNumber(item.totalQty))),
                DataCell(Text(item.itemCount.toString())),
                DataCell(Text('${item.percentage.toStringAsFixed(2)}%')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getColor(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.brown,
    ];
    return colors[index % colors.length];
  }

  String _formatCurrency(double value) {
    return value
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
