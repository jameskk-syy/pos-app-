import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/inventory/get_stock_reconciliations_request.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/inventory/multi_level_stock_reconciliation.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/inventory/widgets/stock_reconciliation_list_widgets.dart';

class StockReconciliationMultiPage extends StatefulWidget {
  const StockReconciliationMultiPage({super.key});

  @override
  State<StockReconciliationMultiPage> createState() =>
      _StockReconciliationMultiPageState();
}

class _StockReconciliationMultiPageState
    extends State<StockReconciliationMultiPage> {
  CurrentUserResponse? currentUserResponse;
  bool _isFilterExpanded = false;

  String? _selectedWorkflowState;
  String? _selectedWarehouse;
  String? _selectedPurpose;
  DateTime? _fromDate;
  DateTime? _toDate;

  List<Warehouse> _warehouses = [];
  bool _warehousesLoaded = false;

  final List<String> _workflowStateOptions = [
    'Draft',
    'Pending Sales User',
    'Approved',
    'Completed',
    'Cancelled',
  ];

  final List<String> _purposeOptions = [
    'Stock Reconciliation',
    'Opening Stock',
    'Stock Take',
  ];

  List<StockReconciliation> _reconciliations = [];
  List<StockReconciliation> _allReconciliations = [];
  bool _isLoading = false;
  int _currentOffset = 0;
  final int _pageSize = 20;
  bool _hasMore = false;
  int _totalCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoading && _hasMore) {
        setState(() {
          _currentOffset += _pageSize;
        });
        _loadReconciliations();
      }
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
    _loadReconciliations();
  }

  void _loadWarehouses() {
    if (currentUserResponse == null) return;
    context.read<StoreBloc>().add(
      GetAllStores(company: currentUserResponse!.message.company.name),
    );
  }

  void _loadReconciliations({bool reset = false}) {
    if (currentUserResponse == null) return;

    if (reset) {
      setState(() {
        _currentOffset = 0;
        _allReconciliations = [];
      });
    }

    final request = GetStockReconciliationsRequest(
      company: currentUserResponse!.message.company.name,
      warehouse: _selectedWarehouse,
      workflowStatus: _selectedWorkflowState,
      limit: _pageSize,
      offset: _currentOffset,
    );

    context.read<InventoryBloc>().add(GetStockReconciliations(request: request));

    setState(() {
      _isLoading = true;
    });
  }

  void _applyLocalFilters() {
    setState(() {
      _reconciliations = _allReconciliations.where((reconciliation) {
        if (_selectedPurpose != null &&
            reconciliation.purpose != _selectedPurpose) {
          return false;
        }

        if (_fromDate != null || _toDate != null) {
          final postingDate = DateTime.tryParse(reconciliation.postingDate);
          if (postingDate != null) {
            if (_fromDate != null &&
                postingDate.isBefore(
                  DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day),
                )) {
              return false;
            }
            if (_toDate != null &&
                postingDate.isAfter(
                  DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59),
                )) {
              return false;
            }
          }
        }
        return true;
      }).toList();
    });
  }

  void _applyFilters() => _loadReconciliations(reset: true);

  void _resetFilters() {
    setState(() {
      _selectedWorkflowState = null;
      _selectedWarehouse = null;
      _selectedPurpose = null;
      _fromDate = null;
      _toDate = null;
    });
    _loadReconciliations(reset: true);
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
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              setState(() {
                _warehouses = state.storeGetResponse.message.data;
                _warehousesLoaded = true;
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
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is StockReconciliationsLoaded) {
              final apiReconciliations = state.response.message.data.reconciliations
                  .map((e) => StockReconciliation.fromApiModel(e))
                  .toList();

              setState(() {
                _isLoading = false;
                _allReconciliations.addAll(apiReconciliations);
                _hasMore = state.response.message.data.hasMore;
                _totalCount = state.response.message.data.totalCount;
              });

              _applyLocalFilters();
            } else if (state is StockReconciliationsError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load reconciliations: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Stock Reconciliation",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              Text(
                _totalCount > 0
                    ? "Showing ${_reconciliations.length} of $_totalCount records"
                    : "Manage stock reconciliation records",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                _loadWarehouses();
                _loadReconciliations(reset: true);
              },
              tooltip: 'Refresh',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateReconciliationPage(),
                    ),
                  );
                  if (result == true) {
                    _loadReconciliations(reset: true);
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Create Reconciliation", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976F3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StockReconciliationFilters(
                isExpanded: _isFilterExpanded,
                onToggleExpand: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
                selectedWarehouse: _selectedWarehouse,
                warehouses: _warehouses,
                warehousesLoaded: _warehousesLoaded,
                selectedWorkflowState: _selectedWorkflowState,
                workflowStateOptions: _workflowStateOptions,
                selectedPurpose: _selectedPurpose,
                purposeOptions: _purposeOptions,
                fromDate: _fromDate,
                toDate: _toDate,
                onWarehouseChanged: (val) => setState(() => _selectedWarehouse = val),
                onWorkflowStateChanged: (val) => setState(() => _selectedWorkflowState = val),
                onPurposeChanged: (val) => setState(() => _selectedPurpose = val),
                onSelectFromDate: () => _selectDate(context, true),
                onSelectToDate: () => _selectDate(context, false),
                onReset: _resetFilters,
                onApply: _applyFilters,
              ),
              const SizedBox(height: 16),
              StockReconciliationTable(
                reconciliations: _reconciliations,
                onShowActions: (rec) => StockReconciliationActionMenu.show(
                  context,
                  rec,
                  () => StockReconciliationDetailDialog.show(context, rec),
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 16),
                const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
