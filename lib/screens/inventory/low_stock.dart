import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/inventory/material_receipt.dart';

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
    if (_thresholdValue == null) return;

    context.read<InventoryBloc>().add(
      GetLowStock(
        warehouse: _selectedWarehouse,
        threshold: _thresholdValue,
        company: currentUserResponse?.message.company.name,
      ),
    );
  }

  void _showItemDetailsDialog(BuildContext context, dynamic item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isMobile = screenWidth < 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          insetPadding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24)
              : const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? screenWidth * 0.95 : 1200,
              maxHeight: screenHeight * (isMobile ? 0.85 : 0.85),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        color: Colors.black,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Item Details',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MaterialReceiptPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Create Receipt',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
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
                                isSmall: isSmall,
                                onChanged: (value) {
                                  _refreshData();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dropdownField(
                                hint: "Warehouse",
                                selectedValue: _selectedWarehouse,
                                warehouses: _warehouses,
                                isSmall: isSmall,
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
                                isSmall: isSmall,
                                onChanged: (value) {
                                  // The value is already handled by the controller listener
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _dropdownField(
                                hint: "Warehouse",
                                selectedValue: _selectedWarehouse,
                                warehouses: _warehouses,
                                isSmall: isSmall,
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

    if (_thresholdValue == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Enter a threshold to view low stock items',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

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
    required bool isSmall,
    required Function(String) onChanged,
  }) {
    final double fontSize = isSmall ? 13.0 : 15.0;
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: hint,
        hintStyle: TextStyle(fontSize: fontSize),
        prefixIcon: icon != null ? Icon(icon, size: isSmall ? 18 : 22) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? selectedValue,
    required List<Warehouse> warehouses,
    required bool isSmall,
    required Function(String?) onChanged,
  }) {
    final double fontSize = isSmall ? 13.0 : 15.0;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedValue,
      style: TextStyle(fontSize: fontSize, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: fontSize),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(
            "All Warehouses",
            style: TextStyle(fontSize: fontSize),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...warehouses.where((warehouse) => warehouse.disabled == 0).map((
          warehouse,
        ) {
          return DropdownMenuItem(
            value: warehouse.name,
            child: Text(
              warehouse.warehouseName,
              style: TextStyle(fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
