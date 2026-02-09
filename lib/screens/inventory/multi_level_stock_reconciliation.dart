import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/inventory/create_stock_reconciliation_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/widgets/common/barcode_scanner_screen.dart';
import 'package:pos/widgets/common/delete_confirmation_dialog.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class CreateReconciliationPage extends StatefulWidget {
  const CreateReconciliationPage({super.key});

  @override
  State<CreateReconciliationPage> createState() =>
      _CreateReconciliationPageState();
}

class _CreateReconciliationPageState extends State<CreateReconciliationPage> {
  String? selectedWarehouse;
  DateTime postingDate = DateTime.now();
  TimeOfDay postingTime = TimeOfDay.now();
  String selectedPurpose = 'Stock Reconciliation';
  final TextEditingController expenseAccountController = TextEditingController(
    text: '',
  );
  final TextEditingController costCenterController = TextEditingController(
    text: '',
  );
  CurrentUserResponse? currentUserResponse;
  List<StockReconciliationItem> selectedItems = [];
  List<Warehouse> warehouses = [];
  bool isLoading = false;
  bool doNotSubmit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;

    setState(() {
      currentUserResponse = savedUser;
    });

    context.read<ProductsBloc>().add(
      GetAllProducts(company: savedUser.message.company.name),
    );

    context.read<StoreBloc>().add(
      GetAllStores(company: savedUser.message.company.name),
    );
  }

  void _createReconciliation() {
    if (selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a warehouse'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = CreateStockReconciliationRequest(
      warehouse: selectedWarehouse!,
      postingDate: DateFormat('yyyy-MM-dd').format(postingDate),
      postingTime:
          '${postingTime.hour.toString().padLeft(2, '0')}:${postingTime.minute.toString().padLeft(2, '0')}:00',
      purpose: selectedPurpose,
      expenseAccount: expenseAccountController.text,
      costCenter: costCenterController.text,
      items: selectedItems,
      company: currentUserResponse?.message.company.name ?? '',
      doNotSubmit: doNotSubmit,
    );

    context.read<InventoryBloc>().add(
      CreateStockReconciliation(request: request),
    );
  }

  void _showAddItemSheet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => StockReconciliationItemSheet(
            scrollController: controller,
            onItemAdded: (item) {
              _addItemToSelectedList(item);
            },
            currentUserResponse: currentUserResponse,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 600,
            child: StockReconciliationItemSheet(
              onItemAdded: (item) {
                _addItemToSelectedList(item);
              },
              currentUserResponse: currentUserResponse,
            ),
          ),
        ),
      );
    }
  }

  void _addItemToSelectedList(StockReconciliationItem item) {
    setState(() {
      // Replace if exists, or add new
      final index = selectedItems.indexWhere(
        (element) => element.itemCode == item.itemCode,
      );
      if (index != -1) {
        selectedItems[index] = item;
      } else {
        selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Create Multi-Level Stock Reconciliation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProductsBloc, ProductsState>(
            listener: (context, state) {
              if (state is ProductsStateFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading products: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<StoreBloc, StoreState>(
            listener: (context, state) {
              if (state is StoreStateFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading warehouses: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (state is StoreStateSuccess) {
                setState(() {
                  warehouses = state.storeGetResponse.message.data;
                  if (warehouses.isNotEmpty && selectedWarehouse == null) {
                    final defaultWarehouse = warehouses.firstWhere(
                      (warehouse) => warehouse.isDefault,
                      orElse: () => warehouses.first,
                    );
                    selectedWarehouse = defaultWarehouse.name;
                  }
                });
              }
            },
          ),
          BlocListener<InventoryBloc, InventoryState>(
            listener: (context, state) {
              if (state is CreateStockReconciliationLoading) {
                setState(() {
                  isLoading = true;
                });
              }
              if (state is CreateStockReconciliationSuccess) {
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ' Reconciliation created successfully: ${state.response.message.data.name}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              }
              if (state is CreateStockReconciliationError) {
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<StoreBloc, StoreState>(
          builder: (context, storeState) {
            return BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, productsState) {
                return Stack(
                  children: [
                    SingleChildScrollView(
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
                                  const Text(
                                    'Create a new stock reconciliation that will go through a multi-level approval process',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
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
                                        onChanged: (value) {
                                          setState(() {
                                            selectedWarehouse = value;
                                          });
                                        },
                                        items: warehouses
                                            .map(
                                              (
                                                warehouse,
                                              ) => DropdownMenuItem<String>(
                                                value: warehouse.name,
                                                child: Text(
                                                  '${warehouse.name} - ${warehouse.warehouseName}${warehouse.isDefault ? ' (Default)' : ''}',
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        isLoading:
                                            storeState is StoreStateLoading,
                                      ),
                                      _buildDateField(
                                        label: 'Posting Date',
                                        date: postingDate,
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: postingDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2030),
                                          );
                                          if (date != null) {
                                            setState(() {
                                              postingDate = date;
                                            });
                                          }
                                        },
                                      ),
                                      _buildTimeField(
                                        label: 'Posting Time',
                                        time: postingTime,
                                        onTap: () async {
                                          final time = await showTimePicker(
                                            context: context,
                                            initialTime: postingTime,
                                          );
                                          if (time != null) {
                                            setState(() {
                                              postingTime = time;
                                            });
                                          }
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
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPurpose = value!;
                                          });
                                        },
                                        items:
                                            [
                                                  'Stock Reconciliation',
                                                  'Opening Stock',
                                                ]
                                                .map(
                                                  (item) =>
                                                      DropdownMenuItem<String>(
                                                        value: item,
                                                        child: Text(item),
                                                      ),
                                                )
                                                .toList(),
                                        isLoading: false,
                                      ),
                                      _buildTextField(
                                        label: 'Expense Account',
                                        controller: expenseAccountController,
                                      ),
                                      _buildTextField(
                                        label: 'Cost Center',
                                        controller: costCenterController,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: doNotSubmit,
                                        onChanged: (val) {
                                          setState(() {
                                            doNotSubmit = val ?? false;
                                          });
                                        },
                                      ),
                                      const Text(
                                        'Do Not Submit (Save as Draft)',
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
                                  Row(
                                    children: [
                                      const Text(
                                        'Reconciliation Items',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showAddItemSheet(context),
                                        icon: const Icon(Icons.add, size: 20),
                                        label: const Text('Add Item'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...selectedItems.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    StockReconciliationItem item = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.itemCode,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Wrap(
                                                    spacing: 16,
                                                    children: [
                                                      Text(
                                                        'Physical Qty: ${item.qty}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                      if (item.batchNo != null)
                                                        Text(
                                                          'Batch: ${item.batchNo}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      Text(
                                                        'Valuation: ${item.valuationRate?.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              final confirmed =
                                                  await DeleteConfirmationDialog.show(
                                                    context,
                                                  );
                                              if (confirmed == true) {
                                                setState(() {
                                                  selectedItems.removeAt(idx);
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  if (selectedItems.isEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'No items selected',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _createReconciliation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLoading
                                ? Colors.grey
                                : Colors.blue[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black.withAlpha(20),
                          ),
                          child: isLoading
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
                              : const Text(
                                  'Create Reconciliation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
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
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              if (required)
                const Text(' *', style: TextStyle(color: Colors.red)),
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
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading...',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      onChanged: onChanged,
                      items: items,
                      hint: const Text(
                        'Select...',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
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
                  Text(
                    DateFormat('MM/dd/yyyy').format(date),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
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
                  Text(
                    time.format(context),
                    style: const TextStyle(fontSize: 14),
                  ),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
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
  State<StockReconciliationItemSheet> createState() =>
      _StockReconciliationItemSheetState();
}

class _StockReconciliationItemSheetState
    extends State<StockReconciliationItemSheet> {
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

  // Derived/Read-only
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
            final posProfile =
                widget.currentUserResponse?.message.posProfile.name ?? '';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }
    if (physicalQtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter physical quantity')),
      );
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
      expiryDate: expiryDateController.text.isEmpty
          ? null
          : expiryDateController.text,
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
          // User requested: trigger search by item name after barcode scan
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        final allProducts = <ProductItem>{
          ...baseProducts,
          ...scannedProducts,
        }.toList();

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: widget.scrollController == null,
            controller: widget.scrollController,
            children: [
              Row(
                children: [
                  const Text(
                    'Add Item Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              // Manual Search Field
              _buildTextField(
                'Search Products',
                searchController,
                suffixIcon: Icons.search,
              ),
              if (searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    baseProducts.isEmpty
                        ? (state is ProductsStateLoading
                              ? 'Searching...'
                              : 'No products found')
                        : '${baseProducts.length} products found. Please select product below.',
                    style: TextStyle(
                      fontSize: 12,
                      color: baseProducts.isEmpty
                          ? (state is ProductsStateLoading
                                ? Colors.blue
                                : Colors.red)
                          : Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Product Selection
              Row(
                children: [
                  _buildLabel('Item Code *'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                    onPressed: _openBarcodeScanner,
                    tooltip: 'Scan Barcode',
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ProductItem>(
                    value: selectedProduct,
                    hint: const Text('Select Product'),
                    isExpanded: true,
                    items: allProducts.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text('${p.itemCode} - ${p.itemName}'),
                      );
                    }).toList(),
                    onChanged: _onProductSelected,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedProduct != null) ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Use a grid-like layout for fields
                    final width = constraints.maxWidth;
                    final halfWidth = (width - 16) / 2;

                    return Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: halfWidth,
                              child: _buildReadOnlyField(
                                'System Qty',
                                systemQty.toString(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: halfWidth,
                              child: _buildReadOnlyField('UOM', uom),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: halfWidth,
                              child: _buildTextField(
                                'Physical Qty *',
                                physicalQtyController,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: halfWidth,
                              child: _buildReadOnlyField(
                                'Difference',
                                difference.toStringAsFixed(2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: halfWidth,
                              child: _buildTextField(
                                'Valuation Rate',
                                valuationRateController,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: halfWidth,
                              child: _buildTextField(
                                'Buying Price',
                                buyingPriceController,
                                isNumber: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: halfWidth,
                              child: _buildTextField(
                                'Selling Price',
                                sellingPriceController,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: halfWidth,
                              child: _buildTextField(
                                'SKU (Optional)',
                                skuController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: halfWidth,
                              child: _buildTextField(
                                'Batch No',
                                batchNoController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: halfWidth,
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    expiryDateController.text = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(date);
                                  }
                                },
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    'Expiry Date',
                                    expiryDateController,
                                    suffixIcon: Icons.calendar_today,
                                  ),
                                ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add Item',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
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
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
