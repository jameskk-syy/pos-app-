import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/widgets/sales/create_credit_payment_dialog.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'dart:convert';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String companyName = '';

  @override
  void initState() {
    super.initState();
    _loadCompanyAndFetch();
  }

  Future<void> _loadCompanyAndFetch() async {
    final storage = getIt<StorageService>();
    final userString =
        (await storage.getString('current_user')) ??
        (await storage.getString('userData'));
    if (userString != null) {
      final user = jsonDecode(userString);
      if (user['message'] != null && user['message']['company'] != null) {
        companyName = user['message']['company']['name'] ?? '';
      } else if (user['company'] != null) {
        companyName = user['company'] ?? '';
      } else {
        companyName = 'Maina CVG'; // Fallback logic usually from global state
      }

      if (mounted) {
        context.read<SalesBloc>().add(
          GetPaymentMethod(company: companyName, onlyEnabled: false),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Payment Methods'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCompanyAndFetch,
          ),
        ],
      ),
      body: BlocConsumer<SalesBloc, SalesState>(
        listener: (context, state) {
          if (state is CreateCreditPaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CreditPaymentCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadCompanyAndFetch();
          }
        },
        builder: (context, state) {
          if (state is PaymentMethodsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentMethodsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCompanyAndFetch,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is PaymentMethodsLoaded) {
            return _buildContent(state.paymentMethods);
          }

          return const Center(child: Text('Initialize payment methods...'));
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () => _showCreateCreditDialog(context),
          icon: const Icon(Icons.add_card),
          label: const Text('Configure Credit Payment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<PaymentMethod> methods) {
    if (methods.isEmpty) {
      return const Center(child: Text('No payment methods found'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResponsiveTable(methods, isMobile),
              const SizedBox(height: 80), // Space for FAB-like bottom nav
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveTable(List<PaymentMethod> methods, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          columnSpacing: isMobile ? 12 : 24,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          columns: const [
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: methods.map((m) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    m.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(m.type)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: m.enabled
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      m.enabled ? 'Enabled' : 'Disabled',
                      style: TextStyle(
                        fontSize: 12,
                        color: m.enabled ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCreateCreditDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateCreditPaymentDialog(companyName: companyName),
    );
  }
}
