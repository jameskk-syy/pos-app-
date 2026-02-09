import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class LowStockAlertPage extends StatelessWidget {
  const LowStockAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const _LowStockAlertPageContent());
  }
}

class _LowStockAlertPageContent extends StatefulWidget {
  const _LowStockAlertPageContent();

  @override
  State<_LowStockAlertPageContent> createState() =>
      _LowStockAlertPageContentState();
}

class _LowStockAlertPageContentState extends State<_LowStockAlertPageContent> {
  String? _selectedWarehouse;
  double? _thresholdValue;
  final TextEditingController _thresholdController = TextEditingController();
  CurrentUserResponse? currentUserResponse;
  List<Warehouse> _warehouses = [];

  @override
  void initState() {
    super.initState();
    _thresholdController.addListener(() {
      final text = _thresholdController.text;
      if (text.isNotEmpty) {
        _thresholdValue = double.tryParse(text);
      } else {
        _thresholdValue = null;
      }
    });
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

    context.read<StoreBloc>().add(
      GetAllStores(company: savedUser.message.company.name),
    );
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  void _refreshData() {
    context.read<InventoryBloc>().add(
      GetLowStock(
        warehouse: _selectedWarehouse,
        threshold: _thresholdValue,
        company: currentUserResponse?.message.company.name,
      ),
    );
  }

  void _showItemDetailsDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Item Details',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        icon: Icons.label,
                        label: 'Item Name',
                        value: item.itemName ?? 'N/A',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.warehouse,
                        label: 'Warehouse',
                        value: item.warehouse ?? 'N/A',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.inventory,
                        label: 'Current Stock',
                        value: item.actualQty?.toString() ?? 'N/A',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.category,
                        label: 'Item Code',
                        value: item.itemCode ?? 'N/A',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.inventory_2_outlined,
                        label: 'Reserved Qty',
                        value: item.reservedQty?.toString() ?? '0',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.trending_up,
                        label: 'Projected Qty',
                        value: item.projectedQty?.toString() ?? '0',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        icon: Icons.straighten,
                        label: 'Stock UOM',
                        value: item.stockUom ?? 'N/A',
                      ),
                      const SizedBox(height: 20),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Add your create receipt logic here
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Receipt'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 600;

    final horizontalController = ScrollController();
    final verticalController = ScrollController();

    // Responsive sizing
    final double titleFontSize = isSmall ? 18.0 : 22.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          "Low Stock Alert",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<InventoryBloc, InventoryState>(
            listener: (context, state) {
              if (state is ExportCSVSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ExportCSVError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<StoreBloc, StoreState>(
            listener: (context, state) {
              if (state is StoreStateSuccess) {
                setState(() {
                  _warehouses = state.storeGetResponse.message.data;
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
        ],
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  isSmall
                      ? Row(
                          children: [
                            Expanded(
                              child: _inputField(
                                hint: "Threshold",
                                icon: Icons.numbers,
                                controller: _thresholdController,
                                onChanged: (value) {
                                  _refreshData();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dropdownField(
                                hint: "Warehouse",
                                value: _selectedWarehouse,
                                warehouses: _warehouses,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWarehouse = value;
                                  });
                                  _refreshData();
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _inputField(
                                hint: "Threshold",
                                icon: Icons.numbers,
                                controller: _thresholdController,
                                onChanged: (value) {
                                  // The value is already handled by the controller listener
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _dropdownField(
                                hint: "Warehouse",
                                value: _selectedWarehouse,
                                warehouses: _warehouses,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWarehouse = value;
                                  });
                                  _refreshData();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _refreshData,
                            ),
                          ],
                        ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.blue.shade100),
                        ),
                        color: Colors.white,
                      ),
                      child: _buildTable(
                        state,
                        horizontalController,
                        verticalController,
                        isSmall,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTable(
    InventoryState state,
    ScrollController horizontalController,
    ScrollController verticalController,
    bool isSmall,
  ) {
    // Responsive sizing inside table
    final double baseFontSize = isSmall ? 12.0 : 14.0;
    final double headerFontSize = isSmall ? 13.0 : 15.0;
    if (state is LowStockLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LowStockError) {
      return Center(
        child: Text(
          'Error: ${state.message}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state is LowStockLoaded) {
      final stockItems = state.response.data ?? [];

      if (stockItems.isEmpty) {
        return const Center(
          child: Text(
            'No low stock items found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return Scrollbar(
        controller: horizontalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: horizontalController,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            controller: verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalController,
              scrollDirection: Axis.vertical,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: DataTable(
                  columnSpacing: isSmall ? 20 : 40,
                  headingRowHeight: isSmall ? 56 : 64,
                  dataRowMinHeight: isSmall ? 48 : 56,
                  columns: [
                    DataColumn(
                      label: Text(
                        "Item Name",
                        style: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Warehouse",
                        style: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Current Stock",
                        style: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Actions",
                        style: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  rows: stockItems.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item.itemName ?? 'N/A',
                            style: TextStyle(fontSize: baseFontSize),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.warehouse ?? 'N/A',
                            style: TextStyle(fontSize: baseFontSize),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.actualQty?.toString() ?? '0',
                              style: TextStyle(
                                fontSize: baseFontSize,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              size: isSmall ? 20 : 24,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              _showItemDetailsDialog(context, item);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Initial state or other states
    return const Center(child: CircularProgressIndicator());
  }

  Widget _inputField({
    required String hint,
    IconData? icon,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<Warehouse> warehouses,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text("All Warehouses")),
        ...warehouses.where((warehouse) => warehouse.disabled == 0).map((
          warehouse,
        ) {
          return DropdownMenuItem(
            value: warehouse.name,
            child: Text(
              warehouse.warehouseName,
              style: TextStyle(fontSize: 12),
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
