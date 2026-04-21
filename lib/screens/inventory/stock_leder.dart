import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/stock_ledger_entry.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/inventory/widgets/stock_ledger_widgets.dart';

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

    _fetchWarehouses();
    _loadStockEntries();
  }

  void _fetchWarehouses() {
    if (currentUserResponse == null) return;

    context.read<StoreBloc>().add(
      GetAllStores(company: currentUserResponse!.message.company.companyName),
    );
  }

  void _loadStockEntries({int offset = 0}) {
    if (currentUserResponse == null) return;

    context.read<InventoryBloc>().add(
      GetStockLedger(
        company: currentUserResponse!.message.company.companyName,
        warehouse: selectedWarehouse,
        voucherType: selectedVoucherType == "" ? null : selectedVoucherType,
        limit: 20,
        offset: offset,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedVoucherType = voucherTypes.first;
      selectedWarehouse = null;
      fromDate = null;
      toDate = null;
      selectedStatus = statusOptions.first;
      _fromDateController.clear();
      _toDateController.clear();
    });
    _loadStockEntries();
  }

  void _onFilterChanged() {
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
          _fromDateController.text = "${picked.day}/${picked.month}/${picked.year}";
        } else {
          toDate = picked;
          _toDateController.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      });
      _onFilterChanged();
    }
  }

  void _showEntryDetails(StockLedgerEntry entry) {
    showDialog(
      context: context,
      builder: (context) => StockLedgerDetailDialog(entry: entry),
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
                warehouseList = warehouses.where((wh) => wh.disabled == 0).toList();
                warehouseNames = warehouseList.map((wh) => wh.name).toList();
                if (selectedWarehouse != null && !warehouseNames.contains(selectedWarehouse)) {
                  selectedWarehouse = null;
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
                style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        body: BlocConsumer<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is StockLedgerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  StockLedgerFilters(
                    selectedVoucherType: selectedVoucherType,
                    selectedWarehouse: selectedWarehouse,
                    selectedStatus: selectedStatus,
                    isFiltersExpanded: _isFiltersExpanded,
                    voucherTypes: voucherTypes,
                    statusOptions: statusOptions,
                    warehouseNames: warehouseNames,
                    fromDateController: _fromDateController,
                    toDateController: _toDateController,
                    onToggleFilters: () => setState(() => _isFiltersExpanded = !_isFiltersExpanded),
                    onVoucherTypeChanged: (value) {
                      setState(() => selectedVoucherType = value);
                      _onFilterChanged();
                    },
                    onWarehouseChanged: (value) {
                      setState(() => selectedWarehouse = value);
                      _onFilterChanged();
                    },
                    onStatusChanged: (value) {
                      setState(() => selectedStatus = value);
                      _onFilterChanged();
                    },
                    onSelectFromDate: () => _selectDate(context, true),
                    onSelectToDate: () => _selectDate(context, false),
                    onResetFilters: _resetFilters,
                    onApplyFilters: () => _loadStockEntries(),
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                    ),
                    child: Column(
                      children: [
                        if (state is StockLedgerLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 40),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                        if (state is StockLedgerLoaded)
                          StockLedgerTable(
                            response: state.response,
                            onViewDetails: _showEntryDetails,
                            onPrevious: () => _loadStockEntries(offset: 0),
                            onNext: () => _loadStockEntries(offset: state.response.data.length),
                          ),
                        if (state is InventoryInitial ||
                            (state is StockLedgerLoaded && state.response.data.isEmpty))
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

  Widget _buildEmptyState(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 40),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: isMobile ? 48 : 64, color: Colors.grey[400]),
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
            style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ElevatedButton(
            onPressed: () => _loadStockEntries(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              minimumSize: Size(isMobile ? 120 : 140, 40),
              elevation: 0,
            ),
            child: Text("Refresh Data", style: TextStyle(fontSize: isMobile ? 12 : 14)),
          ),
        ],
      ),
    );
  }
}
