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
import 'package:pos/widgets/common/delete_confirmation_dialog.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

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
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Stock Transfer',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            actions: [
              // TextButton(onPressed: () {}, child: const Text('View History')),
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
                      _label('Transaction Date*'),
                      _dateField(isSchedule: false),
                      const SizedBox(height: 16),
                      _label('Schedule Date*'),
                      _dateField(isSchedule: true),
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
              child: Text(
                '${store.warehouseName}${store.isDefault ? ' (Default)' : ''}',
                style: const TextStyle(fontSize: 14),
              ),
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

  Widget _dateField({required bool isSchedule}) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: isSchedule ? scheduleDate : postingDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) {
          setState(() {
            if (isSchedule) {
              scheduleDate = picked;
            } else {
              postingDate = picked;
            }
          });
        }
      },
      child: _inputBox(
        isSchedule
            ? '${scheduleDate.day}/${scheduleDate.month}/${scheduleDate.year}'
            : '${postingDate.day}/${postingDate.month}/${postingDate.year}',
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Code Dropdown
          SizedBox(
            width: 200,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductItem>(
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        hint: Text(
                          state is ProductsStateLoading
                              ? 'Loading...'
                              : _products.isEmpty
                              ? 'No items'
                              : 'Select Item',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: item.selectedProduct,
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Quantity field
          SizedBox(
            width: 90,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: item.qtyController,
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: item.purposeController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  hintText: 'Purpose',
                  hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
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
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                final confirmed = await DeleteConfirmationDialog.show(context);
                if (confirmed == true) {
                  setState(() {
                    items[index].dispose();
                    items.removeAt(index);
                  });
                }
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
        final isLoading = state is CreateStockTransferLoading;

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

    // Format dates
    final formattedTransactionDate =
        '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';

    final formattedScheduleDate =
        '${scheduleDate.year}-${scheduleDate.month.toString().padLeft(2, '0')}-${scheduleDate.day.toString().padLeft(2, '0')}';

    // Create the new stock transfer request
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

    // Dispatch the new event
    context.read<InventoryBloc>().add(CreateStockTransfer(request: request));
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
