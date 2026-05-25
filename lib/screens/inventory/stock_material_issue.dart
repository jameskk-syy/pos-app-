import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/inventory/create_material_issue_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/widgets/common/error_dialog.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/inventory/widgets/material_issue_widgets.dart';

class MaterialIssuePage extends StatefulWidget {
  const MaterialIssuePage({super.key});

  @override
  State<MaterialIssuePage> createState() => _MaterialIssuePageState();
}

class _MaterialIssuePageState extends State<MaterialIssuePage> {
  DateTime postingDate = DateTime.now();
  TimeOfDay postingTime = TimeOfDay.now();

  Warehouse? _selectedStore;
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              setState(() {
                _stores = state.storeGetResponse.message.data;
                if (_selectedStore == null && _stores.isNotEmpty) {
                  try {
                    final defaultStore = _stores.firstWhere((store) => store.isDefault);
                    _handleWarehouseChange(defaultStore);
                  } catch (e) {
                    // No default warehouse
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
            if (state is CreateMaterialIssueSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Material issue created: ${state.response.data?.name ?? ""}'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is CreateMaterialIssueError) {
              ErrorDialog.show(context, state.message);
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
          title: const Text('Material Issue', style: TextStyle(color: Colors.black, fontSize: 18)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    MaterialIssueHeaderFields(
                      selectedWarehouse: _selectedStore,
                      stores: _stores,
                      postingDate: postingDate,
                      postingTime: postingTime,
                      onWarehouseChanged: _handleWarehouseChange,
                      onSelectDate: _selectDate,
                      onSelectTime: _selectTime,
                    ),
                    const SizedBox(height: 20),
                    MaterialIssueItemsTable(
                      items: items,
                      products: _products,
                      companyName: currentUserResponse?.message.company.name ?? '',
                      onAddItem: () => setState(() => items.add(StockItem())),
                      onDeleteItem: (index) {
                        setState(() {
                          items[index].dispose();
                          items.removeAt(index);
                        });
                      },
                      onProductSelected: (index, product) {
                        setState(() {
                          items[index].selectedProduct = product;
                          items[index].itemCode = product.itemCode;
                        });
                      },
                    ),
                  ],
                ),
              ),
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) => MaterialIssueSubmitActions(
                  isLoading: state is CreateMaterialIssueLoading,
                  onCancel: () => Navigator.pop(context),
                  onSubmit: _submitMaterialIssue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleWarehouseChange(Warehouse? newValue) {
    setState(() {
      _selectedStore = newValue;
      items.clear();
    });
    if (newValue != null && currentUserResponse != null) {
      context.read<ProductsBloc>().add(
        GetAllProducts(
          company: currentUserResponse!.message.company.name,
          warehouse: newValue.name,
        ),
      );
    }
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

  void _submitMaterialIssue() {
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a warehouse')));
      return;
    }

    if (items.isEmpty || items.any((item) => item.selectedProduct == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item with valid item code')));
      return;
    }

    final formattedDate = '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';

    final request = CreateMaterialIssueRequest(
      items: items.map((item) {
        return MaterialIssueItem(
          itemCode: item.itemCode!,
          qty: item.quantity.toDouble(),
          sWarehouse: _selectedStore!.name,
          purpose: item.purpose,
        );
      }).toList(),
      sourceWarehouse: _selectedStore!.name,
      postingDate: formattedDate,
      doNotSubmit: false,
      company: currentUserResponse!.message.company.name,
    );
    context.read<InventoryBloc>().add(CreateMaterialIssue(request: request));
  }
}
