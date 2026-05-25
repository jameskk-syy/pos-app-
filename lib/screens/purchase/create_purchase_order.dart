import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/purchase/create_purchase_order_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/suppliers/suppliers_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/purchase/widgets/purchase_order_widgets.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});
  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  DateTime postingDate = DateTime.now();
  Warehouse? _selectedStore;
  Supplier? _selectedSupplier;
  List<Warehouse> _stores = [];
  List<Supplier> _suppliers = [];
  List<ProductItem> _products = [];
  final List<StockItem> items = [];
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentUser());
  }

  @override
  void dispose() { for (var item in items) {
    item.dispose();
  } super.dispose(); }

  Future<void> _loadCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (!mounted || userString == null) return;
    setState(() => currentUserResponse = CurrentUserResponse.fromJson(jsonDecode(userString)));
    final company = currentUserResponse!.message.company.name;
    context.read<StoreBloc>().add(GetAllStores(company: company));
    context.read<ProductsBloc>().add(GetAllProducts(company: company));
    context.read<SuppliersBloc>().add(GetSuppliers(company: company, limit: 100, offset: 0));
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
                if (_selectedStore == null) try { _selectedStore = _stores.firstWhere((w) => w.isDefault); } catch (_) {}
              });
            }
          },
        ),
        BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) { if (state is ProductsStateSuccess) setState(() => _products = state.productResponse.products); },
        ),
        BlocListener<SuppliersBloc, SuppliersState>(
          listener: (context, state) { if (state is SuppliersLoaded) setState(() => _suppliers = state.response.data.suppliers); },
        ),
        BlocListener<PurchaseBloc, PurchaseState>(
          listener: (context, state) {
            if (state is PurchaseOrderCreated) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Purchase order created: ${state.response.message.lpoNo}'), backgroundColor: Colors.green));
              Navigator.pop(context, true);
            } else if (state is PurchaseOrderCreateError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)), title: const Text('Purchase Order', style: TextStyle(color: Colors.black, fontSize: 18)), actions: [TextButton(onPressed: () {}, child: const Text('View History')), const SizedBox(width: 12)]),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: ListView(children: [
                PurchaseOrderHeaderFields(
                  suppliers: _suppliers, selectedSupplier: _selectedSupplier, onSupplierChanged: (v) => setState(() => _selectedSupplier = v),
                  stores: _stores, selectedStore: _selectedStore, onStoreChanged: (v) => setState(() => _selectedStore = v),
                  postingDate: postingDate,
                  onDateTap: () async {
                    final p = await showDatePicker(context: context, initialDate: postingDate, firstDate: DateTime(2020), lastDate: DateTime(2035));
                    if (p != null) setState(() => postingDate = p);
                  }
                ),
                const SizedBox(height: 16),
                PurchaseOrderItemsTable(
                  items: items, products: _products, stores: _stores,
                  onAddItem: () => setState(() => items.add(StockItem())),
                  onRemoveItem: (i) { items[i].dispose(); setState(() => items.removeAt(i)); },
                  onProductSelected: (i, p) => setState(() { items[i].selectedProduct = p; items[i].itemCode = p.itemCode; }),
                  subtotal: items.fold(0.0, (sum, item) => sum + (item.quantity * item.rate)),
                  isLoadingProducts: context.watch<ProductsBloc>().state is ProductsStateLoading,
                  companyName: currentUserResponse?.message.company.name,
                ),
              ])),
              BlocBuilder<PurchaseBloc, PurchaseState>(builder: (context, state) => PurchaseOrderBottomButtons(isLoading: state is PurchaseOrderCreating, onCancel: () => Navigator.pop(context), onSubmit: _submitPurchaseOrder)),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPurchaseOrder() {
    if (_selectedSupplier == null || _selectedStore == null || items.isEmpty) { _msg('Please fill all required fields and add items'); return; }
    if (items.any((i) => i.selectedProduct == null || i.warehouse == null)) { _msg('Please select item and warehouse for all rows'); return; }
    if (items.any((i) => i.quantity <= 0 || i.rate <= 0)) { _msg('All items must have valid quantity and rate'); return; }

    final company = currentUserResponse!.message.company.name;
    final formattedDate = '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';

    final request = CreatePurchaseOrderRequest(
      company: company, supplier: _selectedSupplier!.supplierName, transactionDate: formattedDate,
      items: items.map((i) {
        final sDate = i.scheduleDate ?? DateTime.now();
        return PurchaseOrderItemRequest(itemCode: i.itemCode!, qty: i.quantity.toDouble(), rate: i.rate, warehouse: i.warehouse!.name, scheduleDate: '${sDate.year}-${sDate.month.toString().padLeft(2, '0')}-${sDate.day.toString().padLeft(2, '0')}');
      }).toList(),
    );
    context.read<PurchaseBloc>().add(CreatePurchaseOrderEvent(request: request));
  }

  void _msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}

class StockItem {
  String? itemCode;
  int quantity = 1;
  double rate = 0.0;
  ProductItem? selectedProduct;
  Warehouse? warehouse;
  DateTime? scheduleDate;
  late TextEditingController qtyController, rateController;
  StockItem() {
    qtyController = TextEditingController(text: quantity.toString());
    rateController = TextEditingController(text: rate.toString());
  }
  void dispose() { qtyController.dispose(); rateController.dispose(); }
}
