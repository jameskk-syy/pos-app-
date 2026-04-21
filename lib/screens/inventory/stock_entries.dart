import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/inventory/widgets/stock_entries_widgets.dart';

class StockEntriesPage extends StatefulWidget {
  const StockEntriesPage({super.key});

  @override
  State<StockEntriesPage> createState() => _StockEntriesPageState();
}

class _StockEntriesPageState extends State<StockEntriesPage> {
  String? selectedVoucherType;
  String? selectedWarehouse;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedStatus;
  bool _isFiltersExpanded = true;
  Timer? _debounceTimer;

  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  final List<String> voucherTypes = ["", "Material Receipt", "Material Transfer", "Material Issue"];
  final List<String> statusOptions = ["All", "Draft", "Submitted", "Cancelled"];
  
  CurrentUserResponse? currentUserResponse;
  List<String> warehouseNames = [];
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    selectedVoucherType = voucherTypes.first;
    selectedStatus = statusOptions.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  Future<void> _loadCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return;
    
    final user = CurrentUserResponse.fromJson(jsonDecode(userString));
    setState(() {
      currentUserResponse = user;
    });

    _fetchWarehouses();
    _loadStockEntries();
  }

  void _fetchWarehouses() {
    if (currentUserResponse == null) return;
    context.read<StoreBloc>().add(GetAllStores(company: currentUserResponse!.message.company.companyName));
  }

  void _loadStockEntries() {
    if (currentUserResponse == null) return;

    int? docStatus;
    if (selectedStatus != "All") {
      switch (selectedStatus) {
        case "Draft": docStatus = 0; break;
        case "Submitted": docStatus = 1; break;
        case "Cancelled": docStatus = 2; break;
      }
    }

    context.read<InventoryBloc>().add(
      GetStockEntries(
        company: currentUserResponse!.message.company.companyName,
        page: currentPage,
        pageSize: 20,
        stockEntryType: selectedVoucherType == "" ? null : selectedVoucherType,
        warehouse: selectedWarehouse,
        docstatus: docStatus,
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
      currentPage = 1;
      _fromDateController.clear();
      _toDateController.clear();
    });
    _loadStockEntries();
  }

  void _onFilterChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => currentPage = 1);
      _loadStockEntries();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final picked = await showDatePicker(
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              setState(() {
                warehouseNames = state.storeGetResponse.message.data
                    .where((wh) => wh.disabled == 0)
                    .map((wh) => wh.name)
                    .toList();
                if (selectedWarehouse != null && !warehouseNames.contains(selectedWarehouse)) {
                  selectedWarehouse = null;
                }
              });
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is StockEntriesError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Stock Entries", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: isMobile ? 16 : 18)),
              Text("View and manage all stock entries transactions", style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey)),
            ],
          ),
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                children: [
                  StockEntriesFilters(
                    isExpanded: _isFiltersExpanded,
                    onToggleExpanded: () => setState(() => _isFiltersExpanded = !_isFiltersExpanded),
                    selectedVoucherType: selectedVoucherType,
                    voucherTypes: voucherTypes,
                    onVoucherTypeChanged: (val) {
                      setState(() => selectedVoucherType = val);
                      _onFilterChanged();
                    },
                    selectedWarehouse: selectedWarehouse,
                    warehouseNames: warehouseNames,
                    onWarehouseChanged: (val) {
                      setState(() => selectedWarehouse = val);
                      _onFilterChanged();
                    },
                    fromDateController: _fromDateController,
                    onDateTap: (isFrom) => _selectDate(context, isFrom),
                    toDateController: _toDateController,
                    selectedStatus: selectedStatus,
                    statusOptions: statusOptions,
                    onStatusChanged: (val) {
                      setState(() => selectedStatus = val);
                      _onFilterChanged();
                    },
                    onReset: _resetFilters,
                    onApply: _loadStockEntries,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                    ),
                    child: _buildBody(state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(InventoryState state) {
    if (state is StockEntriesLoading) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()));
    }
    if (state is StockEntriesLoaded) {
      if (state.response.data.entries.isEmpty) return _buildEmptyState();
      return StockEntriesTable(
        response: state.response,
        currentPage: currentPage,
        onPageChanged: (page) {
          setState(() => currentPage = page);
          _loadStockEntries();
        },
        onViewDetails: (entry) => StockEntryDetailDialog.show(context, entry),
      );
    }
    if (state is StockEntriesError) return _buildErrorState(state.message);
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: isMobile ? 48 : 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("No stock entries found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
          const Text("Try adjusting your filters or check back later", style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadStockEntries,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), minimumSize: const Size(140, 40), elevation: 0),
            child: const Text("Refresh Data"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text("Error loading data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red)),
          Text(message, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadStockEntries,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), minimumSize: const Size(140, 40), elevation: 0),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
