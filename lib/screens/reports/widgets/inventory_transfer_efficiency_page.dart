import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryTransferEfficiencyPage extends StatefulWidget {
  const InventoryTransferEfficiencyPage({super.key});

  @override
  State<InventoryTransferEfficiencyPage> createState() =>
      _InventoryTransferEfficiencyPageState();
}

class _InventoryTransferEfficiencyPageState
    extends State<InventoryTransferEfficiencyPage> {
  String companyName = '';
  DateTimeRange? selectedDateRange;
  String? selectedWarehouse;
  String? fromWarehouse;
  String? toWarehouse;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    _loadUserAndFetch();
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

      if (mounted && selectedDateRange != null) {
        context.read<ReportsBloc>().add(
          FetchStockMovement(
            ReportRequest(
              company: companyName,
              startDate: selectedDateRange!.start.toIso8601String().split(
                'T',
              )[0],
              endDate: selectedDateRange!.end.toIso8601String().split('T')[0],
              warehouse: selectedWarehouse,
              fromWarehouse: fromWarehouse,
              toWarehouse: toWarehouse,
              groupBy: 'date',
              itemGroup: '',
              customer: '',
              searchTerm: '',
            ),
          ),
        );
      }
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    setState(() {
      selectedDateRange = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      );
      selectedWarehouse = null;
      fromWarehouse = null;
      toWarehouse = null;
    });
    _loadUserAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Transfer Efficiency'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is StockMovementLoaded) {
            final data = state.efficiencyResponse.data;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilterSection(),
                const SizedBox(height: 16),
                _buildStatusSummary(data),
                const SizedBox(height: 16),
                _buildEfficiencyMetrics(data),
                const SizedBox(height: 16),
                _buildPerformanceAssessment(data),
              ],
            );
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return CollapsibleReportSection(
      title: 'Filters & Actions',
      actions: [
        TextButton.icon(
          onPressed: _resetFilters,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reset'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
      children: [_buildDateRangePicker()],
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildDatePickerField(
            'Start Date *',
            selectedDateRange?.start,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDatePickerField('End Date *', selectedDateRange?.end),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(Icons.filter_alt_outlined, color: Colors.black26),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, DateTime? date) {
    return InkWell(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.black38),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      date != null
                          ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                          : 'dd/mm/yyyy',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.black38,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummary(TransferEfficiencyData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final int crossAxisCount = isMobile ? 2 : 4;
        final double itemWidth =
            (constraints.maxWidth - (12 * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatusCard(
              'TOTAL TRANSFERS',
              data.totalTransfers.toString(),
              null,
              const Color(0xFFF8FAFC),
              Colors.blue.shade700,
              itemWidth,
            ),
            _buildStatusCard(
              'COMPLETED',
              data.completedTransfers.toString(),
              '${data.onTimeRate.toStringAsFixed(1)}%',
              const Color(0xFF48BB78),
              Colors.white,
              itemWidth,
            ),
            _buildStatusCard(
              'PENDING',
              data.pendingTransfers.toString(),
              '0.0%',
              const Color(0xFFED8936),
              Colors.white,
              itemWidth,
            ),
            _buildStatusCard(
              'CANCELLED',
              data.cancelledTransfers.toString(),
              '0.0%',
              const Color(0xFFF56565),
              Colors.white,
              itemWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(
    String label,
    String value,
    String? percentage,
    Color bgColor,
    Color textColor,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: bgColor == const Color(0xFFF8FAFC)
            ? Border.all(color: const Color(0xFFE2E8F0))
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: bgColor == const Color(0xFFF8FAFC)
                  ? Colors.black38
                  : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: bgColor == const Color(0xFFF8FAFC)
                  ? Colors.blue.shade700
                  : Colors.white,
            ),
          ),
          if (percentage != null) ...[
            const SizedBox(height: 4),
            Text(
              percentage,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEfficiencyMetrics(TransferEfficiencyData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final int crossAxisCount = isMobile ? 2 : 3;
        final double itemWidth =
            (constraints.maxWidth - (12 * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildMetricDetailCard(
              'Average Completion Time',
              '${data.averageCompletionTimeHours.toStringAsFixed(1)} hrs',
              'Average time to complete transfers',
              itemWidth,
            ),
            _buildMetricDetailCard(
              'Transfer Accuracy',
              '${data.transferAccuracy.toStringAsFixed(1)}%',
              'Accuracy of completed transfers',
              itemWidth,
            ),
            _buildMetricDetailCard(
              'On-Time Rate',
              '${data.onTimeRate.toStringAsFixed(1)}%',
              'Percentage of transfers completed on time',
              itemWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricDetailCard(
    String title,
    String value,
    String subtitle,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF48BB78),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAssessment(TransferEfficiencyData data) {
    final bool isExcellent =
        data.onTimeRate >= 95.0 && data.transferAccuracy >= 95.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Assessment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_box,
                color: isExcellent ? const Color(0xFF48BB78) : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isExcellent
                      ? 'Excellent transfer performance. All metrics are above 95%.'
                      : 'Performance is within acceptable limits. Monitor lead times.',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
