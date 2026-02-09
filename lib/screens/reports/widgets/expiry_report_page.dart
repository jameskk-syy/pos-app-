import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

import 'package:pos/domain/models/reports/aging_stock_model.dart';

class ExpiryReportPage extends StatefulWidget {
  const ExpiryReportPage({super.key});

  @override
  State<ExpiryReportPage> createState() => _ExpiryReportPageState();
}

class _ExpiryReportPageState extends State<ExpiryReportPage> {
  String companyName = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
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
      context.read<ReportsBloc>().add(
        FetchAgingStock(ReportRequest(company: companyName)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Expiry Analysis'),
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AgingStockLoaded) {
            final expiryData = state.expiryResponse.data;
            if (expiryData.isEmpty) {
              return const Center(child: Text('No expiry data available'));
            }
            return _buildExpiryList(expiryData);
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildExpiryList(List<ExpiryItemData> data) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          child: ListTile(
            title: Text(item.itemName),
            subtitle: Text(
              'Batch: ${item.batchNo} | Expires: ${item.expiryDate}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.daysToExpiry} days',
                  style: TextStyle(
                    color: item.daysToExpiry < 30 ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Qty: ${item.quantity}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
