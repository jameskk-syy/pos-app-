import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/inventory/stock_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/item_list.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/inventory/widgets/stock_reconciliation_form_widgets.dart';

class StockReconciliationPage extends StatefulWidget {
  final String company;

  const StockReconciliationPage({super.key, required this.company});

  @override
  State<StockReconciliationPage> createState() =>
      _StockReconciliationPageState();
}

class _StockReconciliationPageState extends State<StockReconciliationPage> {
  String? selectedWarehouse;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    for (var item in items) {
      item.dispose();
    }
    super.dispose();
  }

  List<Warehouse> warehouses = [];
  List<StockItem> stockItems = [];
  bool isLoadingItems = false;
  bool isSubmitting = false;
  int successCount = 0;
  int failureCount = 0;

  List<ItemRow> items = [
    ItemRow(
      itemCode: null,
      itemName: null,
      systemQty: 0,
      physicalQty: 0,
      difference: 0,
      valuationRate: 0,
      stockUom: '',
    ),
  ];
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
    _loadCurrentUser();
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
      GetProductItems(company: savedUser.message.company.name),
    );
  }

  void _loadWarehouses() {
    // In a real app, this might come from Bloc, 
    // but we'll stick to the existing mock logic for now as requested.
    const jsonData = {
      "message": {
        "success": true,
        "data": [
          {
            "name": "All Warehouses - SI",
            "warehouse_name": "All Warehouses",
            "company": "Sobetra International",
            "is_group": 1,
            "disabled": 0,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "ee - SI",
            "warehouse_name": "ee",
            "company": "Sobetra International",
            "warehouse_type": "Company Warehouse",
            "is_group": 0,
            "parent_warehouse": "All Warehouses - SI",
            "disabled": 0,
            "address_line_1": "Po box 61",
            "city": "Kenya",
            "state": "MURANG'A",
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "Finished Goods - SI",
            "warehouse_name": "Finished Goods",
            "company": "Sobetra International",
            "is_group": 0,
            "parent_warehouse": "All Warehouses - SI",
            "disabled": 0,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "Goods In Transit - SI",
            "warehouse_name": "Goods In Transit",
            "company": "Sobetra International",
            "warehouse_type": "Transit",
            "is_group": 0,
            "parent_warehouse": "All Warehouses - SI",
            "disabled": 0,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "Raw aterial Rice - SI",
            "warehouse_name": "Raw aterial Rice",
            "company": "Sobetra International",
            "warehouse_type": "Transit",
            "is_group": 0,
            "disabled": 0,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "SEEDER - SI",
            "warehouse_name": "SEEDER",
            "company": "Sobetra International",
            "warehouse_type": "Company Warehouse",
            "is_group": 0,
            "disabled": 0,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "Stores - SI",
            "warehouse_name": "Stores",
            "company": "Sobetra International",
            "is_group": 0,
            "parent_warehouse": "All Warehouses - SI",
            "disabled": 0,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "Work In Progress - SI",
            "warehouse_name": "Work In Progress",
            "company": "Sobetra International",
            "is_group": 0,
            "parent_warehouse": "All Warehouses - SI",
            "disabled": 0,
            "is_main_depot": false,
            "is_default": false,
          },
        ],
        "count": 8,
      },
    };

    setState(() {
      warehouses = (jsonData['message']!['data'] as List)
          .map((w) => Warehouse.fromJson(w))
          .where((w) => w.disabled == 0 && w.isGroup == 0)
          .toList();

      if (selectedWarehouse == null && warehouses.isNotEmpty) {
        try {
          selectedWarehouse = warehouses.firstWhere((w) => w.isDefault).name;
        } catch (e) {
          // No default
        }
      }
    });
  }

  void _onItemChanged(int index, String? value) {
    if (value != null) {
      final selectedItem = stockItems.firstWhere((item) => item.name == value);
      setState(() {
        items[index].itemCode = value;
        items[index].itemName = selectedItem.itemName;
        items[index].systemQty = selectedItem.stockQty;
        items[index].stockUom = selectedItem.stockUom;
        items[index].valuationRate = selectedItem.standardRate;
        items[index].difference = items[index].physicalQty - items[index].systemQty;
      });
    }
  }

  void _onPhysicalQtyChanged(int index, String value) {
    final physicalQty = double.tryParse(value) ?? 0;
    setState(() {
      items[index].physicalQty = physicalQty;
      items[index].difference = physicalQty - items[index].systemQty;
    });
  }

  void _addItem() {
    setState(() {
      items.add(
        ItemRow(
          itemCode: null,
          itemName: null,
          systemQty: 0,
          physicalQty: 0,
          difference: 0,
          valuationRate: 0,
          stockUom: '',
        ),
      );
    });
  }

  void _onDeleteItem(int index) {
    setState(() {
      items[index].dispose();
      items.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() => selectedTime = picked);
    }
  }

  bool _canSubmit() {
    if (selectedWarehouse == null) return false;
    if (items.isEmpty) return false;
    for (var item in items) {
      if (item.itemCode == null) return false;
    }
    return true;
  }

  void _handleSubmit() async {
    if (!_canSubmit()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
      successCount = 0;
      failureCount = 0;
    });

    _showLoadingDialog();

    final companyName = currentUserResponse?.message.company.name ?? widget.company;

    for (var item in items) {
      if (item.itemCode != null && selectedWarehouse != null) {
        final stockRequest = StockRequest(
          itemCode: item.itemCode!,
          warehouse: selectedWarehouse!,
          company: companyName,
        );
        context.read<ProductsBloc>().add(AddItemToStock(stockRequest: stockRequest));
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Processing ${items.length} items...', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Success: $successCount | Failed: $failureCount', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    Navigator.of(context).pop();
    final bool allSuccess = failureCount == 0;
    setState(() => isSubmitting = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(allSuccess ? Icons.check_circle : Icons.warning, color: allSuccess ? Colors.green : Colors.orange),
            const SizedBox(width: 8),
            Text(allSuccess ? 'Success' : 'Partially Completed', style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allSuccess)
              const Text('All items have been added to stock successfully!')
            else ...[
              Text('$successCount items added successfully'),
              Text('$failureCount items failed'),
            ],
            const SizedBox(height: 16),
            Text('Warehouse: $selectedWarehouse', style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}', style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (allSuccess) Navigator.pop(context);
            },
            child: Text(allSuccess ? 'Done' : 'OK'),
          ),
          if (!allSuccess)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSubmit();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Stock Reconciliation',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ItemsStateSuccess) {
            setState(() {
              stockItems = state.stockItemResponse.data;
              isLoadingItems = false;
            });
          } else if (state is ProductsStateLoading) {
            setState(() { if (!isSubmitting) isLoadingItems = true; });
          } else if (state is ProductsStateFailure) {
            setState(() {
              isLoadingItems = false;
              if (isSubmitting) failureCount++;
            });
            if (isSubmitting) {
              if (successCount + failureCount >= items.length) _showCompletionDialog();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load items: ${state.error}'), backgroundColor: Colors.red),
              );
            }
          } else if (state is AddItemToStockSuccess) {
            setState(() => successCount++);
            if (successCount + failureCount >= items.length) _showCompletionDialog();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReconciliationHeader(
                      selectedWarehouse: selectedWarehouse,
                      warehouses: warehouses,
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      onWarehouseChanged: (val) => setState(() => selectedWarehouse = val),
                      onSelectDate: () => _selectDate(context),
                      onSelectTime: () => _selectTime(context),
                    ),
                    const SizedBox(height: 30),
                    ReconciliationTable(
                      items: items,
                      stockItems: stockItems,
                      isLoadingItems: isLoadingItems,
                      onAddItem: _addItem,
                      onDeleteItem: _onDeleteItem,
                      onItemChanged: _onItemChanged,
                      onPhysicalQtyChanged: _onPhysicalQtyChanged,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            ReconciliationSubmitActions(
              isSubmitting: isSubmitting,
              canSubmit: _canSubmit(),
              onSubmit: _handleSubmit,
              onCancel: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
