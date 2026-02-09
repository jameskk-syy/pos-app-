import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/create_discount_rule_request.dart';
import 'package:pos/domain/requests/update_discount_rule_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/models/inventory_discount_rule.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

import 'package:pos/domain/responses/products/item_group.dart';

class CreateDiscountRulePage extends StatefulWidget {
  final InventoryDiscountRule? existingRule;
  const CreateDiscountRulePage({super.key, this.existingRule});

  @override
  State<CreateDiscountRulePage> createState() => _CreateDiscountRulePageState();
}

class _CreateDiscountRulePageState extends State<CreateDiscountRulePage> {
  CurrentUserResponse? currentUserResponse;
  List<Warehouse> warehouses = [];
  List<ItemGroup> itemGroups = [];
  List<ProductItem> items = [];
  bool isLoading = true;
  bool loadingItemGroups = false;
  bool loadingItems = false;
  bool isSubmitting = false;

  String selectedRuleType = 'Item';
  String selectedDiscountType = 'Percentage';
  TextEditingController discountValueController = TextEditingController();
  TextEditingController priorityController = TextEditingController(text: '10');
  String? selectedWarehouse;
  DateTime? validFromDate;
  DateTime? validUptoDate;
  TextEditingController descriptionController = TextEditingController();
  bool isActive = true;

  String? selectedItem;
  TextEditingController batchNoController = TextEditingController();
  String? selectedItemGroup;

  @override
  void initState() {
    super.initState();
    if (widget.existingRule != null) {
      _initializeWithExistingRule();
    }
    _loadCurrentUser();
  }

  void _initializeWithExistingRule() {
    final rule = widget.existingRule!;
    selectedRuleType = rule.ruleType;
    selectedDiscountType = rule.discountType;
    discountValueController.text = rule.discountValue.toString();
    priorityController.text = rule.priority.toString();
    selectedWarehouse = rule.warehouse;
    isActive = rule.isActive == 1;
    descriptionController.text = rule.description ?? '';
    selectedItem = rule.itemCode;
    batchNoController.text = rule.batchNo ?? '';
    selectedItemGroup = rule.itemGroup;

    if (rule.validFrom != null) {
      validFromDate = DateTime.tryParse(rule.validFrom!);
    }
    if (rule.validUpto != null) {
      validUptoDate = DateTime.tryParse(rule.validUpto!);
    }
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

    _loadWarehouses();
    _loadItemGroups();
    _loadItems();
  }

  void _loadWarehouses() {
    if (currentUserResponse == null) return;
    context.read<StoreBloc>().add(
      GetAllStores(company: currentUserResponse!.message.company.name),
    );
  }

  void _loadItemGroups() {
    setState(() {
      loadingItemGroups = true;
    });
    context.read<ProductsBloc>().add(GetItemGroup());
  }

  void _loadItems() {
    if (currentUserResponse == null) {
      setState(() {
        loadingItems = false;
      });
      return;
    }

    setState(() {
      loadingItems = true;
    });

    context.read<ProductsBloc>().add(
      GetAllProducts(company: currentUserResponse!.message.company.name),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          validFromDate = picked;
        } else {
          validUptoDate = picked;
        }
      });
    }
  }

  void _createDiscountRule() {
    if (discountValueController.text.isEmpty) {
      _showError('Please enter discount value');
      return;
    }

    if (priorityController.text.isEmpty) {
      _showError('Please enter priority');
      return;
    }

    double discountValue = double.tryParse(discountValueController.text) ?? 0.0;
    if (discountValue <= 0) {
      _showError('Discount value must be greater than 0');
      return;
    }

    if (selectedDiscountType == 'Percentage' && discountValue > 100) {
      _showError('Percentage discount cannot exceed 100%');
      return;
    }

    if (selectedRuleType == 'Item' && selectedItem == null) {
      _showError('Please select an item');
      return;
    }

    if (selectedRuleType == 'Batch' && batchNoController.text.isEmpty) {
      _showError('Please enter batch number');
      return;
    }

    if (selectedRuleType == 'ItemGroup' && selectedItemGroup == null) {
      _showError('Please select an item group');
      return;
    }

    if (currentUserResponse == null) {
      _showError('User information not available');
      return;
    }

    String? warehouseValue;
    if (selectedWarehouse != null) {
      warehouseValue = selectedWarehouse;
    }

    if (widget.existingRule != null) {
      final request = UpdateDiscountRuleRequest(
        name: widget.existingRule!.name,
        ruleType: selectedRuleType,
        discountType: selectedDiscountType,
        discountValue: discountValue,
        priority: int.tryParse(priorityController.text) ?? 10,
        warehouse: warehouseValue,
        validFrom: validFromDate != null
            ? DateFormat('yyyy-MM-dd').format(validFromDate!)
            : null,
        validUpto: validUptoDate != null
            ? DateFormat('yyyy-MM-dd').format(validUptoDate!)
            : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        isActive: isActive ? 1 : 0,
        company: currentUserResponse!.message.company.name,
        itemCode: selectedRuleType == 'Item' ? selectedItem : null,
        batchNo: selectedRuleType == 'Batch' ? batchNoController.text : null,
        itemGroup: selectedRuleType == 'ItemGroup' ? selectedItemGroup : null,
      );

      context.read<InventoryBloc>().add(UpdateDiscountRule(request: request));
    } else {
      final request = CreateDiscountRuleRequest(
        ruleType: selectedRuleType,
        discountType: selectedDiscountType,
        discountValue: discountValue,
        priority: int.tryParse(priorityController.text) ?? 10,
        warehouse: warehouseValue,
        validFrom: validFromDate != null
            ? DateFormat('yyyy-MM-dd').format(validFromDate!)
            : null,
        validUpto: validUptoDate != null
            ? DateFormat('yyyy-MM-dd').format(validUptoDate!)
            : null,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        isActive: isActive ? 1 : 0,
        company: currentUserResponse!.message.company.name,
        itemCode: selectedRuleType == 'Item' ? selectedItem : null,
        batchNo: selectedRuleType == 'Batch' ? batchNoController.text : null,
        itemGroup: selectedRuleType == 'ItemGroup' ? selectedItemGroup : null,
      );

      context.read<InventoryBloc>().add(CreateDiscountRule(request: request));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
                warehouses = state.storeGetResponse.message.data;
                if (warehouses.isNotEmpty) {
                  selectedWarehouse = warehouses.first.name;
                }
              });
            } else if (state is StoreStateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load warehouses: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductsItemGroupsStateSuccess) {
              setState(() {
                itemGroups = state.itemGroupResponse.message.itemGroups;
                loadingItemGroups = false;
              });
            } else if (state is ProductsStateSuccess) {
              setState(() {
                items = state.productResponse.products
                    .where((product) => product.isActive && product.canBeSold)
                    .toList();
                loadingItems = false;
                if (itemGroups.isNotEmpty) {
                  isLoading = false;
                }
              });
            } else if (state is ProductsStateFailure) {
              if (state.error.contains('item groups')) {
                setState(() {
                  loadingItemGroups = false;
                });
              } else {
                setState(() {
                  loadingItems = false;
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is CreateDiscountRuleLoading ||
                state is UpdateDiscountRuleLoading) {
              setState(() {
                isSubmitting = true;
              });
            } else if (state is CreateDiscountRuleSuccess) {
              setState(() {
                isSubmitting = false;
              });
              final ruleName = state.response.message.data.name;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Discount rule created successfully: $ruleName',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is UpdateDiscountRuleSuccess) {
              setState(() {
                isSubmitting = false;
              });
              final ruleName = state.response.message.data.name;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Discount rule updated successfully: $ruleName',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is CreateDiscountRuleError) {
              setState(() {
                isSubmitting = false;
              });
              _showError('Failed to create discount rule: ${state.message}');
            } else if (state is UpdateDiscountRuleError) {
              setState(() {
                isSubmitting = false;
              });
              _showError('Failed to update discount rule: ${state.message}');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.existingRule != null
                ? "Edit Discount Rule"
                : "Create Discount Rule",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1976F3),
                              width: 0.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rule Configuration',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976F3),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Rule Type *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment<String>(
                                    value: 'Item',
                                    label: Text('Item'),
                                    icon: Icon(Icons.category, size: 18),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'Batch',
                                    label: Text('Batch'),
                                    icon: Icon(Icons.inventory, size: 18),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'ItemGroup',
                                    label: Text(
                                      'Item Group',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    icon: Icon(Icons.group_work, size: 18),
                                  ),
                                ],
                                selected: {selectedRuleType},
                                onSelectionChanged: (Set<String> newSelection) {
                                  setState(() {
                                    selectedRuleType = newSelection.first;
                                    selectedItem = null;
                                    batchNoController.clear();
                                    selectedItemGroup = null;
                                    if (selectedRuleType == 'Item' &&
                                        items.isEmpty) {
                                      _loadItems();
                                    }
                                  });
                                },
                                style: SegmentedButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  selectedBackgroundColor: const Color(
                                    0xFF1976F3,
                                  ),
                                  selectedForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Priority: Batch → Item → Item Group (most specific first)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (selectedRuleType == 'Item') ...[
                                const Text(
                                  'Item *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                loadingItems
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Loading items...',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedItem,
                                            isExpanded: true,
                                            hint: const Text('Select Item'),
                                            items: items.map((item) {
                                              return DropdownMenuItem<String>(
                                                value: item.itemCode,
                                                child: Text(
                                                  '${item.itemCode} - ${item.itemName}',
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedItem = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                              ],
                              if (selectedRuleType == 'Batch') ...[
                                const Text(
                                  'Batch Number *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: batchNoController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter batch number',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                              if (selectedRuleType == 'ItemGroup') ...[
                                const Text(
                                  'Item Group *',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                loadingItemGroups
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Loading item groups...',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedItemGroup,
                                            isExpanded: true,
                                            hint: const Text(
                                              'Select Item Group',
                                            ),
                                            items: itemGroups.map((group) {
                                              return DropdownMenuItem<String>(
                                                value: group.name,
                                                child: Text(
                                                  group.itemGroupName,
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedItemGroup = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                              ],
                              const SizedBox(height: 24),
                              const Text(
                                'Discount Type *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment<String>(
                                    value: 'Percentage',
                                    label: Text('Percentage'),
                                    icon: Icon(Icons.percent, size: 18),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'Amount',
                                    label: Text('Fixed Amount'),
                                    icon: Icon(Icons.money, size: 18),
                                  ),
                                ],
                                selected: {selectedDiscountType},
                                onSelectionChanged: (Set<String> newSelection) {
                                  setState(() {
                                    selectedDiscountType = newSelection.first;
                                    discountValueController.clear();
                                  });
                                },
                                style: SegmentedButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  selectedBackgroundColor: const Color(
                                    0xFF1976F3,
                                  ),
                                  selectedForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Discount ${selectedDiscountType == 'Percentage' ? 'Percentage' : 'Amount'} *',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (selectedDiscountType == 'Percentage')
                                    const Text(
                                      '(0-100%)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: discountValueController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText:
                                          selectedDiscountType == 'Percentage'
                                          ? '0'
                                          : '0.00',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: Text(
                                          selectedDiscountType == 'Percentage'
                                              ? '%'
                                              : 'KES',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Priority',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: priorityController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: '10',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Icon(
                                          Icons.low_priority,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Lower number = higher priority',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Warehouse (Optional)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedWarehouse,
                                        isExpanded: true,
                                        hint: const Text('Select Warehouse'),
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('All Warehouses'),
                                          ),
                                          ...warehouses.map((warehouse) {
                                            return DropdownMenuItem<String>(
                                              value: warehouse.name,
                                              child: Text(
                                                '${warehouse.name} - ${warehouse.warehouseName}',
                                              ),
                                            );
                                          }),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedWarehouse = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Leave empty to apply to all warehouses',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1976F3),
                              width: 0.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Additional Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976F3),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Validity Period (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () =>
                                              _selectDate(context, true),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  validFromDate != null
                                                      ? DateFormat(
                                                          'MM/dd/yyyy',
                                                        ).format(validFromDate!)
                                                      : 'mm/dd/yyyy',
                                                  style: TextStyle(
                                                    color: validFromDate != null
                                                        ? Colors.black
                                                        : Colors.grey[400],
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 20,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () =>
                                              _selectDate(context, false),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  validUptoDate != null
                                                      ? DateFormat(
                                                          'MM/dd/yyyy',
                                                        ).format(validUptoDate!)
                                                      : 'mm/dd/yyyy',
                                                  style: TextStyle(
                                                    color: validUptoDate != null
                                                        ? Colors.black
                                                        : Colors.grey[400],
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 20,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Leave empty for unlimited validity',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Description (Optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: descriptionController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText:
                                      'Add notes or comments about this rule',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Rule Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isActive ? Colors.green : Colors.red,
                                  ),
                                ),
                                value: isActive,
                                onChanged: (value) {
                                  setState(() {
                                    isActive = value;
                                  });
                                },
                                activeThumbColor: const Color(0xFF1976F3),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Active rules will be applied',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : _createDiscountRule,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSubmitting
                                    ? Colors.grey[400]
                                    : const Color(0xFF1976F3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      widget.existingRule != null
                                          ? 'Update Rule'
                                          : 'Create Rule',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
