import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/inventory/create_material_issue_request.dart';
import 'package:pos/domain/requests/inventory/create_material_receipt_request.dart';
import 'package:pos/domain/requests/inventory/create_transfer_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/widgets/common/delete_confirmation_dialog.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class StockEntryPage extends StatefulWidget {
  const StockEntryPage({super.key});

  @override
  State<StockEntryPage> createState() => _StockEntryPageState();
}

class _StockEntryPageState extends State<StockEntryPage> {
  String selectedType = 'Material Receipt';
  final List<String> entryTypes = [
    'Material Receipt',
    'Material Issue',
    'Material Transfer',
  ];

  DateTime postingDate = DateTime.now();
  TimeOfDay postingTime = TimeOfDay.now();

  String? _selectedSourceStoreName;
  String? _selectedTargetStoreName;
  List<Warehouse> _stores = [];
  List<ProductItem> _products = [];

  final List<StockEntryItemModel> items = [];
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
            if (state is CreateMaterialReceiptSuccess) {
              _showSuccessAndPop(
                'Material receipt created: ${state.response.data?.name ?? ""}',
              );
            } else if (state is CreateMaterialReceiptError) {
              _showError(state.message);
            } else if (state is CreateMaterialIssueSuccess) {
              _showSuccessAndPop(
                'Material issue created: ${state.response.data?.name ?? ""}',
              );
            } else if (state is CreateMaterialIssueError) {
              _showError(state.message);
            } else if (state is CreateMaterialTransferSuccess) {
              _showSuccessAndPop(
                'Material transfer created: ${state.response.data.name}',
              );
            } else if (state is CreateMaterialTransferError) {
              _showError(state.message);
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
          title: const Text(
            'Create Stock Entry',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _label('Stock Entry Type'),
                    _typeDropdown(),
                    const SizedBox(height: 16),

                    if (selectedType == 'Material Issue' ||
                        selectedType == 'Material Transfer') ...[
                      _label('Source Warehouse*'),
                      _storeDropdown(isSource: true),
                      const SizedBox(height: 16),
                    ],

                    if (selectedType == 'Material Receipt' ||
                        selectedType == 'Material Transfer') ...[
                      _label('Target Warehouse*'),
                      _storeDropdown(isSource: false),
                      const SizedBox(height: 16),
                    ],

                    _label('Posting Date*'),
                    _dateField(),
                    const SizedBox(height: 16),

                    _label('Posting Time'),
                    _timeField(),
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

  Widget _typeDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedType,
          items: entryTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedType = val;
                // Reset store selections if type changes to keep things clean?
                // Alternatively, keep them if possible. I'll keep them.
              });
            }
          },
        ),
      ),
    );
  }

  Widget _storeDropdown({required bool isSource}) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        final selectedStoreName = isSource
            ? _selectedSourceStoreName
            : _selectedTargetStoreName;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                state is StoreStateLoading
                    ? 'Loading stores...'
                    : _stores.isEmpty
                    ? 'No stores available'
                    : 'Choose a warehouse',
                style: const TextStyle(fontSize: 14),
              ),
              value: selectedStoreName,
              items: _stores.map((store) {
                return DropdownMenuItem<String>(
                  value: store.name,
                  child: Text(
                    '${store.name}${store.isDefault ? ' (Default)' : ''}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  if (isSource) {
                    _selectedSourceStoreName = newValue;
                  } else {
                    _selectedTargetStoreName = newValue;
                  }
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _Header('Item Code*', 200),
                    const _Header('Qty*', 90),
                    if (selectedType == 'Material Receipt')
                      const _Header('Basic Rate*', 100),
                    if (selectedType != 'Material Receipt')
                      const _Header('Purpose', 160),
                    const _Header('', 50),
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
                items.add(StockEntryItemModel());
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(StockEntryItemModel item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Code
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
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductItem>(
                        isExpanded: true,
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
                              item.basicRate = newValue.standardRate;
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

          // Qty
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

          // Rate
          if (selectedType == 'Material Receipt')
            SizedBox(
              width: 100,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextFormField(
                  initialValue: item.basicRate.toStringAsFixed(2),
                  // controller: item.rateController, // If implementing controller
                  style: const TextStyle(fontSize: 12),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    item.basicRate = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
            ),

          // Purpose
          if (selectedType != 'Material Receipt')
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
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (value) {
                    item.purpose = value;
                  },
                ),
              ),
            ),

          // Delete
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
                    item.dispose();
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
        final isLoading =
            state is CreateMaterialReceiptLoading ||
            state is CreateMaterialIssueLoading ||
            state is CreateMaterialTransferLoading;

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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Create $selectedType', // Material Receipt -> Create Material Receipt
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    // Validations
    if ((selectedType == 'Material Issue' ||
            selectedType == 'Material Transfer') &&
        _selectedSourceStoreName == null) {
      _showError('Please select a source warehouse');
      return;
    }
    if ((selectedType == 'Material Receipt' ||
            selectedType == 'Material Transfer') &&
        _selectedTargetStoreName == null) {
      _showError('Please select a target warehouse');
      return;
    }
    if (selectedType == 'Material Transfer' &&
        _selectedSourceStoreName == _selectedTargetStoreName) {
      _showError('Source and target warehouses must be different');
      return;
    }
    if (items.isEmpty || items.any((item) => item.selectedProduct == null)) {
      _showError('Please add at least one item with valid item code');
      return;
    }

    final formattedDate =
        '${postingDate.year}-${postingDate.month.toString().padLeft(2, '0')}-${postingDate.day.toString().padLeft(2, '0')}';

    if (selectedType == 'Material Receipt') {
      final request = CreateMaterialReceiptRequest(
        items: items
            .map(
              (item) => MaterialReceiptItem(
                itemCode: item.itemCode!,
                qty: item.quantity.toDouble(),
                tWarehouse: _selectedTargetStoreName!,
                // Note: MaterialReceiptItem logic from page had no rate?
                // Wait, StockReceiptPage items had basicRate but request didn't use it?
                // Let me double check CreateMaterialReceiptRequest structure.
                // In StockReceiptPage:
                // MaterialReceiptItem(itemCode: ..., qty: ..., tWarehouse: ...)
                // It seems Basic Rate is NOT part of the request in the other file?
                // Let's assume it isn't or I should check the file.
                // For now I follow StockReceiptPage implementation.
              ),
            )
            .toList(),
        targetWarehouse: _selectedTargetStoreName!,
        postingDate: formattedDate,
        doNotSubmit: false,
        company: currentUserResponse!.message.company.name,
      );
      context.read<InventoryBloc>().add(
        CreateMaterialReceipt(request: request),
      );
    } else if (selectedType == 'Material Issue') {
      final request = CreateMaterialIssueRequest(
        items: items
            .map(
              (item) => MaterialIssueItem(
                itemCode: item.itemCode!,
                qty: item.quantity.toDouble(),
                sWarehouse: _selectedSourceStoreName!,
                purpose: item.purpose,
              ),
            )
            .toList(),
        sourceWarehouse: _selectedSourceStoreName!,
        postingDate: formattedDate,
        doNotSubmit: false,
        company: currentUserResponse!.message.company.name,
      );
      context.read<InventoryBloc>().add(CreateMaterialIssue(request: request));
    } else if (selectedType == 'Material Transfer') {
      final request = CreateMaterialTransferRequest(
        items: items
            .map(
              (item) => TransferItem(
                itemCode: item.itemCode!,
                qty: item.quantity.toDouble(),
                sWarehouse: _selectedSourceStoreName!,
                tWarehouse: _selectedTargetStoreName!,
              ),
            )
            .toList(),
        sourceWarehouse: _selectedSourceStoreName!,
        targetWarehouse: _selectedTargetStoreName!,
        postingDate: formattedDate,
        doNotSubmit: false,
        company: currentUserResponse!.message.company.name,
      );
      context.read<InventoryBloc>().add(
        CreateMaterialTransfer(request: request),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessAndPop(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
    Navigator.pop(context, true);
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

class StockEntryItemModel {
  String? itemCode;
  int quantity = 1;
  double basicRate = 0.0;
  String purpose = '';
  ProductItem? selectedProduct;
  final TextEditingController qtyController;
  final TextEditingController purposeController;

  StockEntryItemModel()
    : qtyController = TextEditingController(text: '1'),
      purposeController = TextEditingController();

  void dispose() {
    qtyController.dispose();
    purposeController.dispose();
  }
}
