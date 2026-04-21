import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/inventory/create_material_receipt_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/inventory/widgets/stock_receipt_widgets.dart';

class StockReceiptPage extends StatefulWidget {
  const StockReceiptPage({super.key});

  @override
  State<StockReceiptPage> createState() => _StockReceiptPageState();
}

class _StockReceiptPageState extends State<StockReceiptPage> {
  DateTime postingDate = DateTime.now();
  TimeOfDay postingTime = TimeOfDay.now();

  String? _selectedStoreName;
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              setState(() {
                _stores = state.storeGetResponse.message.data;
                if (_selectedStoreName == null && _stores.isNotEmpty) {
                  try {
                    _selectedStoreName = _stores.firstWhere((store) => store.isDefault).name;
                  } catch (e) {
                    // No default warehouse found
                  }
                }
              });
            }
          },
        ),
        BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductsStateSuccess) {
              setState(() => _products = state.productResponse.products);
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is CreateMaterialReceiptSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Material receipt created: ${state.response.data?.name ?? ""}'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is CreateMaterialReceiptError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_formatErrorMessage(state.message)),
                  backgroundColor: Colors.red,
                  showCloseIcon: true,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Material Receipt', style: TextStyle(color: Colors.black, fontSize: 18)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    StockReceiptHeaderFields(
                      selectedWarehouseName: _selectedStoreName,
                      stores: _stores,
                      postingDate: postingDate,
                      postingTime: postingTime,
                      onWarehouseChanged: (val) => setState(() => _selectedStoreName = val),
                      onSelectDate: _selectDate,
                      onSelectTime: _selectTime,
                    ),
                    const SizedBox(height: 20),
                    StockReceiptItemsTable(
                      items: items,
                      products: _products,
                      companyName: currentUserResponse?.message.company.name ?? '',
                      onAddItem: () => setState(() => items.add(StockItem())),
                      onDeleteItem: (index) => setState(() => items.removeAt(index)),
                      onProductSelected: (index, product) {
                        setState(() {
                          items[index].selectedProduct = product;
                          items[index].itemCode = product.itemCode;
                          items[index].basicRate = product.standardRate;
                        });
                      },
                      onQtyChanged: (index, val) => items[index].quantity = int.tryParse(val) ?? 1,
                      onRateChanged: (index, val) => items[index].basicRate = double.tryParse(val) ?? 0.0,
                    ),
                  ],
                ),
              ),
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) => StockReceiptSubmitActions(
                  isLoading: state is CreateMaterialReceiptLoading,
                  onCancel: () => Navigator.pop(context),
                  onSubmit: _submitMaterialReceipt,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: postingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => postingDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: postingTime,
    );
    if (picked != null) setState(() => postingTime = picked);
  }

  String _formatErrorMessage(String message) {
    var coreMessage = message;
    if (coreMessage.startsWith('Error: ')) coreMessage = coreMessage.substring(7);
    if (coreMessage.contains('Valuation Rate for the Item')) {
      final itemMatch = RegExp(r'Valuation Rate for the Item (.*?), is required').firstMatch(coreMessage);
      if (itemMatch != null) {
        return 'Valuation Rate for Item ${itemMatch.group(1)}, is required,  please manage price at product  level';
      }
    }
    final match = RegExp(r'\.([A-Z])|\. (Here|If|Please|You|Note)').firstMatch(coreMessage);
    if (match != null) coreMessage = '${coreMessage.substring(0, match.start).trim()}.';
    return coreMessage;
  }

  void _submitMaterialReceipt() {
    if (_selectedStoreName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a warehouse')));
      return;
    }
    if (items.isEmpty || items.any((item) => item.selectedProduct == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item with valid item code')));
      return;
    }
    final formattedDate = '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';
    final request = CreateMaterialReceiptRequest(
      items: items.map((item) => MaterialReceiptItem(itemCode: item.itemCode!, qty: item.quantity.toDouble(), tWarehouse: _selectedStoreName!)).toList(),
      targetWarehouse: _selectedStoreName!,
      postingDate: formattedDate,
      doNotSubmit: false,
      company: currentUserResponse!.message.company.name,
    );
    context.read<InventoryBloc>().add(CreateMaterialReceipt(request: request));
  }
}
