import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/inventory/approve_stock_transfer_request.dart';
import 'package:pos/domain/requests/inventory/get_material_requests_request.dart';
import 'package:pos/domain/requests/inventory/submit_stock_transfer_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/inventory/material_requests_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/inventory/create_stock_transfer.dart';
import 'package:pos/screens/inventory/receive_stock_transfer.dart';
import 'package:pos/screens/inventory/transfer_dispatch.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:intl/intl.dart';
import 'package:pos/screens/inventory/widgets/stock_transfer_list_widgets.dart';

class StockTransferPage extends StatefulWidget {
  const StockTransferPage({super.key});

  @override
  State<StockTransferPage> createState() => _StockTransferPageState();
}

class _StockTransferPageState extends State<StockTransferPage> {
  CurrentUserResponse? currentUserResponse;
  bool _isFilterExpanded = false;

  String? _selectedStatus;
  String? _selectedOriginWarehouse;
  String? _selectedDestinationWarehouse;
  DateTime? _fromDate;
  DateTime? _toDate;

  final List<String> _statusOptions = [
    'Draft',
    'Approved',
    'In Transit',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
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

    setState(() { currentUserResponse = savedUser; });

    context.read<StoreBloc>().add(
      GetAllStores(company: currentUserResponse!.message.company.name),
    );
    _loadMaterialRequests();
  }

  void _loadMaterialRequests() {
    if (currentUserResponse == null) return;

    context.read<InventoryBloc>().add(
      GetMaterialRequests(
        request: GetMaterialRequestsRequest(
          company: currentUserResponse!.message.company.name,
          status: _selectedStatus,
          originWarehouse: _selectedOriginWarehouse,
          destinationWarehouse: _selectedDestinationWarehouse,
          fromDate: _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : null,
          toDate: _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null,
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedOriginWarehouse = null;
      _selectedDestinationWarehouse = null;
      _fromDate = null;
      _toDate = null;
    });
    _loadMaterialRequests();
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
        if (isFromDate) { _fromDate = picked; } else { _toDate = picked; }
      });
    }
  }

  void _showActionMenu(BuildContext context, String requestName, MaterialRequest materialRequest, String status) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StockTransferActionMenu(
        requestName: requestName,
        materialRequest: materialRequest,
        status: status,
        onSubmit: (name) { Navigator.pop(context); _handleSubmit(name); },
        onApprove: (name) { Navigator.pop(context); _handleApprove(name); },
        onDispatch: (name) {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context2) => StockTransferDispatchScreen(requestId: name)));
        },
        onReceive: (name) {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context2) => StockReceiveStockScreen(requestId: name)));
        },
        onViewDetails: (request) { Navigator.pop(context); _handleViewDetails(request); },
      ),
    );
  }

  void _handleApprove(String requestName) {
    if (currentUserResponse == null) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Approve Request'),
        content: Text('Are you sure you want to approve request: $requestName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<InventoryBloc>().add(
                ApproveStockTransfer(
                  request: ApproveStockTransferRequest(
                    requestId: requestName,
                    approvedBy: currentUserResponse!.message.user.email,
                    isApproved: true,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleSubmit(String requestName) {
    if (currentUserResponse == null) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Submit Request'),
        content: Text('Are you sure you want to submit request: $requestName for approval?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<InventoryBloc>().add(
                SubmitStockTransfer(request: SubmitStockTransferRequest(requestId: requestName)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleViewDetails(MaterialRequest request) {
    showDialog(
      context: context,
      builder: (context) => StockTransferDetailDialog(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Material Requests", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            Text("Manage material transfer requests", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.black), onPressed: _loadMaterialRequests, tooltip: 'Refresh'),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => const StockTransfer(),
                );
                if (result == true) _loadMaterialRequests();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Create Request", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976F3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, storeState) {
        List<String> warehouses = [];
        if (storeState is StoreStateSuccess) {
          warehouses = storeState.storeGetResponse.message.data.map((store) => store.name).toList();
        }
        return StockTransferFilters(
          isExpanded: _isFilterExpanded,
          onToggle: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
          selectedStatus: _selectedStatus,
          selectedOrigin: _selectedOriginWarehouse,
          selectedDestination: _selectedDestinationWarehouse,
          statusOptions: _statusOptions,
          warehouses: warehouses,
          fromDate: _fromDate,
          toDate: _toDate,
          onStatusChanged: (val) => setState(() => _selectedStatus = val),
          onOriginChanged: (val) => setState(() => _selectedOriginWarehouse = val),
          onDestinationChanged: (val) => setState(() => _selectedDestinationWarehouse = val),
          onSelectFromDate: () => _selectDate(context, true),
          onSelectToDate: () => _selectDate(context, false),
          onReset: _resetFilters,
          onApply: _loadMaterialRequests,
        );
      },
    );
  }

  Widget _buildTable() {
    return BlocConsumer<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is ApproveStockTransferSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.response.message), backgroundColor: Colors.green));
          _loadMaterialRequests();
        } else if (state is ApproveStockTransferError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red));
        } else if (state is SubmitStockTransferError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        if (state is MaterialRequestsLoading || state is ApproveStockTransferLoading || state is SubmitStockTransferLoading) {
          return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
        }

        if (state is MaterialRequestsError) {
          return _buildErrorView(state.message);
        }

        if (state is MaterialRequestsLoaded) {
          final requests = state.response.data.requests;
          if (requests.isEmpty) return _buildEmptyState();
          return StockTransferTable(requests: requests, onShowActionMenu: _showActionMenu);
        }

        return _buildInitialState();
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $message', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadMaterialRequests, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No material requests found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Loading material requests...', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadMaterialRequests, child: const Text('Load Data')),
          ],
        ),
      ),
    );
  }
}
