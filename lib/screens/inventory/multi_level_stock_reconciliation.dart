import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/inventory/create_stock_reconciliation_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/widgets/common/delete_confirmation_dialog.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/inventory/widgets/stock_reconciliation_widgets.dart';

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
  final TextEditingController expenseAccountController = TextEditingController();
  final TextEditingController costCenterController = TextEditingController();
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
        const SnackBar(content: Text('Please select a warehouse'), backgroundColor: Colors.red),
      );
      return;
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item'), backgroundColor: Colors.red),
      );
      return;
    }

    final request = CreateStockReconciliationRequest(
      warehouse: selectedWarehouse!,
      postingDate: DateFormat('yyyy-MM-dd').format(postingDate),
      postingTime: '${postingTime.hour.toString().padLeft(2, '0')}:${postingTime.minute.toString().padLeft(2, '0')}:00',
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
            onItemAdded: _addItemToSelectedList,
            currentUserResponse: currentUserResponse,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            width: 600,
            child: StockReconciliationItemSheet(
              onItemAdded: _addItemToSelectedList,
              currentUserResponse: currentUserResponse,
            ),
          ),
        ),
      );
    }
  }

  void _addItemToSelectedList(StockReconciliationItem item) {
    setState(() {
      final index = selectedItems.indexWhere((element) => element.itemCode == item.itemCode);
      if (index != -1) {
        selectedItems[index] = item;
      } else {
        selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductsStateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading products: ${state.error}'), backgroundColor: Colors.red));
            }
          },
        ),
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading warehouses: ${state.error}'), backgroundColor: Colors.red));
            }
            if (state is StoreStateSuccess) {
              setState(() {
                warehouses = state.storeGetResponse.message.data;
                if (warehouses.isNotEmpty && selectedWarehouse == null) {
                  final defaultWarehouse = warehouses.firstWhere((w) => w.isDefault, orElse: () => warehouses.first);
                  selectedWarehouse = defaultWarehouse.name;
                }
              });
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is CreateStockReconciliationLoading) setState(() => isLoading = true);
            if (state is CreateStockReconciliationSuccess) {
              setState(() => isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reconciliation created successfully: ${state.response.message.data.name}'), backgroundColor: Colors.green));
              Navigator.pop(context, true);
            }
            if (state is CreateStockReconciliationError) {
              setState(() => isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Create Multi-Level Stock Reconciliation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ReconciliationFormSection(
                    selectedWarehouse: selectedWarehouse,
                    warehouses: warehouses,
                    onWarehouseChanged: (val) => setState(() => selectedWarehouse = val),
                    postingDate: postingDate,
                    onDateChanged: (val) => setState(() => postingDate = val),
                    postingTime: postingTime,
                    onTimeChanged: (val) => setState(() => postingTime = val),
                    selectedPurpose: selectedPurpose,
                    onPurposeChanged: (val) => setState(() => selectedPurpose = val),
                    expenseAccountController: expenseAccountController,
                    costCenterController: costCenterController,
                    doNotSubmit: doNotSubmit,
                    onDoNotSubmitChanged: (val) => setState(() => doNotSubmit = val),
                    isStoreLoading: context.watch<StoreBloc>().state is StoreStateLoading,
                  ),
                  const SizedBox(height: 24),
                  ReconciliationItemsList(
                    selectedItems: selectedItems,
                    onAddItem: () => _showAddItemSheet(context),
                    onDeleteItem: (idx) async {
                      final confirmed = await DeleteConfirmationDialog.show(context);
                      if (confirmed == true) setState(() => selectedItems.removeAt(idx));
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            ReconciliationSubmitButton(
              isLoading: isLoading,
              onPressed: _createReconciliation,
            ),
          ],
        ),
      ),
    );
  }
}
