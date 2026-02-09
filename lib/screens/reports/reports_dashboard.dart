import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/screens/reports/widgets/inventory_valuation_tab.dart';
import 'package:pos/screens/reports/widgets/performance_metrics_tab.dart';
import 'package:pos/screens/reports/widgets/sales_analytics_tab.dart';
import 'package:pos/screens/reports/widgets/stock_movement_tab.dart';
import 'package:pos/screens/reports/widgets/aging_stock_tab.dart';
import 'package:pos/screens/reports/widgets/profit_and_loss_tab.dart';
import 'package:pos/screens/reports/widgets/inventory_summary_tab.dart';

class ReportsDashboardPage extends StatelessWidget {
  const ReportsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsBloc(reportsRepo: getIt()),
      child: DefaultTabController(
        length: 7,
        child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF121212)
              : AppColors.gray,
          appBar: AppBar(
            // backgroundColor:  Colors.grey[200],
            title: const Text('Reports & Analytics'),
            elevation: 0,
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Inventory Summary'),
                Tab(text: 'Sales Analytics'),
                Tab(text: 'Inventory Valuation'),
                Tab(text: 'Stock Movement'),
                Tab(text: 'Performance'),
                Tab(text: 'Aging Stock'),
                Tab(text: 'Accounting'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              InventorySummaryTab(key: ValueKey('Summary')),
              SalesAnalyticsTab(key: ValueKey('Sales')),
              InventoryValuationTab(key: ValueKey('Valuation')),
              StockMovementTab(key: ValueKey('Movement')),
              PerformanceMetricsTab(key: ValueKey('Performance')),
              AgingStockTab(key: ValueKey('Aging')),
              ProfitAndLossTab(key: ValueKey('Accounting')),
            ],
          ),
        ),
      ),
    );
  }
}
