import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class StockAgingReportPage extends StatefulWidget {
  const StockAgingReportPage({super.key});

  @override
  State<StockAgingReportPage> createState() => _StockAgingReportPageState();
}

class _StockAgingReportPageState extends State<StockAgingReportPage> {
  String companyName = '';
  final TextEditingController _thresholdController = TextEditingController(
    text: '5',
  );

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';
      _fetchData();
    }
  }

  void _fetchData() {
    if (mounted) {
      final threshold = double.tryParse(_thresholdController.text) ?? 5.0;
      context.read<ReportsBloc>().add(
        FetchAgingStock(
          ReportRequest(company: companyName, slowMovingThreshold: threshold),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Stock Aging Report'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AgingStockLoaded) {
            final detailsData = state.detailsResponse.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'View stock aging report with movement rate and slow-moving threshold analysis',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  CollapsibleReportSection(
                    title: 'Filters & Actions',
                    actions: [
                      TextButton.icon(
                        onPressed: _fetchData,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ],
                    children: [
                      Builder(
                        builder: (context) {
                          final isMobile =
                              MediaQuery.of(context).size.width < 600;
                          return TextField(
                            controller: _thresholdController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                            ],
                            decoration: modernInputDecoration(
                              'Slow Moving Threshold (Movement Rate)',
                              isMobile: isMobile,
                            ),
                            onSubmitted: (_) => _fetchData(),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Items with movement rate below this threshold will be marked as slow-moving',
                        style: TextStyle(color: Colors.black45, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildBucketSummary(detailsData),
                  const SizedBox(height: 24),
                  ...detailsData.entries.map((entry) {
                    if (entry.value.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: _buildDetailsSection(entry.key, entry.value),
                    );
                  }),
                ],
              ),
            );
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildBucketSummary(Map<String, List<AgingItemData>> data) {
    final buckets = ['0-30', '31-60', '61-90', '90+'];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust aspect ratio based on width to prevent vertical overflow
        double aspectRatio = constraints.maxWidth < 400 ? 1.6 : 2.1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: buckets.length,
          itemBuilder: (context, index) {
            final bucket = buckets[index];
            final items = data[bucket] ?? [];
            final totalQty = items.fold<double>(
              0,
              (sum, item) => sum + item.actualQty,
            );
            final slowMovingCount = items
                .where((item) => item.isSlowMoving)
                .length;

            return _buildBucketCard(
              '$bucket DAYS',
              '${items.length} Items',
              '${_formatNumber(totalQty)} units',
              slowMovingCount,
            );
          },
        );
      },
    );
  }

  Widget _buildBucketCard(
    String title,
    String itemCountLabel,
    String unitLabel,
    int slowMovingCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                itemCountLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                unitLabel,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
          if (slowMovingCount > 0) ...[
            const SizedBox(height: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFED8936),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$slowMovingCount slow-moving',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsSection(String range, List<AgingItemData> items) {
    final totalQty = items.fold<double>(0, (sum, item) => sum + item.actualQty);
    final slowMovingCount = items.where((item) => item.isSlowMoving).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  '$range Days (${items.length} items)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '${_formatNumber(totalQty)} units',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
                if (slowMovingCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFED8936),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$slowMovingCount slow-moving',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.blue,
                  size: 20,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 40,
              headingRowHeight: 40,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(
                  label: Text(
                    'Item Code',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Warehouse',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Age (Days)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Movement Rate',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
              rows: items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(item.itemCode, style: const TextStyle(fontSize: 13)),
                    ),
                    DataCell(
                      Text(
                        item.warehouse ?? '-',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatNumber(item.actualQty),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item.ageDays}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item.movementRate}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    DataCell(_buildStatusBadge(item.isSlowMoving)),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isSlowMoving) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSlowMoving ? const Color(0xFFED8936) : const Color(0xFF48BB78),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isSlowMoving ? 'Slow Moving' : 'Active',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatNumber(double val) {
    return val
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
