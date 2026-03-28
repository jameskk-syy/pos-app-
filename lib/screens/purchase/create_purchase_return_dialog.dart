import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/purchase/create_purchase_return_request.dart';
import 'package:pos/domain/responses/purchase/purchase_order_detail_response.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';

class CreatePurchaseReturnDialog extends StatefulWidget {
  final PurchaseOrderDetail purchaseOrder;

  const CreatePurchaseReturnDialog({super.key, required this.purchaseOrder});

  static Future<void> show(BuildContext context, PurchaseOrderDetail po) async {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    if (isTablet) {
      return showDialog(
        context: context,
        builder: (context) => CreatePurchaseReturnDialog(purchaseOrder: po),
      );
    } else {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        builder: (context) => CreatePurchaseReturnDialog(purchaseOrder: po),
      );
    }
  }

  @override
  State<CreatePurchaseReturnDialog> createState() => _CreatePurchaseReturnDialogState();
}

class _CreatePurchaseReturnDialogState extends State<CreatePurchaseReturnDialog> {
  DateTime _postingDate = DateTime.now();
  final Map<String, double> _returnQtys = {};
  final DateFormat _displayDateFormat = DateFormat('dd MMM, yyyy');

  @override
  void initState() {
    super.initState();
    for (var item in widget.purchaseOrder.items) {
      _returnQtys[item.itemCode] = 0.0;
    }
  }

  double get _totalReturnAmount {
    double total = 0;
    for (var item in widget.purchaseOrder.items) {
      total += (_returnQtys[item.itemCode] ?? 0) * item.rate;
    }
    return total;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _postingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF01579B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _postingDate) {
      setState(() {
        _postingDate = picked;
      });
    }
  }

  void _submitReturn() {
    final items = widget.purchaseOrder.items
        .where((item) => (_returnQtys[item.itemCode] ?? 0) > 0)
        .map((item) => PurchaseReturnItemRequest(
              itemCode: item.itemCode,
              qty: _returnQtys[item.itemCode]!,
              rate: item.rate,
              warehouse: item.warehouse,
            ))
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter return quantity for at least one item')),
      );
      return;
    }

    final request = CreatePurchaseReturnRequest(
      returnAgainst: widget.purchaseOrder.name,
      postingDate: DateFormat('yyyy-MM-dd').format(_postingDate),
      company: widget.purchaseOrder.company,
      supplier: widget.purchaseOrder.supplier,
      items: items,
    );

    context.read<PurchaseBloc>().add(CreatePurchaseReturnEvent(request: request));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        width: isTablet ? screenWidth * 0.7 : screenWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(isTablet),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopFields(isTablet),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Items to Return'),
                    const SizedBox(height: 16),
                    _buildItemsTable(isTablet),
                    const SizedBox(height: 24),
                    _buildTotalSummary(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Create Purchase Return - ${widget.purchaseOrder.name}',
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF263238),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF546E7A)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopFields(bool isTablet) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: isTablet ? 280 : double.infinity,
          child: _buildInputWrapper(
            label: 'Return Against',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.purchaseOrder.name,
                style: const TextStyle(fontSize: 14, color: Color(0xFF455A64), fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        SizedBox(
          width: isTablet ? 280 : double.infinity,
          child: _buildInputWrapper(
            label: 'Posting Date *',
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF01579B).withAlpha(100)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF01579B)),
                    const SizedBox(width: 10),
                    Text(
                      _displayDateFormat.format(_postingDate),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF01579B)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF78909C)),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF546E7A),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildItemsTable(bool isTablet) {
    if (!isTablet) {
      return Column(
        children: widget.purchaseOrder.items.map((item) => _buildMobileItemCard(item)).toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCFD8DC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('ITEM', style: _headerStyle)),
                Expanded(flex: 2, child: Text('ORIGINAL QTY', style: _headerStyle)),
                Expanded(flex: 2, child: Text('RATE', style: _headerStyle)),
                Expanded(flex: 2, child: Text('RETURN QTY', style: _headerStyle)),
                Expanded(flex: 2, child: Text('AMOUNT', style: _headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFCFD8DC)),
          ...widget.purchaseOrder.items.map((item) => _buildTabletRow(item)),
        ],
      ),
    );
  }

  Widget _buildMobileItemCard(PurchaseOrderItem item) {
    final returnQty = _returnQtys[item.itemCode] ?? 0.0;
    final amount = returnQty * item.rate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.itemCode,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Text(
                'Orig: ${item.qty.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RETURN QTY', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildReturnQtyInput(item),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('AMOUNT', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.purchaseOrder.currency} ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF263238)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabletRow(PurchaseOrderItem item) {
    final returnQty = _returnQtys[item.itemCode] ?? 0.0;
    final amount = returnQty * item.rate;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFECEFF1))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemCode, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(item.description, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(item.qty.toStringAsFixed(0))),
          Expanded(flex: 2, child: Text('${widget.purchaseOrder.currency} ${item.rate.toStringAsFixed(2)}')),
          Expanded(
            flex: 2,
            child: _buildReturnQtyInput(item),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${widget.purchaseOrder.currency} ${amount.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF263238)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnQtyInput(PurchaseOrderItem item) {
    return SizedBox(
      height: 54,
      width: 140,
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          filled: true,
          fillColor: Colors.blue[50]?.withAlpha(30),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.blue[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF01579B), width: 2),
          ),
        ),
        onChanged: (val) {
          setState(() {
            _returnQtys[item.itemCode] = double.tryParse(val) ?? 0.0;
          });
        },
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF01579B).withAlpha(10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF01579B).withAlpha(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Return Amount',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF455A64)),
          ),
          Text(
            '${widget.purchaseOrder.currency} ${_totalReturnAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF01579B)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF546E7A), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submitReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01579B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('CREATE RETURN', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.1)),
            ),
          ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: Color(0xFF90A4AE),
    letterSpacing: 0.5,
  );
}
