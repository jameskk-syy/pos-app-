import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_purchase_order_request.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/domain/responses/suppliers_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
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
    context.read<SuppliersBloc>().add(
      GetSuppliers(
        company: savedUser.message.company.name,
        limit: 100,
        offset: 0,
      ),
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
              });
            }
          },
        ),
        BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductsStateSuccess) {
              setState(() {
                _products = state.productResponseSimple.products;
              });
            }
          },
        ),
        BlocListener<SuppliersBloc, SuppliersState>(
          listener: (context, state) {
            if (state is SuppliersLoaded) {
              setState(() {
                _suppliers = state.response.data.suppliers;
              });
            }
          },
        ),
        // Add Purchase Bloc Listener
        BlocListener<PurchaseBloc, PurchaseState>(
          listener: (context, state) {
            if (state is PurchaseOrderCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Purchase order created: ${state.response.message.lpoNo}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is PurchaseOrderCreateError) {
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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Purchase Order',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: [
            TextButton(onPressed: () {}, child: const Text('View History')),
            const SizedBox(width: 12),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _label('Suppliers*'),
                    _suppliersDropdown(),
                    const SizedBox(height: 16),
                    _label('Default Warehouse*'),
                    _storeDropdown(),
                    const SizedBox(height: 16),

                    _label('Posting Date*'),
                    _dateField(),
                    const SizedBox(height: 16),
                    _itemsCard(),
                  ],
                ),
              ),
              _bottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }

  Widget _storeDropdown() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Warehouse>(
              isExpanded: true,
              hint: Text(
                state is StoreStateLoading
                    ? 'Loading stores...'
                    : _stores.isEmpty
                    ? 'No stores available'
                    : 'Choose a warehouse',
              ),
              value: _selectedStore,
              items: _stores.map((store) {
                return DropdownMenuItem<Warehouse>(
                  value: store,
                  child: Text(store.name, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (Warehouse? newValue) {
                setState(() {
                  _selectedStore = newValue;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _suppliersDropdown() {
    return BlocBuilder<SuppliersBloc, SuppliersState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Supplier>(
              isExpanded: true,
              hint: Text(
                state is SuppliersLoading
                    ? 'Loading suppliers...'
                    : _suppliers.isEmpty
                    ? 'No suppliers available'
                    : 'Choose a supplier',
              ),
              value: _selectedSupplier,
              items: _suppliers.map((supplier) {
                return DropdownMenuItem<Supplier>(
                  value: supplier,
                  child: Text(
                    supplier.supplierName,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (Supplier? newValue) {
                setState(() {
                  _selectedSupplier = newValue;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: postingDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) setState(() => postingDate = picked);
      },
      child: _inputBox(
        '${postingDate.day}/${postingDate.month}/${postingDate.year}',
        Icons.calendar_today,
      ),
    );
  }

  Widget _inputBox(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          Icon(icon, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _itemsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Row(
                  children: const [
                    _Header('Item Code*', 200),
                    _Header('Quantity*', 100),
                    _Header('Rate', 100),
                    _Header('Amount', 100),
                    _Header('Warehouse', 150),
                    _Header('Schedule Date', 150),
                    _Header('Actions', 80),
                  ],
                ),
                const SizedBox(height: 8),

                if (items.isEmpty)
                  _itemRow(null, -1)
                else
                  ...items.asMap().entries.map((e) => _itemRow(e.value, e.key)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Subtotal row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 24),
              Text(
                'KES ${_calculateSubtotal().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: () {
              setState(() {
                items.add(StockItem());
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(StockItem? item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Item Code Dropdown
          SizedBox(
            width: 200,
            height: 40,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<ProductItem>(
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12),
                      hint: Text(
                        state is ProductsStateLoading
                            ? 'Loading...'
                            : _products.isEmpty
                            ? 'No items'
                            : 'Sel...',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: item?.selectedProduct,
                      items: _products.map((product) {
                        return DropdownMenuItem<ProductItem>(
                          value: product,
                          child: Text(
                            '${product.itemCode} - ${product.itemName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (ProductItem? newValue) {
                        if (index >= 0 && newValue != null) {
                          setState(() {
                            items[index].selectedProduct = newValue;
                            items[index].itemCode = newValue.itemCode;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Quantity field
          SizedBox(
            width: 100,
            height: 40,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              child: TextFormField(
                controller: item?.qtyController,
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  if (index >= 0 && item != null) {
                    item.quantity = int.tryParse(value) ?? 1;
                    setState(() {});
                  }
                },
              ),
            ),
          ),

          // Rate field
          SizedBox(
            width: 100,
            height: 40,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              child: TextFormField(
                controller: item?.rateController,
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  if (index >= 0 && item != null) {
                    item.rate = double.tryParse(value) ?? 0.0;
                    setState(() {});
                  }
                },
              ),
            ),
          ),

          // Amount field (calculated, read-only)
          SizedBox(
            width: 100,
            height: 40,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'KES ${item != null ? (item.quantity * item.rate).toStringAsFixed(2) : '0.00'}',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Warehouse dropdown
          SizedBox(
            width: 150,
            height: 40,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: BlocBuilder<StoreBloc, StoreState>(
                builder: (context, state) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<Warehouse>(
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12),
                      hint: const Text(
                        'Select...',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: item?.warehouse,
                      items: _stores.map((store) {
                        return DropdownMenuItem<Warehouse>(
                          value: store,
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (Warehouse? newValue) {
                        if (index >= 0 && newValue != null) {
                          setState(() {
                            items[index].warehouse = newValue;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Schedule Date field
          SizedBox(
            width: 150,
            height: 40,
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: item?.scheduleDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null && index >= 0) {
                  setState(() {
                    items[index].scheduleDate = picked;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item?.scheduleDate != null
                          ? '${item!.scheduleDate!.day}/${item.scheduleDate!.month}/${item.scheduleDate!.year}'
                          : '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Delete button
          SizedBox(
            width: 80,
            height: 40,
            child: index >= 0
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      if (index >= 0) {
                        items[index].dispose();
                        setState(() => items.removeAt(index));
                      }
                    },
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    double total = 0.0;
    for (var item in items) {
      total += item.quantity * item.rate;
    }
    return total;
  }

  Widget _bottomButtons() {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, state) {
        final isLoading = state is PurchaseOrderCreating;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitPurchaseOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 8),
                            Text('Create Purchase Order'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitPurchaseOrder() {
    // Validate supplier
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a supplier')));
      return;
    }

    // Validate warehouse
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a default warehouse')),
      );
      return;
    }

    // Validate items
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    // Validate that all items have products selected
    if (items.any((item) => item.selectedProduct == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select item code for all items')),
      );
      return;
    }

    // Validate that all items have warehouses
    if (items.any((item) => item.warehouse == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select warehouse for all items')),
      );
      return;
    }

    // Validate quantities and rates
    if (items.any((item) => item.quantity <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid quantities for all items'),
        ),
      );
      return;
    }

    if (items.any((item) => item.rate <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid rates for all items')),
      );
      return;
    }

    // Format transaction date (posting date)
    final formattedDate =
        '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';

    // Create the request object
    final request = CreatePurchaseOrderRequest(
      company: currentUserResponse!.message.company.name,
      supplier: _selectedSupplier!.supplierName,
      transactionDate: formattedDate,
      items: items.map((item) {
        // Format schedule date
        final scheduleDate = item.scheduleDate ?? DateTime.now();
        final formattedScheduleDate =
            '${scheduleDate.year}-${scheduleDate.month.toString().padLeft(2, '0')}-${scheduleDate.day.toString().padLeft(2, '0')}';

        return PurchaseOrderItemRequest(
          itemCode: item.itemCode!,
          qty: item.quantity.toDouble(),
          rate: item.rate,
          warehouse: item.warehouse!.name,
          scheduleDate: formattedScheduleDate,
        );
      }).toList(),
    );

    // Dispatch the event to create purchase order
    context.read<PurchaseBloc>().add(
      CreatePurchaseOrderEvent(request: request),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  final double width;
  const _Header(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class StockItem {
  String? itemCode;
  int quantity = 1;
  double rate = 0.0;
  ProductItem? selectedProduct;
  Warehouse? warehouse;
  DateTime? scheduleDate;

  late TextEditingController qtyController;
  late TextEditingController rateController;

  StockItem() {
    qtyController = TextEditingController(text: quantity.toString());
    rateController = TextEditingController(text: rate.toString());
  }

  void dispose() {
    qtyController.dispose();
    rateController.dispose();
  }
}
