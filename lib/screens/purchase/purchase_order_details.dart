import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/purchase/create_grn_request.dart';
import 'package:pos/domain/responses/purchase/purchase_order_detail_response.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';

import 'package:pos/utils/report_pdf_generator.dart';

class PurchaseOrderDetailScreen extends StatefulWidget {
  final String poName;

  const PurchaseOrderDetailScreen({super.key, required this.poName});

  @override
  State<PurchaseOrderDetailScreen> createState() =>
      _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  // Track selected items for GRN
  Map<String, int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchPurchaseOrderDetail();
  }

  void _fetchPurchaseOrderDetail() {
    context.read<PurchaseBloc>().add(
      FetchPurchaseOrderDetailEvent(poName: widget.poName),
    );
  }

  void _showCreateGrnDialog(BuildContext context, PurchaseOrderDetail po) {
    selectedItems = {
      for (var item in po.items) item.itemCode: item.qty.toInt(),
    };

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.inventory_2, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Create Goods Receipt Note',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select items to receive:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...po.items.map((item) {
                            final isSelected = selectedItems.containsKey(
                              item.itemCode,
                            );
                            final currentQty =
                                selectedItems[item.itemCode] ??
                                item.qty.toInt();

                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                                side: BorderSide(color: Colors.grey, width: 1),
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedItems[item.itemCode] =
                                                    item.qty.toInt();
                                              } else {
                                                selectedItems.remove(
                                                  item.itemCode,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.itemCode,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                item.description,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const SizedBox(width: 48),
                                          const Text('Qty: '),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed: currentQty > 1
                                                ? () {
                                                    setState(() {
                                                      selectedItems[item
                                                              .itemCode] =
                                                          currentQty - 1;
                                                    });
                                                  }
                                                : null,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              '$currentQty',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            onPressed:
                                                currentQty < item.qty.toInt()
                                                ? () {
                                                    setState(() {
                                                      selectedItems[item
                                                              .itemCode] =
                                                          currentQty + 1;
                                                    });
                                                  }
                                                : null,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warehouse,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Warehouse: ${po.items.first.warehouse}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Actions Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: selectedItems.isEmpty
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _createGrn(po);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text('Create GRN'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _createGrn(PurchaseOrderDetail po) {
    final grnItems = selectedItems.entries.map((entry) {
      return GrnItem(itemCode: entry.key, qty: entry.value.toDouble());
    }).toList();

    final request = CreateGrnRequest(
      lpoNo: po.name,
      warehouse: po.items.first.warehouse,
      items: grnItems,
    );

    context.read<PurchaseBloc>().add(CreateGrnEvent(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Order: ${widget.poName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPurchaseOrderDetail,
          ),
        ],
      ),
      body: BlocConsumer<PurchaseBloc, PurchaseState>(
        listener: (context, state) {
          if (state is GrnCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () {
                    debugPrint('GRN Number: ${state.response.grnNo}');
                  },
                ),
              ),
            );
            _fetchPurchaseOrderDetail();
          } else if (state is GrnCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PurchaseOrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PurchaseOrderDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchPurchaseOrderDetail,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PurchaseOrderDetailLoaded) {
            final po = state.response.purchaseOrder;
            final isCreatingGrn = state is GrnCreating;

            final canReceiveGoods =
                po.status == 'To Receive and Bill' || po.status == 'To Receive';

            return RefreshIndicator(
              onRefresh: () async {
                _fetchPurchaseOrderDetail();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('PO Number:', po.name),
                            const Divider(),
                            _buildInfoRow('Supplier:', po.supplier),
                            _buildInfoRow('Company:', po.company),
                            _buildInfoRow('Date:', po.transactionDate),
                            _buildInfoRow('Status:', po.status),
                            _buildInfoRow('Currency:', po.currency),
                            const Divider(),
                            _buildInfoRow(
                              'Grand Total:',
                              '${po.currency} ${po.grandTotal.toStringAsFixed(2)}',
                              isHighlighted: true,
                            ),
                            _buildInfoRow(
                              'Total Qty:',
                              po.totalQty.toStringAsFixed(2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (canReceiveGoods)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isCreatingGrn
                              ? null
                              : () => _showCreateGrnDialog(context, po),
                          icon: isCreatingGrn
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.inventory_2),
                          label: Text(
                            isCreatingGrn
                                ? 'Creating GRN...'
                                : 'Create Goods Receipt Note',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...po.items.map(
                      (item) => Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Qty: ${item.qty} ${item.uom}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Rate: ${po.currency} ${item.rate}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Warehouse: ${item.warehouse}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Amount: ${po.currency} ${item.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (po.purchaseReceipts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Purchase Receipts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...po.purchaseReceipts.map(
                        (receipt) => Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(receipt.name ?? 'N/A'),
                            subtitle: Text(receipt.status ?? 'N/A'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (receipt.receivedQty != null)
                                  Text('Qty: ${receipt.receivedQty}'),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.print,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    final pdfGenerator = ReportPdfGenerator();
                                    pdfGenerator.generateGrnPdf(
                                      po,
                                      receipt.name ?? 'N/A',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          if (state is GrnCreating || state is GrnCreated) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                fontSize: isHighlighted ? 16 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
