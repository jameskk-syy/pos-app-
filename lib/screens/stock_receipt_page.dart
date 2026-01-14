import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_material_receipt_request.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockReceiptPage extends StatefulWidget {
  const StockReceiptPage({super.key});

  @override
  State<StockReceiptPage> createState() => _StockReceiptPageState();
}

class _StockReceiptPageState extends State<StockReceiptPage> {
  DateTime postingDate = DateTime.now();
  TimeOfDay postingTime = const TimeOfDay(hour: 8, minute: 0);

  Warehouse? _selectedStore;
  List<Warehouse> _stores = [];
  List<ProductItem> _products = [];

  final List<StockItem> items = [];
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    // Fetch stores and products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
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
        // ADD THIS NEW LISTENER FOR MATERIAL RECEIPT
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is CreateMaterialReceiptSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Material receipt created: ${state.response.data?.name ?? ""}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate back after successful creation
              Navigator.pop(context);
            } else if (state is CreateMaterialReceiptError) {
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
            'Material Receipt',
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
                    _label('Target Warehouse*'),
                    _storeDropdown(),
                    const SizedBox(height: 16),

                    _label('Posting Date*'),
                    _dateField(),
                    const SizedBox(height: 16),

                    _label('Posting Time'),
                    _timeField(),
                    const SizedBox(height: 4),
                    const Text(
                      'Optional (HH:MM:SS)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 20),
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
                  child: Text(
                    store.warehouseName,
                    style: const TextStyle(fontSize: 14),
                  ),
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

  Widget _timeField() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: postingTime,
        );
        if (picked != null) setState(() => postingTime = picked);
      },
      child: _inputBox(
        '${postingTime.hour.toString().padLeft(2, '0')}:${postingTime.minute.toString().padLeft(2, '0')}:00',
        Icons.access_time,
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
                    _Header('Qty*', 80),
                    _Header('Basic Rate*', 100),
                    _Header('', 50),
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
                                : 'Select Item',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: item?.selectedProduct,
                      items: _products.map((product) {
                        return DropdownMenuItem<ProductItem>(
                          value: product,
                          child: Text(
                            '${product.itemCode} - ${product.itemName}',
                            style: const TextStyle(fontSize: 12, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (ProductItem? newValue) {
                        if (index >= 0 && newValue != null) {
                          setState(() {
                            items[index].selectedProduct = newValue;
                            items[index].itemCode = newValue.itemCode;
                            items[index].basicRate = newValue.standardRate;
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
            width: 80,
            height: 40,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextFormField(
                controller: TextEditingController(
                  text: item?.quantity.toString() ?? '1',
                ),
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  if (index >= 0) {
                    items[index].quantity = int.tryParse(value) ?? 1;
                  }
                },
              ),
            ),
          ),

          // Basic Rate field
          SizedBox(
            width: 100,
            height: 40,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextFormField(
                controller: TextEditingController(
                  text: item?.basicRate.toStringAsFixed(2) ?? '0.00',
                ),
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  if (index >= 0) {
                    items[index].basicRate = double.tryParse(value) ?? 0.0;
                  }
                },
              ),
            ),
          ),

          // Delete button
          SizedBox(
            width: 50,
            height: 40,
            child: index >= 0
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () {
                      setState(() => items.removeAt(index));
                    },
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _bottomButtons() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        final isLoading = state is CreateMaterialReceiptLoading;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () {
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
                  onPressed: isLoading ? null : _submitMaterialReceipt,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 8),
                            Text('Create'),
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

  void _submitMaterialReceipt() {
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a warehouse')),
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

    // Format posting date
    final formattedDate =
        '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';

    // Create the request object
    final request = CreateMaterialReceiptRequest(
      items: items.map((item) {
        return MaterialReceiptItem(
          itemCode: item.itemCode!,
          qty: item.quantity.toDouble(),
          tWarehouse: _selectedStore!.name,
        );
      }).toList(),
      targetWarehouse: _selectedStore!.name,
      postingDate: formattedDate,
      doNotSubmit: false,
      company: currentUserResponse!.message.company.name,
    );

    // Dispatch the event to BLoC
    context.read<InventoryBloc>().add(
      CreateMaterialReceipt(request: request),
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
  double basicRate = 0;
  ProductItem? selectedProduct;
}