import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_detail_response.dart';
import 'package:pos/presentation/purchase_invoice/bloc/purchase_invoice_bloc.dart';
import 'package:pos/screens/finance/pay_invoice_screen.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:pos/widgets/common/app_button.dart';

class PurchaseInvoiceDetailsScreen extends StatefulWidget {
  final String invoiceNo;

  const PurchaseInvoiceDetailsScreen({super.key, required this.invoiceNo});

  @override
  State<PurchaseInvoiceDetailsScreen> createState() =>
      _PurchaseInvoiceDetailsScreenState();
}

class _PurchaseInvoiceDetailsScreenState
    extends State<PurchaseInvoiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() {
    context.read<PurchaseInvoiceBloc>().add(
      FetchPurchaseInvoiceDetailEvent(invoiceNo: widget.invoiceNo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Purchase Invoice Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.5,
        actions: [
          BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
            builder: (context, state) {
              if (state is PurchaseInvoiceDetailLoaded) {
                return IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () => _printInvoice(state.response.data),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchDetails),
        ],
      ),
      body: BlocListener<PurchaseInvoiceBloc, PurchaseInvoiceState>(
        listener: (context, state) {
          if (state is PaidPurchaseInvoice) {
            _fetchDetails(); // Refresh details when payment is successful
          }
        },
        child: BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
          buildWhen: (previous, current) =>
              current is PurchaseInvoiceDetailLoading ||
              current is PurchaseInvoiceDetailLoaded ||
              current is PurchaseInvoiceDetailError,
          builder: (context, state) {
            if (state is PurchaseInvoiceDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PurchaseInvoiceDetailError) {
              return _buildErrorState(state.message);
            }

            if (state is PurchaseInvoiceDetailLoaded) {
              return RefreshIndicator(
                onRefresh: () async => _fetchDetails(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(state.response.data),
                      const SizedBox(height: 16),
                      _buildDetailsCard(state.response.data),
                      const SizedBox(height: 16),
                      _buildItemsTable(
                        state.response.data.items,
                        state.response.data.currency,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(state.response.data),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(PurchaseInvoiceDetailData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.invoiceNo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${data.postingDate}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          _buildStatusBadge(data.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'unpaid':
        color = Colors.orange;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(PurchaseInvoiceDetailData data) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Supplier', data.supplierName),
            const Divider(),
            _buildDetailRow('Supplier ID', data.supplier),
            const Divider(),
            _buildDetailRow('Due Date', data.dueDate),
            const Divider(),
            _buildDetailRow('Company', data.company),
            const Divider(),
            _buildDetailRow('Currency', data.currency),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<PurchaseInvoiceItem> items, String currency) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Item')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Rate')),
                DataColumn(label: Text('Amount')),
              ],
              rows: items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.itemCode,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text('${item.qty} ${item.uom}')),
                    DataCell(Text(NumberFormat('#,##0.00').format(item.rate))),
                    DataCell(
                      Text(NumberFormat('#,##0.00').format(item.amount)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(PurchaseInvoiceDetailData data) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Net Total', data.netTotal, data.currency),
            _buildSummaryRow('Taxes', data.totalTaxesAndCharges, data.currency),
            const Divider(),
            _buildSummaryRow(
              'Grand Total',
              data.grandTotal,
              data.currency,
              isTotal: true,
            ),
            const Divider(),
            _buildSummaryRow(
              'Outstanding',
              data.outstandingAmount,
              data.currency,
              isHighlight: true,
            ),
            if (data.outstandingAmount > 0) ...[
              const SizedBox(height: 16),
              AppButton(
                text: 'Pay Invoice',
                buttonColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PayInvoiceScreen(invoiceData: data),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _fetchDetails();
                    }
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value,
    String currency, {
    bool isTotal = false,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '$currency ${NumberFormat('#,##0.00').format(value)}',
            style: TextStyle(
              fontSize: (isTotal || isHighlight) ? 16 : 14,
              fontWeight: (isTotal || isHighlight)
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isHighlight ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _printInvoice(PurchaseInvoiceDetailData data) {
    ReportPdfGenerator().generatePurchaseInvoicePdf(data);
  }
}
