import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_transfer_request.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTransferForm extends StatefulWidget {
  const CreateTransferForm({super.key});

  @override
  State<CreateTransferForm> createState() => _CreateTransferFormState();
}

class _CreateTransferFormState extends State<CreateTransferForm> {
  DateTime postingDate = DateTime.now();
  TimeOfDay postingTime = const TimeOfDay(hour: 8, minute: 0);

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
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is CreateMaterialTransferSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Material transfer created: ${state.response.data.name}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is CreateMaterialTransferError) {
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
            'Material Transfer',
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
                    _label('Source Warehouse*'),
                    _storeDropdown(isSource: true),
                    const SizedBox(height: 16),
                    _label('Target Warehouse*'),
                    _storeDropdown(isSource: false),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _storeDropdown({required bool isSource}) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        final selectedStore = isSource
            ? _selectedSourceStore
            : _selectedTargetStore;

        return DropdownButtonFormField<Warehouse>(
          isExpanded: true,
          hint: Text(
            state is StoreStateLoading
                ? 'Loading stores...'
                : _stores.isEmpty
                ? 'No stores available'
                : 'Choose a warehouse',
          ),
          initialValue: selectedStore,
          items: _stores.map((store) {
            return DropdownMenuItem<Warehouse>(
              value: store,
              child: Text(store.name, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (Warehouse? newValue) {
            setState(() {
              if (isSource) {
                _selectedSourceStore = newValue;
              } else {
                _selectedTargetStore = newValue;
              }
            });
          },
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    return InputDecorator(
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _Header('Item Code*', 200),
                    _Header('Qty*', 90),
                    _Header('Purpose*', 160),
                    _Header('', 50),
                  ],
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No items added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
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

  Widget _itemRow(StockItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Item Code Dropdown
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  return DropdownButtonFormField<ProductItem>(
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    hint: Text(
                      state is ProductsStateLoading
                          ? 'Loading...'
                          : _products.isEmpty
                          ? 'No items'
                          : 'Select Item',
                      style: const TextStyle(fontSize: 12),
                    ),
                    initialValue: item.selectedProduct,
                    items: _products.map((product) {
                      return DropdownMenuItem<ProductItem>(
                        value: product,
                        child: Text(
                          '${product.itemCode} - ${product.itemName}',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (ProductItem? newValue) {
                      if (newValue != null) {
                        setState(() {
                          item.selectedProduct = newValue;
                          item.itemCode = newValue.itemCode;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                  );
                },
              ),
            ),
          ),

          // Quantity field
          SizedBox(
            width: 90,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: item.qtyController,
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
                onChanged: (value) {
                  item.quantity = int.tryParse(value) ?? 1;
                },
              ),
            ),
          ),

          // Purpose field
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: item.purposeController,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  isDense: true,
                  hintText: 'Purpose',
                  hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onChanged: (value) {
                  item.purpose = value;
                },
              ),
            ),
          ),

          // Delete button
          SizedBox(
            width: 50,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  items[index].dispose();
                  items.removeAt(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButtons() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        final isLoading = state is CreateMaterialTransferLoading;

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
                  onPressed: isLoading ? null : _submitMaterialTransfer,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
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

  void _submitMaterialTransfer() {
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

    // Format posting date
    final formattedDate =
        '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';

    // Create the request object for Material Transfer
    final request = CreateMaterialTransferRequest(
      items: items.map((item) {
        return TransferItem(
          itemCode: item.itemCode!,
          qty: item.quantity.toDouble(),
          sWarehouse: _selectedSourceStore!.name,
          tWarehouse: _selectedTargetStore!.name,
        );
      }).toList(),
      sourceWarehouse: _selectedSourceStore!.name,
      targetWarehouse: _selectedTargetStore!.name,
      postingDate: formattedDate,
      doNotSubmit: false,
      company: currentUserResponse!.message.company.name,
    );

    context.read<InventoryBloc>().add(CreateMaterialTransfer(request: request));
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
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
