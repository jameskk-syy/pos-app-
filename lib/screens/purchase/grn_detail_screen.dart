import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/purchase/grn_detail_response.dart';
import 'package:pos/presentation/grn/bloc/grn_bloc.dart';
import 'package:pos/presentation/purchase_invoice/bloc/purchase_invoice_bloc.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:pos/widgets/common/app_button.dart';

class GrnDetailScreen extends StatefulWidget {
  final String grnNo;

  const GrnDetailScreen({super.key, required this.grnNo});

  @override
  State<GrnDetailScreen> createState() => _GrnDetailScreenState();
}

class _GrnDetailScreenState extends State<GrnDetailScreen> {
  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() {
    context.read<GrnBloc>().add(FetchGrnDetailEvent(grnNo: widget.grnNo));
  }

  void _printGrn(GrnDetailData data) {
    ReportPdfGenerator().generateGrnDetailPdf(data);
  }

  void _createPurchaseInvoice() {
    context.read<PurchaseInvoiceBloc>().add(
      CreatePurchaseInvoiceFromGrnEvent(
        grnNo: widget.grnNo,
        doNotSubmit: false,
        billDate: DateTime.now().toString().split(' ')[0],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      listener: (context, state) {
        if (state is PurchaseInvoiceCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase Invoice created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchDetails(); // Refresh to update billed status
        } else if (state is PurchaseInvoiceCreateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('GRN Detail: ${widget.grnNo}'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          elevation: 0.5,
          actions: [
            BlocBuilder<GrnBloc, GrnState>(
              builder: (context, state) {
                if (state is GrnDetailLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: () => _printGrn(state.response.data),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchDetails,
            ),
          ],
        ),
        body: BlocBuilder<GrnBloc, GrnState>(
          builder: (context, state) {
            if (state is GrnDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GrnDetailError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is GrnDetailLoaded) {
              return _buildGrnDetails(state.response.data);
            }
            return const Center(child: Text('Loading GRN details...'));
          },
        ),
      ),
    );
  }

  Widget _buildGrnDetails(GrnDetailData data) {
    final canCreateInvoice = data.perBilled < 100 && data.docstatus == 1;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(data),
                const SizedBox(height: 16),
                _buildItemsSection(data.items),
              ],
            ),
          ),
        ),
        if (canCreateInvoice)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
              builder: (context, state) {
                final isLoading = state is PurchaseInvoiceCreating;
                return AppButton(
                  text: isLoading
                      ? 'Creating Invoice...'
                      : 'Create Purchase Invoice',
                  onTap: isLoading ? null : _createPurchaseInvoice,
                  buttonColor: Colors.blue,
                  width: double.infinity,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(GrnDetailData data) {
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
            _buildInfoRow('Supplier', data.supplierName),
            _buildInfoRow('Posting Date', data.postingDate),
            _buildInfoRow('Warehouse', data.setWarehouse),
            _buildInfoRow('Purchase Order', data.purchaseOrder),
            _buildInfoRow('Status', data.status, isStatus: true),
            const Divider(),
            _buildInfoRow(
              'Grand Total',
              data.grandTotal.toStringAsFixed(2),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isStatus ? _getStatusColor(value) : Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(List<GrnItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Card(
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.itemCode,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Qty: ${item.qty} ${item.uom}'),
                      Text(
                        'Amount: ${item.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
