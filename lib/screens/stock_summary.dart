import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/stock_summary_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockSummaryPage extends StatefulWidget {
  const StockSummaryPage({super.key});

  @override
  State<StockSummaryPage> createState() => _StockSummaryPageState();
}

class _StockSummaryPageState extends State<StockSummaryPage> {
  CurrentUserResponse? currentUserResponse;
  late InventoryBloc inventoryBloc;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedWarehouse;
  String? _selectedItemGroup;
  bool _isFiltersExpanded = true;
  List<String> warehouseList = [];
  List<String> itemGroupList = [];

  @override
  void initState() {
    super.initState();
    inventoryBloc = getIt<InventoryBloc>();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    inventoryBloc.close();
    _searchController.dispose();
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

    // Load stock summary on init
    inventoryBloc.add(
      GetStockSummary(
        company: savedUser.message.company.name,
        limit: 100,
        offset: 0,
      ),
    );
  }

  void _fetchWarehouses() {
    if (currentUserResponse == null) return;
    context.read<StoreBloc>().add(
      GetAllStores(company: currentUserResponse!.message.company.companyName),
    );
  }

  void _extractItemGroups(List<StockSummaryItem> items) {
    try {
      final groups = items.map((item) => item.itemGroup).toSet().toList();
      setState(() {
        itemGroupList = groups;
      });
    } catch (e) {
      setState(() {
        itemGroupList = [];
      });
    }
  }

  void _loadStockSummary() {
    if (currentUserResponse == null) return;
    inventoryBloc.add(
      GetStockSummary(
        company: currentUserResponse!.message.company.name,
        limit: 100,
        offset: 0,
        warehouse: _selectedWarehouse,
        itemGroup: _selectedItemGroup,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedWarehouse = null;
      _selectedItemGroup = null;
    });
    _loadStockSummary();
  }

  void _showItemDetails(StockSummaryItem item) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item.itemName,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow("Item Code:", item.itemCode, context),
              _detailRow("Item Group:", item.itemGroup, context),
              _detailRow("Warehouse:", item.warehouse, context),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                "Stock Details:",
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _detailRow(
                "Actual QTY:",
                "${item.actualQty.toStringAsFixed(2)} ${item.stockUom}",
                context,
              ),
              _detailRow(
                "Reserved QTY:",
                "${item.reservedQty.toStringAsFixed(2)} ${item.stockUom}",
                context,
              ),
              _detailRow(
                "Ordered QTY:",
                "${item.orderedQty.toStringAsFixed(2)} ${item.stockUom}",
                context,
              ),
              _detailRow(
                "Projected QTY:",
                "${item.projectedQty.toStringAsFixed(2)} ${item.stockUom}",
                context,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                "Financial Details:",
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _detailRow(
                "Stock Value:",
                "\$${item.stockValue.toStringAsFixed(2)}",
                context,
              ),
              _detailRow(
                "Valuation Rate:",
                "\$${item.valuationRate.toStringAsFixed(2)}",
                context,
              ),
              _detailRow("Unit of Measure:", item.stockUom, context),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 3 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 100 : 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return InputDecoration(
      hintText: hint,
      isDense: true,
      hintStyle: TextStyle(
        fontSize: isMobile ? 13 : 14,
        color: Colors.grey[600],
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 12 : 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
      ),
    );
  }

  Widget _input(String label, Widget field, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final double padding = isMobile ? 12.0 : 16.0;

    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              try {
                final warehouses = state.storeGetResponse.message.data;
                setState(() {
                  warehouseList = warehouses
                      .where((wh) => wh.disabled == 0)
                      .map((wh) => wh.warehouseName)
                      .toList();

                  warehouseList.insert(0, "All Warehouses");
                });
              } catch (e) {
                setState(() {
                  warehouseList = ["All Warehouses"];
                });
              }
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is StockSummaryLoaded) {
              try {
                _extractItemGroups(state.response.data);
              } catch (e) {
                debugPrint('Error in StockSummaryLoaded listener: $e');
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Stock Summary",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: isMobile ? 8 : 16),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download, size: isMobile ? 16 : 18),
                label: Text(
                  "Export CSV",
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 8 : 10,
                  ),
                ),
              ),
            ),
          ],
        ),

        body: BlocConsumer<InventoryBloc, InventoryState>(
          bloc: inventoryBloc,
          listener: (context, state) {
            if (state is StockSummaryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            List<StockSummaryItem> items = [];
            bool isLoading = false;
            String? errorMessage;

            if (state is StockSummaryLoading) {
              isLoading = true;
            } else if (state is StockSummaryError) {
              errorMessage = state.message;
            } else if (state is StockSummaryLoaded) {
              try {
                items = state.response.data;
                if (warehouseList.isEmpty) {
                  _fetchWarehouses();
                }
              } catch (e) {
                errorMessage = 'Error loading data';
              }
            }

            // Show loading or error state
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error: $errorMessage',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadStockSummary,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  // Filters Section - Collapsible
                  Container(
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter Header with Collapse Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Filters",
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isFiltersExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: isMobile ? 18 : 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isFiltersExpanded = !_isFiltersExpanded;
                                });
                              },
                            ),
                          ],
                        ),

                        // Filter Content (Collapsible)
                        if (_isFiltersExpanded) ...[
                          SizedBox(height: isMobile ? 12 : 16),

                          // First Row: 2 filters
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search Field
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: isMobile ? 6.0 : 8.0,
                                  ),
                                  child: _input(
                                    "Search Items",
                                    TextField(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          _loadStockSummary();
                                        }
                                      },
                                      onSubmitted: (_) => _loadStockSummary(),
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      decoration:
                                          _decoration(
                                            "Search items",
                                            context,
                                          ).copyWith(
                                            prefixIcon: Icon(
                                              Icons.search,
                                              size: isMobile ? 18 : 20,
                                              color: Colors.grey[600],
                                            ),
                                            suffixIcon:
                                                _searchController
                                                    .text
                                                    .isNotEmpty
                                                ? IconButton(
                                                    icon: Icon(
                                                      Icons.clear,
                                                      size: isMobile ? 16 : 18,
                                                    ),
                                                    onPressed: () {
                                                      _searchController.clear();
                                                      _loadStockSummary();
                                                    },
                                                  )
                                                : null,
                                          ),
                                    ),
                                    context,
                                  ),
                                ),
                              ),

                              // Warehouse Dropdown
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: isMobile ? 6.0 : 8.0,
                                  ),
                                  child: _input(
                                    "Warehouse",
                                    DropdownButtonFormField<String?>(
                                      isExpanded: true,
                                      initialValue: _selectedWarehouse,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      decoration: _decoration(
                                        "Warehouse",
                                        context,
                                      ),
                                      items: [
                                        DropdownMenuItem<String?>(
                                          value: null,
                                          child: Text(
                                            "All Warehouses",
                                            style: TextStyle(
                                              fontSize: isMobile ? 13 : 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        ...(warehouseList.isNotEmpty
                                            ? warehouseList
                                                  .where(
                                                    (wh) =>
                                                        wh != "All Warehouses",
                                                  )
                                                  .map((wh) {
                                                    return DropdownMenuItem<
                                                      String?
                                                    >(
                                                      value: wh,
                                                      child: Text(
                                                        wh,
                                                        style: TextStyle(
                                                          fontSize: isMobile
                                                              ? 13
                                                              : 14,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    );
                                                  })
                                                  .toList()
                                            : []),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedWarehouse = value;
                                        });
                                        _loadStockSummary();
                                      },
                                    ),
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isMobile ? 12 : 16),

                          // Second Row: Item Group Dropdown
                          _input(
                            "Item Group",
                            DropdownButtonFormField<String?>(
                              isExpanded: true,
                              initialValue: _selectedItemGroup,
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                color: Colors.black,
                              ),
                              decoration: _decoration("Select Group", context),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    "All Groups",
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                ...(itemGroupList.isNotEmpty
                                    ? itemGroupList.map((group) {
                                        return DropdownMenuItem<String?>(
                                          value: group,
                                          child: Text(
                                            group,
                                            style: TextStyle(
                                              fontSize: isMobile ? 13 : 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList()
                                    : []),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedItemGroup = value;
                                });
                                _loadStockSummary();
                              },
                            ),
                            context,
                          ),

                          SizedBox(height: isMobile ? 16 : 20),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Reset Filters Button
                              OutlinedButton(
                                onPressed: _clearFilters,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 16 : 20,
                                    vertical: isMobile ? 10 : 14,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clear_all,
                                      color: Colors.red,
                                      size: isMobile ? 16 : 18,
                                    ),
                                    SizedBox(width: isMobile ? 6 : 8),
                                    Text(
                                      "Clear Filters",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: isMobile ? 12 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: isMobile ? 8 : 12),

                              // Apply Filters Button
                              ElevatedButton(
                                onPressed: _loadStockSummary,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 16 : 20,
                                    vertical: isMobile ? 10 : 14,
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Apply Filters",
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: isMobile ? 16 : 20),

                  Padding(
                    padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items: ${items.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                        Text(
                          'Showing: ${items.length} items',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: isMobile ? 48 : 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  Text(
                                    'No items found',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 8 : 12),
                                  Text(
                                    'Try adjusting your filters',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _buildDataTable(items, context),
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

  Widget _buildDataTable(List<StockSummaryItem> items, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Header Row
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Item Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 16),
              Expanded(
                flex: 2,
                child: Text(
                  "Actual QTY",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 4 : 8),
              Container(
                width: isMobile ? 40 : 48,
                alignment: Alignment.center,
                child: Text(
                  "Action",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Data Rows
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    // Item Name
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.itemName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? 13 : 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isMobile ? 2 : 4),
                          Text(
                            item.itemCode,
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: isMobile ? 8 : 16),

                    // Quantity
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.actualQty.toStringAsFixed(2),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 13 : 14,
                            ),
                          ),
                          SizedBox(height: isMobile ? 2 : 4),
                          Text(
                            item.stockUom,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: isMobile ? 4 : 8),

                    // View Action
                    SizedBox(
                      width: isMobile ? 40 : 48,
                      child: IconButton(
                        icon: Icon(
                          Icons.remove_red_eye,
                          size: isMobile ? 18 : 20,
                          color: Colors.blue,
                        ),
                        onPressed: () => _showItemDetails(item),
                        tooltip: 'View Details',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
