import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/inventory/create_stock_reconciliation_request.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/widgets/common/barcode_scanner_screen.dart';

class ReconciliationFormSection extends StatelessWidget {
  final String? selectedWarehouse;
  final List<Warehouse> warehouses;
  final Function(String?) onWarehouseChanged;
  final DateTime postingDate;
  final Function(DateTime) onDateChanged;
  final TimeOfDay postingTime;
  final Function(TimeOfDay) onTimeChanged;
  final String selectedPurpose;
  final Function(String) onPurposeChanged;
  final TextEditingController expenseAccountController;
  final TextEditingController costCenterController;
  final bool doNotSubmit;
  final Function(bool) onDoNotSubmitChanged;
  final bool isStoreLoading;

  const ReconciliationFormSection({
    super.key,
    required this.selectedWarehouse,
    required this.warehouses,
    required this.onWarehouseChanged,
    required this.postingDate,
    required this.onDateChanged,
    required this.postingTime,
    required this.onTimeChanged,
    required this.selectedPurpose,
    required this.onPurposeChanged,
    required this.expenseAccountController,
    required this.costCenterController,
    required this.doNotSubmit,
    required this.onDoNotSubmitChanged,
    this.isStoreLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
            'Create a new stock reconciliation that will go through a multi-level approval process',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildDropdownField(
                label: 'Warehouse',
                value: selectedWarehouse,
                required: true,
                onChanged: onWarehouseChanged,
                items: warehouses
                    .map((w) => DropdownMenuItem<String>(
                          value: w.name,
                          child: Text('${w.name} - ${w.warehouseName}${w.isDefault ? ' (Default)' : ''}'),
                        ))
                    .toList(),
                isLoading: isStoreLoading,
              ),
              _buildDateField(
                context,
                label: 'Posting Date',
                date: postingDate,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: postingDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) onDateChanged(date);
                },
              ),
              _buildTimeField(
                context,
                label: 'Posting Time',
                time: postingTime,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: postingTime,
                  );
                  if (time != null) onTimeChanged(time);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildDropdownField(
                label: 'Purpose',
                value: selectedPurpose,
                onChanged: (value) => onPurposeChanged(value!),
                items: ['Stock Reconciliation', 'Opening Stock']
                    .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                    .toList(),
              ),
              _buildTextField(label: 'Expense Account', controller: expenseAccountController),
              _buildTextField(label: 'Cost Center', controller: costCenterController),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: doNotSubmit,
                onChanged: (val) => onDoNotSubmitChanged(val ?? false),
              ),
              const Text('Do Not Submit (Save as Draft)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required Function(String?) onChanged,
    required List<DropdownMenuItem<String>> items,
    bool required = false,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
              if (required) const Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text('Loading...', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      onChanged: onChanged,
                      items: items,
                      hint: const Text('Select...', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, {required String label, required DateTime date, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Text(DateFormat('MM/dd/yyyy').format(date), style: const TextStyle(fontSize: 14)),
                  const Spacer(),
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, {required String label, required TimeOfDay time, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Text(time.format(context), style: const TextStyle(fontSize: 14)),
                  const Spacer(),
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class ReconciliationItemsList extends StatelessWidget {
  final List<StockReconciliationItem> selectedItems;
  final VoidCallback onAddItem;
  final Function(int) onDeleteItem;

  const ReconciliationItemsList({
    super.key,
    required this.selectedItems,
    required this.onAddItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Text('Reconciliation Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Item'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (selectedItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('No items selected', style: TextStyle(color: Colors.grey[600], fontSize: 14))),
            )
          else
            ...selectedItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.itemCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 16,
                              children: [
                                Text('Physical Qty: ${item.qty}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                if (item.batchNo != null) Text('Batch: ${item.batchNo}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                Text('Valuation: ${item.valuationRate?.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => onDeleteItem(idx),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class ReconciliationSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const ReconciliationSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLoading ? Colors.grey : Colors.blue[600],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            shadowColor: Colors.black.withAlpha(20),
          ),
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : const Text('Create Reconciliation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }
}

class StockReconciliationItemSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(StockReconciliationItem) onItemAdded;
  final CurrentUserResponse? currentUserResponse;

  const StockReconciliationItemSheet({
    super.key,
    this.scrollController,
    required this.onItemAdded,
    this.currentUserResponse,
  });

  @override
  State<StockReconciliationItemSheet> createState() => _StockReconciliationItemSheetState();
}

class _StockReconciliationItemSheetState extends State<StockReconciliationItemSheet> {
  ProductItem? selectedProduct;
  final TextEditingController physicalQtyController = TextEditingController();
  final TextEditingController valuationRateController = TextEditingController();
  final TextEditingController buyingPriceController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController batchNoController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final List<ProductItem> scannedProducts = [];
  List<ProductItem> baseProducts = [];
  Timer? _searchTimer;

  double systemQty = 0;
  String uom = '';
  double difference = 0;

  @override
  void initState() {
    super.initState();
    physicalQtyController.addListener(_calculateDifference);
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    physicalQtyController.removeListener(_calculateDifference);
    searchController.removeListener(_onSearchChanged);
    physicalQtyController.dispose();
    valuationRateController.dispose();
    buyingPriceController.dispose();
    sellingPriceController.dispose();
    skuController.dispose();
    batchNoController.dispose();
    expiryDateController.dispose();
    searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text.isNotEmpty) {
        context.read<ProductsBloc>().add(
              GetAllProducts(
                company: widget.currentUserResponse?.message.company.name ?? '',
                searchTerm: searchController.text,
                pageSize: 50,
              ),
            );
      }
    });
  }

  Future<void> _openBarcodeScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (result != null && result.isNotEmpty) {
      if (mounted) {
        final state = context.read<ProductsBloc>().state;
        if (state is ProductsStateSuccess) {
          final product = state.productResponse.getProductByCode(result);
          if (product != null) {
            _onProductSelected(product);
          } else {
            final posProfile = widget.currentUserResponse?.message.posProfile.name ?? '';
            context.read<ProductsBloc>().add(
                  SearchProductByBarcode(barcode: result, posProfile: posProfile),
                );
          }
        }
      }
    }
  }

  void _onProductSelected(ProductItem? product) {
    if (product == null) return;
    setState(() {
      selectedProduct = product;
      systemQty = product.stockQty;
      uom = product.stockUom;
      valuationRateController.text = product.standardRate.toString();
      sellingPriceController.text = product.price.toString();
      buyingPriceController.text = product.standardRate.toString();
      if (!scannedProducts.contains(product)) {
        scannedProducts.add(product);
      }
    });
    _calculateDifference();
  }

  void _calculateDifference() {
    final physical = double.tryParse(physicalQtyController.text) ?? 0;
    setState(() {
      difference = physical - systemQty;
    });
  }

  void _submit() {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }
    if (physicalQtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter physical quantity')));
      return;
    }

    final item = StockReconciliationItem(
      itemCode: selectedProduct!.itemCode,
      qty: double.tryParse(physicalQtyController.text),
      valuationRate: double.tryParse(valuationRateController.text),
      buyingPrice: double.tryParse(buyingPriceController.text),
      sellingPrice: double.tryParse(sellingPriceController.text),
      unitOfMeasure: uom,
      sku: skuController.text.isEmpty ? null : skuController.text,
      expiryDate: expiryDateController.text.isEmpty ? null : expiryDateController.text,
      batchNo: batchNoController.text.isEmpty ? null : batchNoController.text,
    );
    widget.onItemAdded(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsState>(
      listener: (context, state) {
        if (state is BarcodeSearchSuccess) {
          _onProductSelected(state.product);
          context.read<ProductsBloc>().add(
                GetAllProducts(
                  company: widget.currentUserResponse?.message.company.name ?? '',
                  searchTerm: state.product.itemName,
                  pageSize: 50,
                ),
              );
        } else if (state is ProductsStateSuccess) {
          setState(() {
            baseProducts = state.productResponse.products;
          });
        } else if (state is ProductsStateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        final allProducts = <ProductItem>{...baseProducts, ...scannedProducts}.toList();
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: widget.scrollController == null,
            controller: widget.scrollController,
            children: [
              Row(
                children: [
                  const Text('Add Item Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildTextField('Search Products', searchController, suffixIcon: Icons.search),
              if (searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    baseProducts.isEmpty ? (state is ProductsStateLoading ? 'Searching...' : 'No products found') : '${baseProducts.length} products found. Please select product below.',
                    style: TextStyle(
                      fontSize: 12,
                      color: baseProducts.isEmpty ? (state is ProductsStateLoading ? Colors.blue : Colors.red) : Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildLabel('Item Code *'),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.blue), onPressed: _openBarcodeScanner, tooltip: 'Scan Barcode'),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ProductItem>(
                    value: selectedProduct,
                    hint: const Text('Select Product'),
                    isExpanded: true,
                    items: allProducts.map((p) => DropdownMenuItem(value: p, child: Text('${p.itemCode} - ${p.itemName}'))).toList(),
                    onChanged: _onProductSelected,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedProduct != null) ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final halfWidth = (width - 16) / 2;
                    return Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: halfWidth, child: _buildReadOnlyField('System Qty', systemQty.toString())),
                            const SizedBox(width: 16),
                            SizedBox(width: halfWidth, child: _buildReadOnlyField('UOM', uom)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(width: halfWidth, child: _buildTextField('Physical Qty *', physicalQtyController, isNumber: true)),
                            const SizedBox(width: 16),
                            SizedBox(width: halfWidth, child: _buildReadOnlyField('Difference', difference.toStringAsFixed(2))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(width: halfWidth, child: _buildTextField('Valuation Rate', valuationRateController, isNumber: true)),
                            const SizedBox(width: 16),
                            SizedBox(width: halfWidth, child: _buildTextField('Buying Price', buyingPriceController, isNumber: true)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(width: halfWidth, child: _buildTextField('Selling Price', sellingPriceController, isNumber: true)),
                            const SizedBox(width: 16),
                            SizedBox(width: halfWidth, child: _buildTextField('SKU (Optional)', skuController)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(width: halfWidth, child: _buildTextField('Batch No', batchNoController)),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: halfWidth,
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                                  if (date != null) expiryDateController.text = DateFormat('yyyy-MM-dd').format(date);
                                },
                                child: AbsorbPointer(child: _buildTextField('Expiry Date', expiryDateController, suffixIcon: Icons.calendar_today)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976F3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Add Item', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)));
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
          child: Text(value),
        ),
      ],
    );
  }
}
