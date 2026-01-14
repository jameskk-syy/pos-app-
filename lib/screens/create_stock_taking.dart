import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/add_stock_take_request.dart';
import 'package:pos/domain/requests/get_stock_reconciliation_request.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';

class StockTakePage extends StatefulWidget {
  final String reconciliationName;
  final StockTakeRole role;

  const StockTakePage({
    super.key,
    required this.reconciliationName,
    required this.role,
  });

  @override
  State<StockTakePage> createState() => _StockTakePageState();
}

class _StockTakePageState extends State<StockTakePage> {
  final TextEditingController generalCommentController =
      TextEditingController();
  List<TextEditingController> countedQtyControllers = [];
  List<TextEditingController> itemCommentControllers = [];
  List<Map<String, dynamic>> stockItems = [];
  String? workflowStatus;
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReconciliationData();
  }

  void _loadReconciliationData() async {
    final request = GetStockReconciliationRequest(
      reconciliationName: widget.reconciliationName,
    );

    context.read<InventoryBloc>().add(GetStockReconciliation(request: request));
  }

  void _submitStockTake() {
    final List<StockTakeItem> items = [];

    for (int i = 0; i < stockItems.length; i++) {
      final item = stockItems[i];
      final qty = double.tryParse(countedQtyControllers[i].text) ?? 0.0;
      final comment = itemCommentControllers[i].text.trim();

      items.add(
        StockTakeItem(
          itemCode: item['item_code'],
          qty: qty,
          comment: comment.isNotEmpty ? comment : null,
        ),
      );
    }

    final request = AddStockTakeRequest(
      reconciliationName: widget.reconciliationName,
      items: items,
      comment: generalCommentController.text.trim().isNotEmpty
          ? generalCommentController.text.trim()
          : null,
    );

    context.read<InventoryBloc>().add(
      AddStockTake(request: request, role: widget.role),
    );
  }

  String _getRoleTitle() {
    switch (widget.role) {
      case StockTakeRole.salesPerson:
        return 'Sales Person';
      case StockTakeRole.stockController:
        return 'Quality Manager';
      case StockTakeRole.stockManager:
        return 'Stock Manager';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '${_getRoleTitle()} Stock Take',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is GetStockReconciliationLoaded) {
            final data = state.response.message.data;
            setState(() {
              workflowStatus = data.workflowStatus;
              stockItems = data.stockTakingRecords.map((record) {
                return {
                  'item_code': record.itemCode,
                  'current_qty': record.currentQty,
                };
              }).toList();

              countedQtyControllers = stockItems.map((item) {
                final controller = TextEditingController();
                controller.text = '0';
                return controller;
              }).toList();

              itemCommentControllers = stockItems.map((_) {
                return TextEditingController();
              }).toList();

              isLoading = false;
            });
          }
          if (state is GetStockReconciliationError) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is AddStockTakeLoading) {
            setState(() {
              isSubmitting = true;
            });
          }
          if (state is AddStockTakeSuccess) {
            setState(() {
              isSubmitting = false;
            });

            final response = state.response;
            final data = response.message.data;

            if (data.submission?.submitted == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ' ${response.message.message}. Status: ${data.workflowStatus}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ' ${data.submission?.error ?? 'Submission success'}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          }
          if (state is AddStockTakeError) {
            setState(() {
              isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (isLoading || state is GetStockReconciliationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Reconciliation:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.reconciliationName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Status:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                workflowStatus ?? 'Loading...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: generalCommentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'General Comment',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Item Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Current Qty',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Counted Qty',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Comment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...stockItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;

                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      item['item_code'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      item['current_qty'].toString(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: countedQtyControllers[index],
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: itemCommentControllers[index],
                                    decoration: InputDecoration(
                                      hintText: 'Item comment',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting ? null : _submitStockTake,
                      icon: isSubmitting
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
                          : const Icon(Icons.save, color: Colors.white),
                      label: isSubmitting
                          ? const Text(
                              'Submitting...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.role == StockTakeRole.stockManager
                                  ? 'Submit Reconciliation'
                                  : 'Add Stock Take',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubmitting
                            ? Colors.grey[400]
                            : Colors.blue[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
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
}
