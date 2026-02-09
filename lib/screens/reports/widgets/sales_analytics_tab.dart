import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/repository/crm_repo.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/domain/repository/store_repo.dart';
import 'package:pos/domain/requests/sales/get_customer_request.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class SalesAnalyticsTab extends StatefulWidget {
  const SalesAnalyticsTab({super.key});

  @override
  State<SalesAnalyticsTab> createState() => _SalesAnalyticsTabState();
}

class _SalesAnalyticsTabState extends State<SalesAnalyticsTab> {
  String companyName = '';
  String _currency = '';
  DateTimeRange? selectedDateRange;

  // Filter State
  String? selectedWarehouse = 'All Warehouses';
  String? selectedItemGroup = 'All Item Groups';
  String? selectedCustomer = 'All Customers';
  String selectedGroupBy = 'Customer';
  final TextEditingController _searchController = TextEditingController();

  List<String> warehouses = ['All Warehouses'];
  List<String> itemGroups = ['All Item Groups'];
  List<String> customers = ['All Customers'];
  final List<String> groupByOptions = ['Date', 'Item Group', 'Customer'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    _loadUserAndFetch();
    _fetchFilterOptions();
  }

  Future<void> _fetchFilterOptions() async {
    try {
      final results = await Future.wait([
        getIt<StoreRepo>().getAllStores(companyName),
        getIt<ProductsRepo>().getItemGroup(),
        getIt<CrmRepo>().getAllCustomers(
          CustomerRequest(company: companyName, limit: 1000),
        ),
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

          // Customers
          try {
            final customerResponse = results[2] as dynamic;
            if (customerResponse != null &&
                customerResponse.message != null &&
                customerResponse.message.success == true) {
              final fetched = (customerResponse.message.data as List)
                  .map((c) => c.customerName as String?)
                  .where((name) => name != null && name.isNotEmpty)
                  .cast<String>()
                  .toList();
              customers = {'All Customers', ...fetched}.toList();

              if (!customers.contains(selectedCustomer)) {
                selectedCustomer = 'All Customers';
              }
            }
          } catch (e) {
            debugPrint('Error parsing customers: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching filter options: $e');
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
      _loadUserAndFetch();
    }
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';

      // Fetch currency: Try POS Profile first, then Company default
      final posProfile = user['message']['pos_profile'] ?? {};
      final company = user['message']['company'] ?? {};
      _currency = posProfile['currency'] ?? company['default_currency'] ?? '';

      if (mounted && selectedDateRange != null) {
        context.read<ReportsBloc>().add(
          FetchSalesAnalytics(
            ReportRequest(
              company: companyName,
              startDate: selectedDateRange!.start.toIso8601String().split(
                'T',
              )[0],
              endDate: selectedDateRange!.end.toIso8601String().split('T')[0],
              warehouse: selectedWarehouse == 'All Warehouses'
                  ? null
                  : selectedWarehouse,
              itemGroup: selectedItemGroup == 'All Item Groups'
                  ? null
                  : selectedItemGroup,
              customer: selectedCustomer == 'All Customers'
                  ? null
                  : selectedCustomer,
              groupBy: selectedGroupBy.toLowerCase().replaceAll(' ', '_'),
              searchTerm: _searchController.text.isEmpty
                  ? null
                  : _searchController.text,
            ),
          ),
        );
      }
    }
  }

  Future<void> _exportPdf(SalesAnalyticsData data) async {
    try {
      await ReportPdfGenerator().generateSalesAnalyticsPdf(data, _currency);
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
        } else if (state is SalesAnalyticsLoaded) {
          final data = state.response.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFilters(context),
              const SizedBox(height: 16),
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
              _buildSummaryCards(data.summary, _currency),
              const SizedBox(height: 24),
              ReportSectionCard(
                title: 'Daily Sales Trend',
                child: SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
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
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 &&
                                  index < data.dailySales.length) {
                                final date = data.dailySales[index].date;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    date.length >= 10
                                        ? date.substring(5)
                                        : date,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            interval: 1,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.dailySales.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              e.value.totalAmount,
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withValues(alpha: 0.3),
                                Colors.blue.withValues(alpha: 0.0),
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
              const SizedBox(height: 24),
              ReportSectionCard(
                title: 'Revenue by Item Group',
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: data.revenueByItemGroup.map((group) {
                            return PieChartSectionData(
                              value: group.percentage,
                              title: '${group.percentage.toStringAsFixed(1)}%',
                              color: [
                                Colors.blue,
                                Colors.black,
                              ][data.revenueByItemGroup.indexOf(group) % 2],
                              radius: 25,
                              showTitle: false,
                            );
                          }).toList(),
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: data.revenueByItemGroup.map((group) {
                        final color = [
                          Colors.blue,
                          Colors.black,
                        ][data.revenueByItemGroup.indexOf(group) % 2];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${group.itemGroup} (${group.percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
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

  Widget _buildSummaryCards(dynamic summary, String currency) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            title: 'Total Revenue',
            value: '$currency ${_formatCurrency(summary.totalRevenue)}',
            icon: Icons.attach_money,
            color: Colors.green,
            trend: '+12%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MetricCard(
            title: 'Total Invoices',
            value: '${summary.totalInvoices}',
            icon: Icons.receipt_long,
            color: Colors.blue,
            trend: '+5%',
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return ReportFilterSection(
      searchController: _searchController,
      onSearch: _loadUserAndFetch,
      children: [
        FilterInput(
          label: 'Date Range',
          child: ReportDateFilter(
            selectedRange: selectedDateRange,
            onTap: _pickDateRange,
          ),
        ),
        FilterInput(
          label: 'Warehouse',
          child: _buildDropdown(selectedWarehouse, warehouses, (val) {
            setState(() => selectedWarehouse = val);
            _loadUserAndFetch();
          }, 'All Warehouses'),
        ),
        FilterInput(
          label: 'Item Group',
          child: _buildDropdown(selectedItemGroup, itemGroups, (val) {
            setState(() => selectedItemGroup = val);
            _loadUserAndFetch();
          }, 'All Item Groups'),
        ),
        FilterInput(
          label: 'Customer',
          child: _buildDropdown(selectedCustomer, customers, (val) {
            setState(() => selectedCustomer = val);
            _loadUserAndFetch();
          }, 'All Customers'),
        ),
        FilterInput(
          label: 'Group By',
          child: _buildDropdown(selectedGroupBy, groupByOptions, (val) {
            if (val != null) {
              setState(() => selectedGroupBy = val);
              _loadUserAndFetch();
            }
          }, 'Customer'),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    Function(String?) onChanged,
    String hint,
  ) {
    // Ensure value exists in items
    final safeItems = items.toSet().toList();
    String? safeValue = value;
    if (safeValue != null && !safeItems.contains(safeValue)) {
      safeValue = safeItems.isNotEmpty ? safeItems.first : null;
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: safeValue,
      decoration: modernInputDecoration(hint, isMobile: isMobile),
      items: safeItems.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              fontSize: isMobile ? 11 : 13,
              color: const Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
