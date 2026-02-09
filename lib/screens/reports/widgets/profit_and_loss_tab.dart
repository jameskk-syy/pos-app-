import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/accounting_reports_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProfitAndLossTab extends StatefulWidget {
  const ProfitAndLossTab({super.key});

  @override
  State<ProfitAndLossTab> createState() => _ProfitAndLossTabState();
}

class _ProfitAndLossTabState extends State<ProfitAndLossTab> {
  String companyName = '';
  DateTimeRange? _selectedRange;
  String _periodicity = 'Monthly';
  bool _showZeroRows = true;

  @override
  void initState() {
    super.initState();
    _selectedRange = DateTimeRange(
      start: DateTime(DateTime.now().year, DateTime.now().month, 1),
      end: DateTime.now(),
    );
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString =
        await storage.getString('current_user') ??
        await storage.getString('userData');
    if (userString != null) {
      final user = jsonDecode(userString);
      if (user['message'] != null && user['message']['company'] != null) {
        companyName = user['message']['company']['name'] ?? '';
      } else if (user['company'] != null) {
        companyName = user['company'] ?? '';
      } else {
        companyName = 'Troy'; // Fallback
      }

      if (mounted) {
        context.read<ReportsBloc>().add(
          FetchProfitAndLoss(
            ReportRequest(
              company: companyName,
              fromDate: _selectedRange != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedRange!.start)
                  : null,
              toDate: _selectedRange != null
                  ? DateFormat('yyyy-MM-dd').format(_selectedRange!.end)
                  : null,
              periodicity: _periodicity,
              showZeroRows: _showZeroRows ? 1 : 0,
              accumulatedValues: 0,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (state is ProfitAndLossLoaded) ...[
              _buildControlBar(state.response),
              const SizedBox(height: 24),
              _buildSummaryCards(state.response.reportSummary),
              const SizedBox(height: 24),
              ReportSectionCard(
                title: 'Profit and Loss Statement',
                child: _buildPLTable(state.response),
              ),
            ] else ...[
              _buildControlBar(null),
              const SizedBox(height: 24),
              if (state is ReportsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is ReportsError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserAndFetch,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(child: Text('Select filters to load report')),
            ],
          ],
        );
      },
    );
  }

  Widget _buildControlBar(ProfitAndLossResponse? response) {
    return CollapsibleReportSection(
      title: 'Filters & Actions',
      actions: [
        IconButton(
          onPressed: response != null ? () => _printPdf(response) : null,
          icon: Icon(
            Icons.picture_as_pdf_outlined,
            color: response != null
                ? const Color(0xFF64748B)
                : Colors.grey[400],
          ),
          tooltip: response != null ? 'Export PDF' : 'Load data to export',
        ),
        IconButton(
          onPressed: _loadUserAndFetch,
          icon: const Icon(Icons.refresh, size: 18),
          tooltip: 'Refresh',
          color: const Color(0xFF64748B),
        ),
      ],
      children: [
        ReportDateFilter(
          selectedRange: _selectedRange,
          onTap: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDateRange: _selectedRange,
            );
            if (range != null) {
              setState(() => _selectedRange = range);
              _loadUserAndFetch();
            }
          },
        ),
        _buildPeriodicityDropdown(),
        _buildZeroRowsSwitch(),
      ],
    );
  }

  Widget _buildPeriodicityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _periodicity,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          items: [
            'Monthly',
            'Quarterly',
            'Half-Yearly',
            'Yearly',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _periodicity = val);
              _loadUserAndFetch();
            }
          },
        ),
      ),
    );
  }

  Widget _buildZeroRowsSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Include Zeros',
            style: TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _showZeroRows,
              onChanged: (val) {
                setState(() => _showZeroRows = val);
                _loadUserAndFetch();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<ProfitAndLossSummary> summary) {
    if (summary.isEmpty) return const SizedBox.shrink();

    // Filter out separators and get key metrics
    final income = summary.firstWhere(
      (s) => s.label.toLowerCase().contains('income'),
      orElse: () => ProfitAndLossSummary(label: 'Income', value: 0.0),
    );
    final expense = summary.firstWhere(
      (s) => s.label.toLowerCase().contains('expense'),
      orElse: () => ProfitAndLossSummary(label: 'Expense', value: 0.0),
    );
    final profit = summary.firstWhere(
      (s) => s.label.toLowerCase().contains('profit'),
      orElse: () => ProfitAndLossSummary(label: 'Net Profit', value: 0.0),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB), // Vibrant Blue
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6), // Lighter Blue
            Color(0xFF1D4ED8), // Deeper Blue
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profit.label.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatMetricValue(profit.value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  label: income.label,
                  value: _formatMetricValue(income.value),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF22C55E), // Success Green
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white10),
              Expanded(
                child: _buildMiniMetric(
                  label: expense.label,
                  value: _formatMetricValue(expense.value),
                  icon: Icons.trending_down_rounded,
                  color: const Color(0xFFEF4444), // Danger Red
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMetricValue(dynamic val) {
    if (val is num) return _formatCurrency(val.toDouble());
    return val.toString();
  }

  Widget _buildPLTable(ProfitAndLossResponse response) {
    final visibleColumns = response.columns.where((c) => !c.hidden).toList();
    if (response.data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('No data found for the selected period'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        horizontalMargin: 0,
        headingRowHeight: 40,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 60,
        columns: visibleColumns.map((col) {
          return DataColumn(
            label: Text(
              col.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            numeric: col.fieldtype == 'Currency',
          );
        }).toList(),
        rows: response.data.map((row) {
          final bool isSummary =
              row.account.contains('Total') || row.account.contains('Profit');

          return DataRow(
            cells: visibleColumns.map((col) {
              final val = row.dynamicValues[col.fieldname];
              Widget cellContent;

              if (col.fieldname == 'account' ||
                  col.fieldname == 'account_name') {
                cellContent = Padding(
                  padding: EdgeInsets.only(left: row.indent * 16.0),
                  child: Text(
                    row.account,
                    style: TextStyle(
                      fontWeight: row.isGroup || isSummary
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSummary ? Colors.blue[900] : Colors.black87,
                    ),
                  ),
                );
              } else if (col.fieldtype == 'Currency') {
                final double amount = val is num
                    ? val.toDouble()
                    : (double.tryParse(val.toString()) ?? 0.0);
                cellContent = Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    fontWeight: row.isGroup || isSummary
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: amount < 0 ? Colors.red : Colors.black87,
                  ),
                );
              } else {
                cellContent = Text(val?.toString() ?? '');
              }

              return DataCell(cellContent);
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount);
  }

  Future<void> _printPdf(ProfitAndLossResponse response) async {
    final doc = pw.Document();
    final visibleColumns = response.columns.where((c) => !c.hidden).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Profit and Loss Statement',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        companyName,
                        style: const pw.TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Period: ${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            // Summary Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: response.reportSummary
                  .where((s) => s.type != 'separator')
                  .map(
                    (s) => pw.Column(
                      children: [
                        pw.Text(
                          s.label,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          _formatMetricValue(s.value),
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 30),
            // Table Section
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: visibleColumns
                      .map(
                        (col) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            col.label,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                // Rows
                ...response.data.map((row) {
                  final bool isBold =
                      row.isGroup ||
                      row.account.contains('Total') ||
                      row.account.contains('Profit');
                  return pw.TableRow(
                    children: visibleColumns.map((col) {
                      final val = row.dynamicValues[col.fieldname];
                      String text = '';
                      if (col.fieldtype == 'Currency') {
                        final double amount = val is num
                            ? val.toDouble()
                            : (double.tryParse(val.toString()) ?? 0.0);
                        text = _formatCurrency(amount);
                      } else {
                        text = val?.toString() ?? '';
                      }

                      return pw.Padding(
                        padding: pw.EdgeInsets.only(
                          left: col.fieldname == 'account'
                              ? (row.indent * 10.0 + 6.0)
                              : 6.0,
                          top: 6,
                          bottom: 6,
                          right: 6,
                        ),
                        child: pw.Text(
                          text,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: isBold
                                ? pw.FontWeight.bold
                                : pw.FontWeight.normal,
                          ),
                          textAlign: col.fieldtype == 'Currency'
                              ? pw.TextAlign.right
                              : pw.TextAlign.left,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildMiniMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
