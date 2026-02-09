import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class RiskAnalysisPage extends StatefulWidget {
  const RiskAnalysisPage({super.key});

  @override
  State<RiskAnalysisPage> createState() => _RiskAnalysisPageState();
}

class _RiskAnalysisPageState extends State<RiskAnalysisPage> {
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
        title: const Text('Obsolescence Risk Analysis'),
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is AgingStockLoaded) {
            final riskData = state.riskResponse.data;
            if (riskData.isEmpty) {
              return const Center(child: Text('No risk data available'));
            }
            return _buildRiskList(riskData);
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildRiskList(List<ObsolescenceRiskData> data) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          child: ListTile(
            title: Text(item.itemName),
            subtitle: Text('Last Sold: ${item.lastMovementDate}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Risk: ${item.riskLevel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Text('Val: ${item.stockValue.toStringAsFixed(2)}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
