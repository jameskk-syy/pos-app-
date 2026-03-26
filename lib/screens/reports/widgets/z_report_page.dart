import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/models/reports/z_report_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/sales/bloc/pos_opening_entries_bloc.dart';
import 'package:intl/intl.dart';

class ZReportPage extends StatefulWidget {
  const ZReportPage({super.key});

  @override
  State<ZReportPage> createState() => _ZReportPageState();
}

class _ZReportPageState extends State<ZReportPage> {
  final StorageService _storageService = getIt<StorageService>();
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00');
  String? _company;
  String? _selectedEntryId;

  @override
  void initState() {
    super.initState();
    _loadCompanyAndFetchSessions();
  }

  Future<void> _loadCompanyAndFetchSessions() async {
    final userJson = await _storageService.getString('current_user');
    if (userJson != null) {
      final user = CurrentUserResponse.fromJson(jsonDecode(userJson));
      _company = user.message.company.name;
      if (mounted) {
        context.read<PosOpeningEntriesBloc>().add(GetPosOpeningEntries(company: _company!));
      }
    }
  }

  void _fetchZReport(String entryId) {
    setState(() => _selectedEntryId = entryId);
    final request = ReportRequest(
      company: _company!,
      filters: {'pos_opening_entry': entryId},
    );
    context.read<ReportsBloc>().add(FetchZReport(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Z-Report (EOD Summary)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSessionSelector(),
          Expanded(
            child: BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReportsError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is ZReportLoaded) {
                  if (state.response.data == null) {
                    return const Center(child: Text('No report data available for this session'));
                  }
                  return _buildReportContent(state.response.data!);
                }
                return const Center(child: Text('Select a POS session to view its Z-Report summary'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<PosOpeningEntriesBloc, PosOpeningEntriesState>(
        builder: (context, state) {
          if (state is PosOpeningEntriesLoading) {
            return const LinearProgressIndicator();
          } else if (state is PosOpeningEntriesLoaded) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Select POS Session (Opening Entry)"),
                  value: _selectedEntryId,
                  items: state.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.name,
                      child: Text("${e.name} (${e.posProfile}) - ${e.status}"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _fetchZReport(val);
                  },
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildReportContent(ZReportData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderInfo(data),
          const SizedBox(height: 16),
          _buildMetricRow(data),
          const SizedBox(height: 24),
          _buildSectionTitle("Payment Reconciliation"),
          const SizedBox(height: 8),
          _buildReconciliationTable(data.paymentReconciliation),
          const SizedBox(height: 24),
          _buildSectionTitle("Transactions"),
          const SizedBox(height: 8),
          _buildTransactionsTable(data.posTransactions),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(ZReportData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.posOpeningEntry, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: data.status == 'Closed' ? Colors.green.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.status,
                  style: TextStyle(
                    color: data.status == 'Closed' ? Colors.green : Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow("POS Profile:", data.posProfile),
          _buildInfoRow("Cashier:", data.user),
          _buildInfoRow("Period:", "${data.periodStartDate} to ${data.periodEndDate}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildMetricRow(ZReportData data) {
    return Row(
      children: [
        _buildMetricCard("Grand Total", "KSh ${_currencyFormat.format(data.grandTotal)}", Colors.indigo),
        const SizedBox(width: 12),
        _buildMetricCard("Taxes", "KSh ${_currencyFormat.format(data.totalTaxesAndCharges)}", Colors.purple),
        const SizedBox(width: 12),
        _buildMetricCard("Invoices", data.invoicesCount.toString(), Colors.teal),
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
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
    );
  }

  Widget _buildReconciliationTable(List reconciliations) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DataTable(
        headingRowHeight: 40,
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Mode', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Opening', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Expected', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: reconciliations.map((item) {
          return DataRow(cells: [
            DataCell(Text(item.modeOfPayment)),
            DataCell(Text(_currencyFormat.format(item.openingAmount))),
            DataCell(Text(_currencyFormat.format(item.expectedAmount))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionsTable(List transactions) {
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
          headingRowHeight: 40,
          columns: const [
            DataColumn(label: Text('Invoice', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: transactions.map((item) {
            return DataRow(cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.posInvoice, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(item.postingDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              DataCell(Text(item.customer, overflow: TextOverflow.ellipsis)),
              DataCell(Text(_currencyFormat.format(item.grandTotal))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
