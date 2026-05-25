import 'dart:async';
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
import 'package:pos/screens/inventory/widgets/stock_entry_form_widgets.dart';
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
                if (_stores.isNotEmpty) {
                  try {
                    final defaultStoreName = _stores
                        .firstWhere((store) => store.isDefault)
                        .name;

                    _selectedSourceStoreName ??= defaultStoreName;
                    _selectedTargetStoreName ??= defaultStoreName;
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
                    const _Label('Stock Entry Type'),
                    StockEntryTypeSelector(
                      selectedType: selectedType,
                      entryTypes: entryTypes,
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    StockEntryWarehouseSection(
                      selectedType: selectedType,
                      selectedSourceStoreName: _selectedSourceStoreName,
                      selectedTargetStoreName: _selectedTargetStoreName,
                      stores: _stores,
                      onSourceChanged: (val) => setState(() => _selectedSourceStoreName = val),
                      onTargetChanged: (val) => setState(() => _selectedTargetStoreName = val),
                    ),

                    const _Label('Posting Date*'),
                    _dateField(),
                    const SizedBox(height: 16),

                    const _Label('Posting Time'),
                    _timeField(),
                    const SizedBox(height: 20),

                    StockEntryItemsTable(
                      selectedType: selectedType,
                      items: items,
                      products: _products,
                      currentUserResponse: currentUserResponse,
                      onAddItem: () => setState(() => items.add(StockEntryItemModel())),
                      onRemoveItem: (index) => setState(() {
                        items[index].dispose();
                        items.removeAt(index);
                      }),
                      onStateChanged: () => setState(() {}),
                    ),
                  ],
                ),
              ),
              BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  final isLoading = state is CreateMaterialReceiptLoading ||
                      state is CreateMaterialIssueLoading ||
                      state is CreateMaterialTransferLoading;
                  return StockEntrySubmitActions(
                    isLoading: isLoading,
                    selectedType: selectedType,
                    onCancel: () => Navigator.pop(context),
                    onSubmit: _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
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

  void _submit() {
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

  String _formatErrorMessage(String message) {
    var coreMessage = message;
    
    if (coreMessage.startsWith('Error: ')) {
      coreMessage = coreMessage.substring(7);
    }
    
    if (coreMessage.contains('Valuation Rate for the Item')) {
      final itemMatch = RegExp(r'Valuation Rate for the Item (.*?), is required').firstMatch(coreMessage);
      if (itemMatch != null) {
        return 'Valuation Rate for Item ${itemMatch.group(1)}, is required,  please manage price at product  level';
      }
    }

    final regex = RegExp(r'\.([A-Z])|\. (Here|If|Please|You|Note)');
    final match = regex.firstMatch(coreMessage);
    
    if (match != null) {
      coreMessage = '${coreMessage.substring(0, match.start).trim()}.';
    }
    
    return coreMessage;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_formatErrorMessage(message)),
        backgroundColor: Colors.red,
        showCloseIcon: true,
      ),
    );
  }

  void _showSuccessAndPop(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
    Navigator.pop(context, true);
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
