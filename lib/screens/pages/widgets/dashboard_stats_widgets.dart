import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/widgets/sales/sales_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  final dynamic stats;
  final double screenWidth;

  const DashboardStatsGrid({
    super.key,
    required this.stats,
    required this.screenWidth,
  });

  String _formatCurrency(num amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 1100 ? 3 : 4);
    double childAspectRatio = screenWidth < 600 ? 1.55 : (screenWidth < 1100 ? 1.8 : 2.0);

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
          percentage: stats?.totalPurchases != null && stats!.totalPurchases! > 0
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
}

class DashboardLoadingCards extends StatelessWidget {
  final double screenWidth;

  const DashboardLoadingCards({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 1100 ? 3 : 4);
    double childAspectRatio = screenWidth < 600 ? 1.55 : (screenWidth < 1100 ? 1.8 : 2.0);

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
}
