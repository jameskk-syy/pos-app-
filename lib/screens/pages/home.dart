import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/sales/dashboard_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/screens/pages/dashboard_sales_overview.dart';
import 'package:pos/domain/models/top_selling_item_model.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';
import 'package:pos/screens/pages/widgets/dashboard_filter_widgets.dart';
import 'package:pos/screens/pages/widgets/dashboard_stats_widgets.dart';
import 'package:pos/screens/pages/widgets/dashboard_chart_widgets.dart';
import 'package:pos/screens/pages/widgets/dashboard_table_widgets.dart';

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
    context.read<DashboardBloc>().add(FetchDashboardData(DashboardRequest(period: _selectedPeriod)));
    context.read<StaffBloc>().add(GetUserListEvent());
    _loadCurrentUser();
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;
    setState(() => currentUserResponse = savedUser);
    context.read<StoreBloc>().add(GetAllStores(company: savedUser.message.company.name));
  }

  void _refreshDashboard() {
    context.read<DashboardBloc>().add(FetchDashboardData(DashboardRequest(period: _selectedPeriod, warehouse: _selectedWarehouse, staff: _selectedStaff)));
  }

  void _showPeriodMenu() {
    final periods = {'30days': 'Last 30 Days', '7days': 'Last 7 Days', 'today': 'Today', 'yesterday': 'Yesterday', 'this_month': 'This Month', 'last_month': 'Last Month', 'custom': 'Custom Range'};
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => DashboardSelectionSheet(title: 'Select Period', options: periods.values.toList(), selectedValue: periods[_selectedPeriod], onSelected: (label) {
      setState(() => _selectedPeriod = periods.keys.firstWhere((k) => periods[k] == label));
      Navigator.pop(context); _refreshDashboard();
    }));
  }

  void _showWarehouseMenu(List<String> options) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => DashboardSelectionSheet(title: 'Select Warehouse', options: options, selectedValue: _selectedWarehouse ?? 'All Warehouses', onSelected: (warehouse) {
      setState(() => _selectedWarehouse = warehouse == 'All Warehouses' ? null : warehouse);
      Navigator.pop(context); _refreshDashboard();
    }));
  }

  void _showStaffMenu(List<String> options) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => DashboardSelectionSheet(title: 'Select Staff', options: options, selectedValue: _selectedStaff ?? 'All Staff', onSelected: (staff) {
      setState(() => _selectedStaff = staff == 'All Staff' ? null : staff);
      Navigator.pop(context); _refreshDashboard();
    }));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async { context.read<DashboardBloc>().add(RefreshDashboardData()); await Future.delayed(const Duration(milliseconds: 500)); },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              final stats = state is DashboardLoaded ? state.dashboardData.data?.stats : (state is DashboardError ? state.cachedData?.data?.stats : null);
              final salesData = state is DashboardLoaded ? (state.dashboardData.data?.salesLast30Days ?? []) : (state is DashboardError ? (state.cachedData?.data?.salesLast30Days ?? []) : []);
              final monthlyData = state is DashboardLoaded ? (state.dashboardData.data?.monthlySales ?? []) : (state is DashboardError ? (state.cachedData?.data?.monthlySales ?? []) : []);
              final salesDue = state is DashboardLoaded ? (state.dashboardData.data?.salesDue ?? []) : (state is DashboardError ? (state.cachedData?.data?.salesDue ?? []) : []);
              final purchasesDue = state is DashboardLoaded ? (state.dashboardData.data?.purchasesDue ?? []) : (state is DashboardError ? (state.cachedData?.data?.purchasesDue ?? []) : []);
              final stockAlerts = state is DashboardLoaded ? (state.dashboardData.data?.stockAlerts ?? []) : (state is DashboardError ? (state.cachedData?.data?.stockAlerts ?? []) : []);
              final shipments = state is DashboardLoaded ? (state.dashboardData.data?.pendingShipments ?? []) : (state is DashboardError ? (state.cachedData?.data?.pendingShipments ?? []) : []);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    DashboardFilter(
                      periodDropdown: DashboardFilterDropdown(label: _getPeriodLabel(), onTap: _showPeriodMenu),
                      warehouseDropdown: BlocBuilder<StoreBloc, StoreState>(builder: (context, storeState) {
                        List<String> opts = ['All Warehouses'];
                        if (storeState is StoreStateSuccess) opts.addAll(storeState.storeGetResponse.message.data.where((w) => w.disabled == 0).map((w) => w.name));
                        return DashboardFilterDropdown(label: _selectedWarehouse ?? 'All Warehouses', isLoading: storeState is StoreStateLoading, onTap: () => _showWarehouseMenu(opts));
                      }),
                      staffDropdown: BlocBuilder<StaffBloc, StaffState>(builder: (context, staffState) {
                        List<String> opts = ['All Staff'];
                        if (staffState is StaffStateSuccess) opts.addAll(staffState.staffUser.message.staffUsers.where((s) => s.enabled == 1).map((s) => s.fullName));
                        return DashboardFilterDropdown(label: _selectedStaff ?? 'All Staff', isLoading: staffState is StaffStateLoading, onTap: () => _showStaffMenu(opts));
                      }),
                      clearButton: (_selectedPeriod != '30days' || _selectedWarehouse != null || _selectedStaff != null) ? DashboardClearButton(onTap: () { setState(() { _selectedPeriod = '30days'; _selectedWarehouse = null; _selectedStaff = null; }); _refreshDashboard(); }) : null,
                    ),
                    const SizedBox(height: 18),
                    if (state is DashboardLoading && state is! DashboardLoaded) DashboardLoadingCards(screenWidth: w)
                    else if (state is DashboardLoaded || (state is DashboardError && state.cachedData != null)) DashboardStatsGrid(stats: stats, screenWidth: w)
                    else if (state is DashboardError) _buildErrorCard(state.message)
                    else DashboardLoadingCards(screenWidth: w),
                    const SizedBox(height: 22),
                    if (state is DashboardLoaded || (state is DashboardError && state.cachedData != null)) ...[
                      SalesPerformanceChart(salesData: salesData, selectedPeriod: _selectedPeriod!),
                      const SizedBox(height: 22),
                      MonthlySalesChart(monthlyData: monthlyData),
                      const SizedBox(height: 22),
                      _buildSalesOverviewSection(w, state),
                      const SizedBox(height: 22),
                      DashboardTableCard(title: "Sales Due", child: SalesDueTable(salesDue: salesDue)),
                      const SizedBox(height: 22),
                      DashboardTableCard(title: "Purchases Due", child: PurchasesDueTable(purchasesDue: purchasesDue)),
                      const SizedBox(height: 22),
                      DashboardTableCard(title: "Stock Alerts", child: StockAlertsTable(stockAlerts: stockAlerts)),
                      const SizedBox(height: 22),
                      DashboardTableCard(title: "Pending Shipments", child: ShipmentsTable(shipments: shipments)),
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

  String _getPeriodLabel() {
    final periods = {'30days': 'Last 30 Days', '7days': 'Last 7 Days', 'today': 'Today', 'yesterday': 'Yesterday', 'this_month': 'This Month', 'last_month': 'Last Month', 'custom': 'Custom Range'};
    return periods[_selectedPeriod] ?? 'Period';
  }

  Widget _buildSalesOverviewSection(double w, DashboardState state) {
    if (state is! DashboardLoaded && state is! DashboardError) return const SizedBox();
    final topSellingItems = state is DashboardLoaded ? state.topSellingItems : <TopSellingItem>[];
    final latestOrders = state is DashboardLoaded ? (state.latestOrders ?? []) : <InvoiceListItem>[];
    final recentPurchases = state is DashboardLoaded ? (state.recentPurchases ?? []) : <PurchaseInvoiceData>[];
    final widgets = [DashboardSalesOverviewWidgets.buildTopSellingItems(context, topSellingItems), DashboardSalesOverviewWidgets.buildLatestOrders(context, latestOrders.cast()), DashboardSalesOverviewWidgets.buildRecentPurchases(context, recentPurchases.cast())];
    if (w < 800) return Column(children: widgets.map((wi) => Padding(padding: const EdgeInsets.only(bottom: 16), child: wi)).toList());
    return GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: w < 1100 ? 1.5 : 2.0, children: widgets);
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
      child: Row(children: [
        Icon(Icons.error_outline, color: Colors.red.shade700), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Error loading dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)), Text(message, style: TextStyle(fontSize: 12, color: Colors.red.shade600))])),
        TextButton(onPressed: () => context.read<DashboardBloc>().add(RefreshDashboardData()), child: const Text('Retry'))
      ]),
    );
  }
}
