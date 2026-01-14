import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos/domain/requests/dashboard_request.dart';
import 'package:pos/domain/responses/dashboard_response.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/widgets/sales_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedPeriod = '30days';
  String? _selectedWarehouse;
  String? _selectedStaff;
  CurrentUserResponse? currentUserResponse;
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(
      FetchDashboardData(DashboardRequest(period: _selectedPeriod)),
    );

    context.read<StaffBloc>().add(GetUserListEvent());
    _loadCurrentUser();
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;

    setState(() {
      currentUserResponse = savedUser;
    });
    context.read<StoreBloc>().add(
      GetAllStores(company: savedUser.message.company.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<DashboardBloc>().add(RefreshDashboardData());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _filters(),
                    const SizedBox(height: 18),
                    if (state is DashboardLoading && state is! DashboardLoaded)
                      _buildLoadingCards(w)
                    else if (state is DashboardLoaded)
                      _buildStatsCards(w, state)
                    else if (state is DashboardError &&
                        state.cachedData != null)
                      _buildStatsCards(w, null, cachedData: state.cachedData)
                    else if (state is DashboardError)
                      _buildErrorCard(state.message)
                    else
                      _buildLoadingCards(w),
                    const SizedBox(height: 22),
                    if (state is DashboardLoaded) ...[
                      _buildSalesChart(state),
                      const SizedBox(height: 22),
                      _buildMonthlySalesChart(context, state),
                      const SizedBox(height: 22),
                      _buildSalesDueTable(state),
                      const SizedBox(height: 22),
                      _buildPurchasesDueTable(state),
                      const SizedBox(height: 22),
                      _buildStockAlertsTable(state),
                      const SizedBox(height: 22),
                      _buildPendingShipmentsTable(state),
                    ] else if (state is DashboardError &&
                        state.cachedData != null) ...[
                      _buildSalesChart(null, cachedData: state.cachedData),
                      const SizedBox(height: 22),
                      _buildMonthlySalesChart(
                        context,
                        null,
                        cachedData: state.cachedData,
                      ),
                      const SizedBox(height: 22),
                      _buildSalesDueTable(null, cachedData: state.cachedData),
                      const SizedBox(height: 22),
                      _buildPurchasesDueTable(
                        null,
                        cachedData: state.cachedData,
                      ),
                      const SizedBox(height: 22),
                      _buildStockAlertsTable(
                        null,
                        cachedData: state.cachedData,
                      ),
                      const SizedBox(height: 22),
                      _buildPendingShipmentsTable(
                        null,
                        cachedData: state.cachedData,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCards(double w) {
    int crossAxisCount = w < 600 ? 2 : (w < 1100 ? 3 : 4);
    double childAspectRatio = w < 600 ? 1.55 : (w < 1100 ? 1.8 : 2.0);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: childAspectRatio,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error loading dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<DashboardBloc>().add(RefreshDashboardData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    double w,
    DashboardLoaded? state, {
    DashboardResponse? cachedData,
  }) {
    final stats = state?.dashboardData.data?.stats ?? cachedData?.data?.stats;

    int crossAxisCount = w < 600 ? 2 : (w < 1100 ? 3 : 4);
    double childAspectRatio = w < 600 ? 1.55 : (w < 1100 ? 1.8 : 2.0);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: childAspectRatio,
      children: [
        SalesCard(
          backgroundColor: const Color(0xFFE5F3FE),
          title: "TOTAL SALES",
          value: "KSh ${_formatCurrency(stats?.totalSales ?? 0)}",
          netLabel: "Returns",
          netValue: "${stats?.salesReturnsCount ?? 0}",
          percentage: stats?.totalSales != null && stats!.totalSales! > 0
              ? "${((stats.salesReturns ?? 0) / stats.totalSales! * 100).toStringAsFixed(1)}%"
              : "0.0%",
          valueColor: Colors.blue,
          percentageColor: Colors.red,
        ),
        SalesCard(
          backgroundColor: const Color(0xFFFFF4E2),
          title: "NET SALES",
          value: "KSh ${_formatCurrency(stats?.netSales ?? 0)}",
          netLabel: "After returns",
          netValue: "KSh ${_formatCurrency(stats?.salesReturns ?? 0)}",
          valueColor: const Color(0xFFF97316),
        ),
        SalesCard(
          backgroundColor: const Color(0xFFE5F3FE),
          title: "TOTAL PURCHASES",
          value: "KSh ${_formatCurrency(stats?.totalPurchases ?? 0)}",
          netLabel: "Returns",
          netValue: "${stats?.purchaseReturnsCount ?? 0}",
          percentage:
              stats?.totalPurchases != null && stats!.totalPurchases! > 0
              ? "${((stats.purchaseReturns ?? 0) / stats.totalPurchases! * 100).toStringAsFixed(1)}%"
              : "0.0%",
          valueColor: const Color(0xFF8B5CF6),
          percentageColor: Colors.red,
        ),
        SalesCard(
          backgroundColor: const Color(0xFFDFF6DD),
          title: "PROFIT MARGIN",
          value: "${stats?.profitMargin?.toStringAsFixed(1) ?? '0.0'}%",
          netLabel: "Avg Transaction",
          netValue: "KSh ${_formatCurrency(stats?.averageTransaction ?? 0)}",
          valueColor: const Color(0xFF22C55E),
          percentageColor: const Color(0xFF22C55E),
        ),
      ],
    );
  }

  Widget _buildSalesChart(
    DashboardLoaded? state, {
    DashboardResponse? cachedData,
  }) {
    final salesData =
        state?.dashboardData.data?.salesLast30Days ??
        cachedData?.data?.salesLast30Days ??
        [];

    return _chartCard(
      "Sales Performance - Last $_selectedPeriod",
      SizedBox(
        height: 220,
        child: salesData.isEmpty
            ? const Center(child: Text('No sales data available'))
            : LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(salesData),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _calculateInterval(salesData),
                        getTitlesWidget: (value, _) => Text(
                          _formatAxisValue(value),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (v, _) {
                          if (v.toInt() >= salesData.length) {
                            return const Text('');
                          }
                          final date = salesData[v.toInt()].date ?? '';
                          return Text(
                            date.length >= 10 ? date.substring(8, 10) : '',
                            style: const TextStyle(fontSize: 10),
                          );
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
                      spots: salesData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.sales ?? 0,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
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
    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(0)}K";
    }
    return value.toInt().toString();
  }

  double _getMaxSales(List salesData) {
    double max = 0;
    for (var sale in salesData) {
      if (sale.sales != null && sale.sales > max) {
        max = sale.sales.toDouble();
      }
    }
    return max == 0 ? 100 : max;
  }

  Widget _buildMonthlySalesChart(
    BuildContext context,
    DashboardLoaded? state, {
    DashboardResponse? cachedData,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final monthlyData =
        state?.dashboardData.data?.monthlySales ??
        cachedData?.data?.monthlySales ??
        [];

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
          const Text(
            "Monthly Sales Overview",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
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
                        maxY: _getMaxMonthlySales(monthlyData) > 0
                            ? _getMaxMonthlySales(monthlyData) * 1.2
                            : 100,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, _) => Text(
                                _formatAxisValue(value),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                if (value.toInt() >= monthlyData.length) {
                                  return const Text('');
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    monthlyData[value.toInt()].month ?? '',
                                    style: const TextStyle(fontSize: 10),
                                  ),
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
                              BarChartRodData(
                                toY: (data.net ?? 0).toDouble(),
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0xFF22C55E),
                              ),
                              BarChartRodData(
                                toY: (data.returns ?? 0).toDouble(),
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0xFFF97316),
                              ),
                              BarChartRodData(
                                toY: (data.sales ?? 0).toDouble(),
                                width: 10,
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0xFF3B82F6),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: const [
              _Legend(color: Color(0xFF22C55E), text: "Net Sales"),
              _Legend(color: Color(0xFFF97316), text: "Returns"),
              _Legend(color: Color(0xFF3B82F6), text: "Total Sales"),
            ],
          ),
        ],
      ),
    );
  }

  double _getMaxMonthlySales(List monthlyData) {
    double max = 0;
    for (var data in monthlyData) {
      final sales = data.sales ?? 0;
      if (sales > max) max = sales.toDouble();
    }
    return max;
  }

  Widget _buildSalesDueTable(
    DashboardLoaded? state, {
    DashboardResponse? cachedData,
  }) {
    final salesDue =
        state?.dashboardData.data?.salesDue ?? cachedData?.data?.salesDue ?? [];

    return _buildTableCard(
      "Sales Due",
      salesDue.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No sales due'),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Invoice',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Customer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Amount',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Due Date',
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
                rows: salesDue.map((sale) {
                  return DataRow(
                    cells: [
                      DataCell(Text(sale.id ?? '-')),
                      DataCell(Text(sale.customer ?? '-')),
                      DataCell(
                        Text('KSh ${_formatCurrency(sale.amount ?? 0)}'),
                      ),
                      DataCell(Text(sale.dueDate ?? '-')),
                      DataCell(_buildStatusChip(sale.status ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildPurchasesDueTable(
    DashboardLoaded? state, {
    DashboardResponse? cachedData,
  }) {
    final purchasesDue =
        state?.dashboardData.data?.purchasesDue ??
        cachedData?.data?.purchasesDue ??
        [];

    return _buildTableCard(
      "Purchases Due",
      purchasesDue.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No purchases due'),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Invoice',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Supplier',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Amount',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Due Date',
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
                rows: purchasesDue.map((purchase) {
                  return DataRow(
                    cells: [
                      DataCell(Text(purchase.id ?? '-')),
                      DataCell(Text(purchase.supplier ?? '-')),
                      DataCell(
                        Text('KSh ${_formatCurrency(purchase.amount ?? 0)}'),
                      ),
                      DataCell(Text(purchase.dueDate ?? '-')),
                      DataCell(_buildStatusChip(purchase.status ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildStockAlertsTable(
    DashboardLoaded? state, {
    DashboardResponse? cachedData,
  }) {
    final stockAlerts =
        state?.dashboardData.data?.stockAlerts ??
        cachedData?.data?.stockAlerts ??
        [];

    return _buildTableCard(
      "Stock Alerts",
      stockAlerts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No stock alerts'),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.red.shade50),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Item ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Product',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Current Stock',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Min Stock',
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
                rows: stockAlerts.map((stock) {
                  return DataRow(
                    cells: [
                      DataCell(Text(stock.id ?? '-')),
                      DataCell(Text(stock.product ?? '-')),
                      DataCell(
                        Text(stock.currentStock?.toStringAsFixed(0) ?? '0'),
                      ),
                      DataCell(Text(stock.minStock?.toStringAsFixed(0) ?? '0')),
                      DataCell(
                        _buildStatusChip(stock.status ?? '-', isAlert: true),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildPendingShipmentsTable(
    DashboardLoaded? state, {
    DashboardResponse? cachedData,
  }) {
    final pendingShipments =
        state?.dashboardData.data?.pendingShipments ??
        cachedData?.data?.pendingShipments ??
        [];

    return _buildTableCard(
      "Pending Shipments",
      pendingShipments.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No pending shipments'),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
                columns: const [
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Order ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Customer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Items',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Est. Delivery',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: pendingShipments.map((shipment) {
                  return DataRow(
                    cells: [
                      DataCell(Text(shipment.id ?? '-')),
                      DataCell(Text(shipment.orderId ?? '-')),
                      DataCell(Text(shipment.customer ?? '-')),
                      DataCell(Text('${shipment.items ?? 0}')),
                      DataCell(_buildStatusChip(shipment.status ?? '-')),
                      DataCell(Text(shipment.estDelivery ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildStatusChip(String status, {bool isAlert = false}) {
    Color color;
    switch (status.toLowerCase()) {
      case 'overdue':
        color = Colors.red;
        break;
      case 'due soon':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'low':
        color = Colors.red;
        break;
      case 'critical':
        color = Colors.red.shade900;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTableCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(2)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    }
    return amount.toStringAsFixed(0);
  }

  Widget _filters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPeriodDropdown()),
            const SizedBox(width: 12),
            Expanded(child: _buildWarehouseDropdown()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStaffDropdown()),
            const SizedBox(width: 12),
            if (_selectedPeriod != '30days' ||
                _selectedWarehouse != null ||
                _selectedStaff != null)
              Expanded(child: _buildClearButton()),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodDropdown() {
    return GestureDetector(
      onTap: _showPeriodMenu,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.blue, width: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedPeriod == '30days'
                  ? 'Last 30 Days'
                  : _selectedPeriod == '7days'
                  ? 'Last 7 Days'
                  : _selectedPeriod == 'today'
                  ? 'Today'
                  : _selectedPeriod == 'yesterday'
                  ? 'Yesterday'
                  : _selectedPeriod == 'this_month'
                  ? 'This Month'
                  : _selectedPeriod == 'last_month'
                  ? 'Last Month'
                  : _selectedPeriod == 'custom'
                  ? 'Custom Range'
                  : 'Period',
              style: const TextStyle(fontSize: 13),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        List<String> options = ['All Warehouses'];
        if (state is StoreStateSuccess) {
          debugPrint("empty ${state.storeGetResponse.message.data.toString()}");
          options.addAll(
            state.storeGetResponse.message.data
                .where((w) => w.disabled == 0)
                .map((w) => w.name)
                .toList(),
          );
        }

        String displayText = _selectedWarehouse ?? 'All Warehouses';

        return GestureDetector(
          onTap: state is StoreStateLoading
              ? null
              : () => _showWarehouseMenu(options),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blue, width: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (state is StoreStateLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    displayText,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaffDropdown() {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        List<String> options = ['All Staff'];
        if (state is StaffStateSuccess) {
          options.addAll(
            state.staffUser.message.staffUsers
                .where((staff) => staff.enabled == 1)
                .map((staff) => staff.fullName)
                .toList(),
          );
        }

        String displayText = _selectedStaff ?? 'All Staff';

        return GestureDetector(
          onTap: state is StaffStateLoading
              ? null
              : () => _showStaffMenu(options),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blue, width: 0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (state is StaffStateLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    displayText,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClearButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = '30days';
          _selectedWarehouse = null;
          _selectedStaff = null;
        });
        _refreshDashboard();
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.clear, size: 16, color: Colors.red),
            SizedBox(width: 6),
            Text('Clear', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  void _showWarehouseMenu(List<String> options) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select Warehouse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final warehouse = options[index];
                        return ListTile(
                          title: Text(
                            warehouse,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedWarehouse == warehouse ||
                                      (_selectedWarehouse == null &&
                                          warehouse == 'All Warehouses')
                                  ? Colors.blue
                                  : Colors.grey.shade800,
                            ),
                          ),
                          trailing:
                              _selectedWarehouse == warehouse ||
                                  (_selectedWarehouse == null &&
                                      warehouse == 'All Warehouses')
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                  size: 22,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedWarehouse = warehouse == 'All Warehouses'
                                  ? null
                                  : warehouse;
                            });
                            Navigator.pop(context);
                            _refreshDashboard();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStaffMenu(List<String> options) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select Staff',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final staff = options[index];
                        return ListTile(
                          title: Text(
                            staff,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedStaff == staff ||
                                      (_selectedStaff == null &&
                                          staff == 'All Staff')
                                  ? Colors.blue
                                  : Colors.grey.shade800,
                            ),
                          ),
                          trailing:
                              _selectedStaff == staff ||
                                  (_selectedStaff == null &&
                                      staff == 'All Staff')
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                  size: 22,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedStaff = staff == 'All Staff'
                                  ? null
                                  : staff;
                            });
                            Navigator.pop(context);
                            _refreshDashboard();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPeriodMenu() {
    final periods = [
      {'value': '30days', 'label': 'Last 30 Days'},
      {'value': '7days', 'label': 'Last 7 Days'},
      {'value': 'today', 'label': 'Today'},
      {'value': 'yesterday', 'label': 'Yesterday'},
      {'value': 'this_month', 'label': 'This Month'},
      {'value': 'last_month', 'label': 'Last Month'},
      {'value': 'custom', 'label': 'Custom Range'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select Period',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: periods.length,
                      itemBuilder: (context, index) {
                        final period = periods[index];
                        return ListTile(
                          title: Text(
                            period['label']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedPeriod == period['value']
                                  ? Colors.blue
                                  : Colors.grey.shade800,
                            ),
                          ),
                          trailing: _selectedPeriod == period['value']
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                  size: 22,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedPeriod = period['value'];
                            });
                            Navigator.pop(context);
                            _refreshDashboard();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _refreshDashboard() {
    final request = DashboardRequest(
      period: _selectedPeriod,
      warehouse: _selectedWarehouse,
      staff: _selectedStaff,
    );

    context.read<DashboardBloc>().add(FetchDashboardData(request));
  }

  Widget _chartCard(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.blue, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
