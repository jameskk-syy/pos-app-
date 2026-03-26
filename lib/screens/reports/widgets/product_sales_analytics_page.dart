import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_state.dart';
import 'package:pos/widgets/reports/report_filter_card.dart';
import 'package:intl/intl.dart';

class ProductSalesAnalyticsPage extends StatefulWidget {
  const ProductSalesAnalyticsPage({super.key});

  @override
  State<ProductSalesAnalyticsPage> createState() => _ProductSalesAnalyticsPageState();
}

class _ProductSalesAnalyticsPageState extends State<ProductSalesAnalyticsPage> {
  final StorageService _storageService = getIt<StorageService>();
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00');
  
  String? _company;
  
  @override
  void initState() {
    super.initState();
    _loadCompanyAndFetch();
  }

  Future<void> _loadCompanyAndFetch() async {
    final userJson = await _storageService.getString('current_user');
    if (userJson != null) {
      final user = CurrentUserResponse.fromJson(jsonDecode(userJson));
      _company = user.message.company.name;
      if (mounted) {
        _onRefresh();
      }
    }
  }

  void _onRefresh({
    String? startDate,
    String? endDate,
    String? warehouse,
    String? itemGroup,
    String? paymentMethod,
  }) {
    if (_company == null) return;

    final request = ReportRequest(
      company: _company!,
      startDate: startDate,
      endDate: endDate,
      warehouse: warehouse,
      itemGroup: itemGroup,
      filters: paymentMethod != null ? {'payment_method': paymentMethod} : null,
    );

    context.read<ReportsBloc>().add(FetchProductSalesAnalytics(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Product Sales Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReportsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(state.message, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _onRefresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ProductSalesAnalyticsLoaded) {
                  return _buildReportContent(state);
                }
                return const Center(child: Text('Select filters and apply to view report'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, storeState) {
        List<String> warehouses = [];
        if (storeState is StoreStateSuccess) {
          warehouses = storeState.storeGetResponse.message.data
              .where((w) => w.disabled == 0)
              .map((w) => w.name)
              .toList();
        }
        return BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, catState) {
            List<String> groups = [];
            if (catState is CategoriesLoaded) {
              groups = catState.allCategories
                  .map((c) => c.itemGroupName)
                  .where((n) => n.isNotEmpty)
                  .toList();
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ReportFilterCard(
                warehouses: warehouses,
                itemGroups: groups,
                paymentMethods: const ['Cash', 'M-Pesa', 'Card', 'Bank Transfer'],
                onApply: (start, end, wh, ig, pm) {
                  _onRefresh(
                    startDate: start,
                    endDate: end,
                    warehouse: wh,
                    itemGroup: ig,
                    paymentMethod: pm,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportContent(ProductSalesAnalyticsLoaded state) {
    if (state.response.data.isEmpty) {
      return const Center(child: Text('No data found for the selected filters'));
    }

    final data = state.response.data;
    
    // Summary Metrics
    double totalRev = data.fold(0.0, (sum, item) => sum + item.totalRevenue);
    double totalQty = data.fold(0.0, (sum, item) => sum + item.totalQty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(totalRev, totalQty, data.length),
          const SizedBox(height: 24),
          _buildDataTable(data),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double revenue, double qty, int products) {
    return Row(
      children: [
        _buildMetricCard("Total Revenue", "KSh ${_currencyFormat.format(revenue)}", Colors.blue),
        const SizedBox(width: 12),
        _buildMetricCard("Total Quantity", qty.toStringAsFixed(0), Colors.green),
        const SizedBox(width: 12),
        _buildMetricCard("Products", products.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
          columns: const [
            DataColumn(label: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Item Group', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Avg Price', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Invoices', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: data.map((item) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(item.itemCode, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                DataCell(Text(item.itemGroup)),
                DataCell(Text(item.totalQty.toStringAsFixed(0))),
                DataCell(Text(_currencyFormat.format(item.totalRevenue))),
                DataCell(Text(_currencyFormat.format(item.averagePrice))),
                DataCell(Text(item.invoiceCount.toString())),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
