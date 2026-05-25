import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/inventory/create_stock_transfer_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/screens/inventory/widgets/stock_transfer_widgets.dart';

class StockTransfer extends StatefulWidget {
  const StockTransfer({super.key});

  @override
  State<StockTransfer> createState() => _StockTransferState();
}

class _StockTransferState extends State<StockTransfer> {
  DateTime postingDate = DateTime.now();
  DateTime scheduleDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay postingTime = TimeOfDay.now();

  Warehouse? _selectedSourceStore;
  Warehouse? _selectedTargetStore;
  List<Warehouse> _stores = [];
  List<ProductItem> _products = [];

  final List<StockItem> items = [];
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  @override
  void dispose() {
    for (var item in items) {
      item.dispose();
    }
    super.dispose();
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

    context.read<StoreBloc>().add(
      GetAllStores(company: savedUser.message.company.name),
    );
    context.read<ProductsBloc>().add(
      GetAllProducts(company: savedUser.message.company.name),
    );
  }

  void _submitStockTransfer() {
    if (_selectedSourceStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a source warehouse')),
      );
      return;
    }

    if (_selectedTargetStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target warehouse')),
      );
      return;
    }

    if (_selectedSourceStore == _selectedTargetStore) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Source and target warehouses must be different'),
        ),
      );
      return;
    }

    if (items.isEmpty || items.any((item) => item.selectedProduct == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item with valid item code'),
        ),
      );
      return;
    }

    final formattedTransactionDate =
        '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';

    final formattedScheduleDate =
        '${scheduleDate.year}-${scheduleDate.month.toString().padLeft(2, '0')}-${scheduleDate.day.toString().padLeft(2, '0')}';

    final request = CreateStockTransferRequest(
      company: currentUserResponse!.message.company.name,
      fromWarehouse: _selectedSourceStore!.name,
      toWarehouse: _selectedTargetStore!.name,
      items: items.map((item) {
        return StockTransferItem(
          itemCode: item.itemCode!,
          qty: item.quantity.toDouble(),
        );
      }).toList(),
      transactionDate: formattedTransactionDate,
      scheduleDate: formattedScheduleDate,
      submit: false,
    );

    context.read<InventoryBloc>().add(CreateStockTransfer(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              setState(() {
                _stores = state.storeGetResponse.message.data;
                if (_selectedSourceStore == null && _stores.isNotEmpty) {
                  final defaultStore = _stores.where((store) => store.isDefault);
                  if (defaultStore.isNotEmpty) {
                    _selectedSourceStore = defaultStore.first;
                  }
                }
              });
            }
          },
        ),
        BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductsStateSuccess) {
              setState(() {
                _products = state.productResponse.products;
              });
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is CreateStockTransferSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Stock transfer request created: ${state.response.message.data.materialRequest}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is CreateStockTransferError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Stock Transfer',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      WarehouseSelector(
                        selectedSourceStore: _selectedSourceStore,
                        selectedTargetStore: _selectedTargetStore,
                        stores: _stores,
                        onSourceChanged: (v) => setState(() => _selectedSourceStore = v),
                        onTargetChanged: (v) => setState(() => _selectedTargetStore = v),
                      ),
                      const SizedBox(height: 16),
                      DateAndTimeFields(
                        postingDate: postingDate,
                        scheduleDate: scheduleDate,
                        postingTime: postingTime,
                        onSelectPostingDate: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: postingDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) setState(() => postingDate = picked);
                        },
                        onSelectScheduleDate: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: scheduleDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) setState(() => scheduleDate = picked);
                        },
                        onSelectPostingTime: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: postingTime,
                          );
                          if (picked != null) setState(() => postingTime = picked);
                        },
                      ),
                      const SizedBox(height: 20),
                      StockItemsTable(
                        items: items,
                        products: _products,
                        onAddItem: () => setState(() => items.add(StockItem())),
                        onDeleteItem: (index) {
                          setState(() {
                            items[index].dispose();
                            items.removeAt(index);
                          });
                        },
                        onItemChanged: (index, p) {
                          setState(() {
                            items[index].selectedProduct = p;
                            items[index].itemCode = p.itemCode;
                          });
                        },
                        onQtyChanged: (index, v) {
                          items[index].quantity = int.tryParse(v) ?? 1;
                        },
                        onPurposeChanged: (index, v) {
                          items[index].purpose = v;
                        },
                        currentUserResponse: currentUserResponse,
                      ),
                    ],
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        final isLoading = state is CreateStockTransferLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitStockTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Transfer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StockItem {
  String? itemCode;
  int quantity = 1;
  String purpose = '';
  ProductItem? selectedProduct;
  final TextEditingController qtyController;
  final TextEditingController purposeController;

  StockItem()
      : qtyController = TextEditingController(text: '1'),
        purposeController = TextEditingController();

  void dispose() {
    qtyController.dispose();
    purposeController.dispose();
  }
}
