import 'package:flutter/material.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/widgets/common/barcode_scanner_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/presentation/barcode/bloc/barcode_bloc.dart';
import 'package:pos/core/dependency.dart';

class ManageBarcodeSheet extends StatefulWidget {
  final ProductItem product;

  const ManageBarcodeSheet({super.key, required this.product});

  @override
  State<ManageBarcodeSheet> createState() => _ManageBarcodeSheetState();
}

class _ManageBarcodeSheetState extends State<ManageBarcodeSheet> {
  final TextEditingController _barcodeController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<String> barcodes = [];

  @override
  void initState() {
    super.initState();
    if (widget.product.itemCode.isNotEmpty) {}
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result != null && mounted) {
      _barcodeController.text = result;
      _addBarcode();
    }
  }

  void _addBarcode() {
    final code = _barcodeController.text.trim();
    if (code.isEmpty) return;

    if (barcodes.contains(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barcode "$code" already exists'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      barcodes.insert(0, code);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 300),
      );
      _barcodeController.clear();
    });
  }

  void _removeBarcode(int index) {
    final removedItem = barcodes[index];
    final isTablet = MediaQuery.of(context).size.width >= 768;
    setState(() {
      barcodes.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildBarcodeTile(
          removedItem,
          animation,
          index,
          isRemoving: true,
          isTablet: isTablet,
        ),
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(isTablet),
                Expanded(
                  child: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
                ),
                _buildFooter(isTablet),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductInfoCard(false),
          const SizedBox(height: 20),
          _buildActionSection(false),
          const SizedBox(height: 28),
          _buildSectionHeader('Active Barcodes', false),
          const SizedBox(height: 10),
          _buildAnimatedList(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            isTablet: false,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Product Info & Actions
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfoCard(true),
                  const SizedBox(height: 24),
                  _buildActionSection(true),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Active Barcodes', true),
                const SizedBox(height: 16),
                Expanded(child: _buildAnimatedList(isTablet: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 28 : 24,
        isTablet ? 24 : 16,
        isTablet ? 20 : 16,
        isTablet ? 16 : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Barcodes',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Update product identification',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: Colors.blueGrey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.all(isTablet ? 8 : 6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10),
                ],
              ),
              child: Icon(
                Icons.close,
                size: isTablet ? 20 : 18,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isTablet) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey[200]!, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfoCard(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(10),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: const Color(0xFF2563EB),
              size: isTablet ? 28 : 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.itemName,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey[100]!),
                  ),
                  child: Text(
                    'SKU: ${widget.product.itemCode}',
                    style: TextStyle(
                      fontSize: isTablet ? 12 : 11,
                      color: Colors.blueGrey[600],
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
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

  Widget _buildActionSection(bool isTablet) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _barcodeController,
            onSubmitted: (_) => _addBarcode(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              fontSize: isTablet ? 16 : 14,
            ),
            keyboardType: TextInputType.text,
            // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Manual entry...',
              hintStyle: TextStyle(
                color: Colors.blueGrey[300],
                fontSize: isTablet ? 15 : 13,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 20 : 14,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: IconButton(
                  onPressed: _addBarcode,
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: const Color(0xFF2563EB),
                    size: isTablet ? 28 : 24,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isTablet ? 20 : 14),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _scanBarcode,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withAlpha(60),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: isTablet ? 24 : 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scan New Barcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: isTablet ? 16 : 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedList({
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    required bool isTablet,
  }) {
    if (barcodes.isEmpty) {
      return _buildEmptyState(isTablet);
    }
    return AnimatedList(
      key: _listKey,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: EdgeInsets.zero,
      initialItemCount: barcodes.length,
      itemBuilder: (context, index, animation) {
        return _buildBarcodeTile(
          barcodes[index],
          animation,
          index,
          isTablet: isTablet,
        );
      },
    );
  }

  Widget _buildBarcodeTile(
    String code,
    Animation<double> animation,
    int index, {
    bool isRemoving = false,
    required bool isTablet,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Container(
          margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.blueGrey[50]!),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(
              isTablet ? 20 : 16,
              isTablet ? 8 : 4,
              isTablet ? 12 : 8,
              isTablet ? 8 : 4,
            ),
            leading: Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              ),
              child: Icon(
                Icons.qr_code_rounded,
                color: const Color(0xFF64748B),
                size: isTablet ? 22 : 20,
              ),
            ),
            title: Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
                fontSize: isTablet ? 16 : 14,
                letterSpacing: 0.5,
              ),
            ),
            subtitle: Text(
              'Added recently',
              style: TextStyle(
                color: Colors.blueGrey[400],
                fontSize: isTablet ? 12 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: IconButton(
              onPressed: isRemoving ? null : () => _removeBarcode(index),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[400],
                padding: isTablet ? null : const EdgeInsets.all(8),
              ),
              icon: Icon(Icons.delete_sweep_rounded, size: isTablet ? 22 : 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isTablet ? 60 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: Colors.blue[50]?.withAlpha(150),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.barcode_reader,
              size: isTablet ? 56 : 40,
              color: Colors.blue[200],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to Scan',
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add barcodes to this product for faster \ncheckout and inventory tracking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey[400],
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isTablet) {
    return BlocProvider(
      create: (context) => getIt<BarcodeBloc>(),
      child: BlocConsumer<BarcodeBloc, BarcodeState>(
        listener: (context, state) {
          if (state is BarcodeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is BarcodeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: state is BarcodeLoading
                          ? null
                          : () {
                              if (barcodes.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Add at least one barcode'),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              // The API seems to take one barcode at a time.
                              // We'll save the first one or we should iterate?
                              // User request says: {"item_code": "TMI-REST-002", "barcode": "tttt"}
                              // I will save the first one in the list for now, or just the one scanned.
                              // If they added multiple, maybe we should loop?
                              // But the prompt says "add way to save the barcodes"
                              // I'll loop through them.
                              for (var barcode in barcodes) {
                                context.read<BarcodeBloc>().add(
                                  AddBarcodeEvent(
                                    itemCode: widget.product.itemCode,
                                    barcode: barcode,
                                  ),
                                );
                              }
                            },
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 20 : 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: state is BarcodeLoading
                                ? [Colors.grey, Colors.grey]
                                : [
                                    const Color(0xFF2563EB),
                                    const Color(0xFF1D4ED8),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 20 : 16,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withAlpha(40),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: state is BarcodeLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Save & Update Product',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }
}
