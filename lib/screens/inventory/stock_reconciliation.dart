import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/inventory/stock_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/item_list.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

// Warehouse Model
class Warehouse {
  final String name;
  final String warehouseName;
  final String company;
  final String? warehouseType;
  final int isGroup;
  final String? parentWarehouse;
  final int disabled;
  final String? addressLine1;
  final String? city;
  final String? state;
  final bool isMainDepot;
  final bool isDefault;

  Warehouse({
    required this.name,
    required this.warehouseName,
    required this.company,
    this.warehouseType,
    required this.isGroup,
    this.parentWarehouse,
    required this.disabled,
    this.addressLine1,
    this.city,
    this.state,
    required this.isMainDepot,
    required this.isDefault,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      name: json['name'] ?? '',
      warehouseName: json['warehouse_name'] ?? '',
      company: json['company'] ?? '',
      warehouseType: json['warehouse_type'],
      isGroup: json['is_group'] ?? 0,
      parentWarehouse: json['parent_warehouse'],
      disabled: json['disabled'] ?? 0,
      addressLine1: json['address_line_1'],
      city: json['city'],
      state: json['state'],
      isMainDepot: json['is_main_depot'] ?? false,
      isDefault: json['is_default'] ?? false,
    );
  }
}

class StockReconciliationPage extends StatefulWidget {
  final String company;

  const StockReconciliationPage({super.key, required this.company});

  @override
  State<StockReconciliationPage> createState() =>
      _StockReconciliationPageState();
}

class _StockReconciliationPageState extends State<StockReconciliationPage> {
  String? selectedWarehouse;
  DateTime selectedDate = DateTime(2025, 12, 16);
  TimeOfDay selectedTime = TimeOfDay.now();

  // ...
  @override
  void dispose() {
    for (var item in items) {
      item.dispose();
    }
    super.dispose();
  }

  // Warehouse list from API
  List<Warehouse> warehouses = [];

  // Items from BLoC
  List<StockItem> stockItems = [];
  bool isLoadingItems = false;

  // Submission tracking
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
    const jsonData = {
      "message": {
        "success": true,
        "data": [
          {
            "name": "All Warehouses - SI",
            "warehouse_name": "All Warehouses",
            "company": "Sobetra International",
            "warehouse_type": null,
            "is_group": 1,
            "parent_warehouse": null,
            "disabled": 0,
            "address_line_1": null,
            "city": null,
            "state": null,
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
            "warehouse_type": null,
            "is_group": 0,
            "parent_warehouse": "All Warehouses - SI",
            "disabled": 0,
            "address_line_1": null,
            "city": null,
            "state": null,
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
            "address_line_1": null,
            "city": null,
            "state": null,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "Raw aterial Rice - SI",
            "warehouse_name": "Raw aterial Rice",
            "company": "Sobetra International",
            "warehouse_type": "Transit",
            "is_group": 0,
            "parent_warehouse": null,
            "disabled": 0,
            "address_line_1": null,
            "city": null,
            "state": null,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "SEEDER - SI",
            "warehouse_name": "SEEDER",
            "company": "Sobetra International",
            "warehouse_type": "Company Warehouse",
            "is_group": 0,
            "parent_warehouse": null,
            "disabled": 0,
            "address_line_1": null,
            "city": null,
            "state": null,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "Stores - SI",
            "warehouse_name": "Stores",
            "company": "Sobetra International",
            "warehouse_type": null,
            "is_group": 0,
            "parent_warehouse": "All Warehouses - SI",
            "disabled": 0,
            "address_line_1": null,
            "city": null,
            "state": null,
            "is_main_depot": false,
            "is_default": false,
          },
          {
            "name": "Work In Progress - SI",
            "warehouse_name": "Work In Progress",
            "company": "Sobetra International",
            "warehouse_type": null,
            "is_group": 0,
            "parent_warehouse": "All Warehouses - SI",
            "disabled": 0,
            "address_line_1": null,
            "city": null,
            "state": null,
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
    });
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Stock Reconciliation',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2196F3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('', style: TextStyle(color: Color(0xFF2196F3))),
            ),
          ),
        ],
      ),
      body: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ItemsStateSuccess) {
            setState(() {
              stockItems = state.stockItemResponse.data;
              isLoadingItems = false;
            });
          } else if (state is ProductsStateLoading) {
            setState(() {
              if (!isSubmitting) {
                isLoadingItems = true;
              }
            });
          } else if (state is ProductsStateFailure) {
            setState(() {
              isLoadingItems = false;
              if (isSubmitting) {
                failureCount++;
              }
            });

            if (isSubmitting) {
              // Check if all items are processed
              if (successCount + failureCount >= items.length) {
                _showCompletionDialog();
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load items: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is AddItemToStockSuccess) {
            setState(() {
              successCount++;
            });

            // Check if all items are processed
            if (successCount + failureCount >= items.length) {
              _showCompletionDialog();
            }
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
                    _buildWarehouseField(),
                    const SizedBox(height: 20),
                    _buildPostingDateField(),
                    const SizedBox(height: 20),
                    _buildPostingTimeField(),
                    const SizedBox(height: 30),
                    _buildItemsSection(),
                    const SizedBox(height: 80), // Extra space at bottom
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Warehouse',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedWarehouse,
          decoration: const InputDecoration(
            hintText: 'Choose a warehouse',
            hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          items: warehouses.map((warehouse) {
            return DropdownMenuItem(
              value: warehouse.name,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    warehouse.warehouseName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (warehouse.warehouseType != null)
                    Text(
                      warehouse.warehouseType!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF757575),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedWarehouse = value;
            });
          },
        ),
        if (selectedWarehouse != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildWarehouseInfo(),
          ),
      ],
    );
  }

  Widget _buildWarehouseInfo() {
    final warehouse = warehouses.firstWhere((w) => w.name == selectedWarehouse);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Text(
                warehouse.company,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          if (warehouse.addressLine1 != null || warehouse.city != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      warehouse.addressLine1,
                      warehouse.city,
                      warehouse.state,
                    ].where((e) => e != null && e.isNotEmpty).join(', '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostingDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Posting Date',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostingTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Posting Time',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Optional (HH:MM:SS)',
          style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (isLoadingItems) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Optional: Add inventory details (buying price, selling price, UOM, SKU, expiry, batch) to create / update warehouse-specific inventory details.',
          style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 16),
        _buildItemsTable(),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: stockItems.isEmpty ? null : _addItem,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Item'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(horizontal: 0),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 32,
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 220, // Item Code column width
                      child: Row(
                        children: const [
                          Text(
                            'Item Code',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120, // System Qty column width
                      child: const Text(
                        'System Qty',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120, // Physical Qty column width
                      child: Row(
                        children: const [
                          Text(
                            'Physical Qty',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120, // Difference column width
                      child: const Text(
                        'Difference',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120, // Valuation Rate column width
                      child: const Text(
                        'Valuation Rate',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Space for delete button
                  ],
                ),
              ),
              // Table Rows
              ...items.asMap().entries.map((entry) {
                return _buildItemRow(entry.key);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          // Item Code Dropdown
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              initialValue: items[index].itemCode,
              decoration: const InputDecoration(
                hintText: 'Select item',
                hintStyle: TextStyle(fontSize: 12),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              isExpanded: true,
              items: stockItems
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.name,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.itemName,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            '${item.itemCode} • ${item.stockUom}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF757575),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  final selectedItem = stockItems.firstWhere(
                    (item) => item.name == value,
                  );
                  setState(() {
                    items[index].itemCode = value;
                    items[index].itemName = selectedItem.itemName;
                    items[index].systemQty = selectedItem.stockQty;
                    items[index].stockUom = selectedItem.stockUom;
                    items[index].valuationRate = selectedItem.standardRate;
                    items[index].difference =
                        items[index].physicalQty - items[index].systemQty;
                  });
                }
              },
            ),
          ),

          // System Qty (Read-only)
          SizedBox(
            width: 120,
            child: Text(
              items[index].systemQty.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12),
            ),
          ),

          // Physical Qty (Editable)
          SizedBox(
            width: 120,
            child: TextField(
              controller: items[index].physicalQtyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onChanged: (value) {
                final physicalQty = double.tryParse(value) ?? 0;
                setState(() {
                  items[index].physicalQty = physicalQty;
                  items[index].difference =
                      physicalQty - items[index].systemQty;
                });
              },
            ),
          ),

          // Difference (Calculated)
          SizedBox(
            width: 120,
            child: Text(
              items[index].difference.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 12,
                color: items[index].difference == 0
                    ? Colors.black
                    : items[index].difference > 0
                    ? Colors.green
                    : Colors.red,
                fontWeight: items[index].difference != 0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),

          // Valuation Rate (Read-only)
          SizedBox(
            width: 120,
            child: Text(
              items[index].valuationRate.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12),
            ),
          ),

          // Delete Button
          SizedBox(
            width: 40,
            child: items.length > 1
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        items[index].dispose();
                        items.removeAt(index);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (_canSubmit() && !isSubmitting) ? _handleSubmit : null,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.add, size: 20),
              label: Text(
                isSubmitting ? 'Creating...' : 'Create',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                disabledForegroundColor: const Color(0xFF9E9E9E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
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
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Reset counters
    setState(() {
      isSubmitting = true;
      successCount = 0;
      failureCount = 0;
    });

    // Show loading dialog
    _showLoadingDialog();

    // Get company name
    final companyName =
        currentUserResponse?.message.company.name ?? widget.company;

    // Submit each item
    for (var item in items) {
      if (item.itemCode != null && selectedWarehouse != null) {
        final stockRequest = StockRequest(
          itemCode: item.itemCode!,
          warehouse: selectedWarehouse!,
          company: companyName,
        );

        // Dispatch the event
        context.read<ProductsBloc>().add(
          AddItemToStock(stockRequest: stockRequest),
        );
        // Add small delay between requests to avoid overwhelming the server
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
            Text(
              'Processing ${items.length} items...',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Success: $successCount | Failed: $failureCount',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    // Close loading dialog
    Navigator.of(context).pop();

    final bool allSuccess = failureCount == 0;

    setState(() {
      isSubmitting = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              allSuccess ? Icons.check_circle : Icons.warning,
              color: allSuccess ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              allSuccess ? 'Success' : 'Partially Completed',
              style: const TextStyle(fontSize: 18),
            ),
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
            Text(
              'Warehouse: $selectedWarehouse',
              style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
            ),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              if (allSuccess) {
                Navigator.pop(context); // Return to previous screen
              }
            },
            child: Text(allSuccess ? 'Done' : 'OK'),
          ),
          if (!allSuccess)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Reset for retry
                setState(() {
                  successCount = 0;
                  failureCount = 0;
                });
                _handleSubmit(); // Retry submission
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
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
}

class ItemRow {
  String? itemCode;
  String? itemName;
  double systemQty;
  double physicalQty;
  double difference;
  double valuationRate;
  String stockUom;
  late TextEditingController physicalQtyController;

  ItemRow({
    required this.itemCode,
    required this.itemName,
    required this.systemQty,
    required this.physicalQty,
    required this.difference,
    required this.valuationRate,
    required this.stockUom,
  }) {
    physicalQtyController = TextEditingController(
      text: physicalQty == 0 ? '' : physicalQty.toStringAsFixed(2),
    );
  }

  void dispose() {
    physicalQtyController.dispose();
  }
}
