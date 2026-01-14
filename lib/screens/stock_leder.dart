import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/stock_ledger_entry.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockLedgerDetailsPage extends StatefulWidget {
  const StockLedgerDetailsPage({super.key});

  @override
  State<StockLedgerDetailsPage> createState() => _StockLedgerDetailsPageState();
}

class _StockLedgerDetailsPageState extends State<StockLedgerDetailsPage> {
  String? selectedVoucherType;
  String? selectedWarehouse;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedStatus;
  bool _isFiltersExpanded = true;
  Timer? _debounceTimer;

  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<String> voucherTypes = [
    "",
    "Sales Invoice",
    "Stock Entry",
    "Purchase Receipt",
    "Delivery Note",
    "Material Issue",
    "Material Transfer",
  ];
  CurrentUserResponse? currentUserResponse;
  final List<String> statusOptions = ["All", "Draft", "Submitted", "Cancelled"];
  List<Warehouse> warehouseList = [];
  List<String> warehouseNames = [];

  @override
  void initState() {
    super.initState();
    selectedVoucherType = voucherTypes.first;
    selectedStatus = statusOptions.first;
    _loadCurrentUser();
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
  
    _fetchWarehouses();
    _loadStockEntries();
  }

  void _fetchWarehouses() {
    if (currentUserResponse == null) return;
    
    context.read<StoreBloc>().add(
      GetAllStores(
        company: currentUserResponse!.message.company.companyName,
      ),
    );
  }

  void _loadStockEntries() {
    if (currentUserResponse == null) return;
    
    context.read<InventoryBloc>().add(
      GetStockLedger(
        company: currentUserResponse!.message.company.companyName,
        warehouse: selectedWarehouse ?? _getDefaultWarehouseName(),
        voucherType: selectedVoucherType,
        limit: 20,
        offset: 0,
      ),
    );
  }

  String _getDefaultWarehouseName() {
    if (currentUserResponse == null) return "VBU";
    
    final defaultWarehouseFromUser = currentUserResponse!.message.defaultWarehouse;
    if (warehouseNames.contains(defaultWarehouseFromUser)) {
      return defaultWarehouseFromUser;
    }
    final matchingWarehouse = warehouseList.firstWhere(
      (wh) => wh.name == defaultWarehouseFromUser,
      orElse: () => Warehouse(
        name: '',
        warehouseName: '',
        company: '',
        isGroup: 0,
        disabled: 0,
        isMainDepot: false,
        isDefault: false,
      ),
    );
    
    return matchingWarehouse.warehouseName.isNotEmpty 
        ? matchingWarehouse.warehouseName 
        : (warehouseNames.isNotEmpty ? warehouseNames.first : "VBU - VB");
  }

  void _resetFilters() {
    setState(() {
      selectedVoucherType = voucherTypes.first;
      selectedWarehouse = _getDefaultWarehouseName();
      fromDate = null;
      toDate = null;
      selectedStatus = statusOptions.first;
      _fromDateController.clear();
      _toDateController.clear();
    });
    _loadStockEntries();
  }

  void _onFilterChanged() {
    // Debounce to avoid too many API calls
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadStockEntries();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          _fromDateController.text =
              "${picked.day}/${picked.month}/${picked.year}";
        } else {
          toDate = picked;
          _toDateController.text =
              "${picked.day}/${picked.month}/${picked.year}";
        }
      });
      _onFilterChanged();
    }
  }

  InputDecoration _decoration(String hint, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: isMobile ? 13 : 14,
        color: Colors.grey[600],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isMobile ? 12 : 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: .8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: .8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1),
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

  DataRow _buildStockEntryRow(StockLedgerEntry entry, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.voucherNo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.itemCode,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: entry.voucherType == "Stock Entry"
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.voucherType,
              style: TextStyle(
                color: entry.voucherType == "Stock Entry"
                    ? const Color(0xFF166534)
                    : const Color(0xFF92400E),
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.postingDate,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.postingTime.split('.')[0],
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            entry.warehouse,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.black,
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              Text(
                "${entry.actualQty > 0 ? '+' : ''}${entry.actualQty.toInt()}",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: entry.actualQty > 0
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                ),
              ),
              
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_red_eye, size: isMobile ? 16 : 18),
                onPressed: () {
                  _showEntryDetails(entry, context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEntryDetails(StockLedgerEntry entry, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Stock Entry Details",
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            color: Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow("Voucher No:", entry.voucherNo, context),
              _detailRow("Item Code:", entry.itemCode, context),
              _detailRow("Warehouse:", entry.warehouse, context),
              _detailRow("Voucher Type:", entry.voucherType, context),
              _detailRow("Posting Date:", entry.postingDate, context),
              _detailRow("Posting Time:", entry.postingTime, context),
              _detailRow("Actual Qty:", entry.actualQty.toString(), context),
              _detailRow(
                "Qty After Transaction:",
                entry.qtyAfterTransaction.toString(),
                context,
              ),
              _detailRow("Valuation Rate:", entry.valuationRate.toString(), context),
              _detailRow("Stock Value:", entry.stockValue.toString(), context),
              _detailRow(
                "Status:",
                entry.isCancelled == 1 ? "Cancelled" : "Active",
                context,
              ),
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
            width: isMobile ? 120 : 150,
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    final double padding = isMobile ? 12.0 : 16.0;

    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              final warehouses = state.storeGetResponse.message.data;
              setState(() {
                warehouseList = warehouses
                    .where((wh) => wh.disabled == 0)
                    .toList();
                
                warehouseNames = warehouseList
                    .map((wh) => wh.name)
                    .toList();
                
                // Set default warehouse if not set
                if (selectedWarehouse == null || !warehouseNames.contains(selectedWarehouse)) {
                  selectedWarehouse = _getDefaultWarehouseName();
                }
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Stock Ledger",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "View and manage all stock ledger transactions",
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        body: BlocConsumer<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is StockLedgerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  // Filters Section
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
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isFiltersExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: isMobile ? 18 : 20,
                                color: Colors.black,
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
                              // Voucher Type
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: isMobile ? 6.0 : 8.0),
                                  child: _input(
                                    "Voucher Type",
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: selectedVoucherType,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      decoration: _decoration("Select type", context),
                                      items: voucherTypes.map((type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(
                                            type,
                                            style: TextStyle(
                                              fontSize: isMobile ? 13 : 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedVoucherType = value;
                                        });
                                        _onFilterChanged();
                                      },
                                    ),
                                    context,
                                  ),
                                ),
                              ),
                              
                              // Warehouse
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: isMobile ? 6.0 : 8.0),
                                  child: _input(
                                    "Warehouse",
                                    DropdownButtonFormField<String?>(
                                      isExpanded: true,
                                      initialValue: selectedWarehouse,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      decoration: _decoration("Warehouse", context),
                                      items: warehouseNames.map((whName) {
                                        return DropdownMenuItem<String?>(
                                          value: whName,
                                          child: Text(
                                            whName,
                                            style: TextStyle(
                                              fontSize: isMobile ? 13 : 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedWarehouse = value;
                                        });
                                        _onFilterChanged();
                                      },
                                    ),
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isMobile ? 12 : 16),
                          
                          // Second Row: 2 filters
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // From Date
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: isMobile ? 6.0 : 8.0),
                                  child: _input(
                                    "From Date",
                                    TextFormField(
                                      controller: _fromDateController,
                                      readOnly: true,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      decoration: _decoration("Select date", context).copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.calendar_today,
                                            size: isMobile ? 16 : 18,
                                            color: Colors.grey[700],
                                          ),
                                          onPressed: () => _selectDate(context, true),
                                        ),
                                      ),
                                    ),
                                    context,
                                  ),
                                ),
                              ),
                              
                              // To Date
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: isMobile ? 6.0 : 8.0),
                                  child: _input(
                                    "To Date",
                                    TextFormField(
                                      controller: _toDateController,
                                      readOnly: true,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      decoration: _decoration("Select date", context).copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.calendar_today,
                                            size: isMobile ? 16 : 18,
                                            color: Colors.grey[700],
                                          ),
                                          onPressed: () => _selectDate(context, false),
                                        ),
                                      ),
                                    ),
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isMobile ? 12 : 16),
                          
                          // Third Row: Status filter
                          _input(
                            "Status",
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedStatus,
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                color: Colors.black,
                              ),
                              decoration: _decoration("Status", context),
                              items: statusOptions.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value;
                                });
                                _onFilterChanged();
                              },
                            ),
                            context,
                          ),
                          
                          SizedBox(height: isMobile ? 16 : 20),
                          
                          // Action Buttons - NOT ROUNDED with white borders
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Reset Filters Button - White with red border
                              OutlinedButton(
                                onPressed: _resetFilters,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red, width: 1.0),
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
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
                                      Icons.close,
                                      color: Colors.red,
                                      size: isMobile ? 16 : 18,
                                    ),
                                    SizedBox(width: isMobile ? 4 : 8),
                                    Text(
                                      "Reset Filters",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: isMobile ? 12 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: isMobile ? 8 : 12),
                              
                              // Apply Filters Button - Blue with no border
                              ElevatedButton(
                                onPressed: _loadStockEntries,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
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

                  // Data Table Section
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Loading State
                        if (state is StockLedgerLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 40),
                            child: const Center(child: CircularProgressIndicator()),
                          ),

                        // Loaded State
                        if (state is StockLedgerLoaded)
                          _buildStockLedgerTable(state.response, context),

                        // Empty or Initial State
                        if (state is InventoryInitial ||
                            (state is StockLedgerLoaded &&
                                state.response.data.isEmpty))
                          _buildEmptyState(context),
                      ],
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

  Widget _buildStockLedgerTable(StockLedgerResponse response, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Info
        Padding(
          padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing ${response.data.length} of ${response.count} entries",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey,
                ),
              ),
              Chip(
                backgroundColor: const Color(0xFFDCFCE7),
                label: Text(
                  "Success: ${response.success ? 'Yes' : 'No'}",
                  style: TextStyle(
                    color: const Color(0xFF166534),
                    fontSize: isMobile ? 11 : 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Data Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
            dataRowMinHeight: isMobile ? 40 : 56,
            columnSpacing: isMobile ? 12 : 24,
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 12 : 14,
              color: Colors.black,
            ),
            columns: [
              DataColumn(
                label: Text(
                  "Voucher No",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              DataColumn(
                label: Text(
                  "Voucher Type",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              DataColumn(
                label: Text(
                  "Date & Time",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              DataColumn(
                label: Text(
                  "Warehouse",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              DataColumn(
                label: Text(
                  "Quantity",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              DataColumn(
                label: Text(
                  "Actions",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
            rows: response.data.map((entry) => _buildStockEntryRow(entry, context)).toList(),
          ),
        ),

        // Pagination Buttons - NOT ROUNDED with white borders
        if (response.count > response.data.length)
          Padding(
            padding: EdgeInsets.only(top: isMobile ? 12 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous Button - White with blue border
                OutlinedButton(
                  onPressed: () {
                    context.read<InventoryBloc>().add(
                      GetStockLedger(
                        company: currentUserResponse!.message.company.companyName,
                        warehouse: selectedWarehouse ?? _getDefaultWarehouseName(),
                        voucherType: selectedVoucherType,
                        limit: 20,
                        offset: 0,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB), width: 1.0),
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    minimumSize: Size(isMobile ? 80 : 100, 36),
                  ),
                  child: Text(
                    "Previous",
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                
                // Next Button - Blue with no border
                ElevatedButton(
                  onPressed: () {
                    context.read<InventoryBloc>().add(
                      GetStockLedger(
                        company: currentUserResponse!.message.company.companyName,
                        warehouse: selectedWarehouse ?? _getDefaultWarehouseName(),
                        voucherType: selectedVoucherType,
                        limit: 20,
                        offset: response.data.length,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    minimumSize: Size(isMobile ? 80 : 100, 36),
                    elevation: 0,
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 40),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: isMobile ? 48 : 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            "No stock ledger data found",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            "Try adjusting your filters or check back later",
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          
          // Refresh Button - NOT ROUNDED
          ElevatedButton(
            onPressed: _loadStockEntries,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              minimumSize: Size(isMobile ? 120 : 140, 40),
              elevation: 0,
            ),
            child: Text(
              "Refresh Data",
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }
}