import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/inventory_valuation_tab.dart';
import 'package:pos/screens/reports/widgets/performance_metrics_tab.dart';
import 'package:pos/screens/reports/widgets/sales_analytics_tab.dart';
import 'package:pos/screens/reports/widgets/stock_movement_tab.dart';
import 'package:pos/screens/reports/widgets/aging_stock_tab.dart';

class ReportsDashboardPage extends StatelessWidget {
  const ReportsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsBloc(reportsRepo: getIt()),
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            // backgroundColor:  Colors.grey[200],
            title: const Text('Reports & Analytics'),
            elevation: 0,
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Sales Analytics'),
                Tab(text: 'Inventory Valuation'),
                Tab(text: 'Stock Movement'),
                Tab(text: 'Performance'),
                Tab(text: 'Aging Stock'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              SalesAnalyticsTab(),
              InventoryValuationTab(),
              StockMovementTab(),
              PerformanceMetricsTab(),
              AgingStockTab(),
            ],
          ),
        ),
      ),
    );
  }
}
