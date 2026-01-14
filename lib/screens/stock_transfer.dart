import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/approve_stock_transfer_request.dart';
import 'package:pos/domain/requests/get_material_requests_request.dart';
import 'package:pos/domain/requests/submit_stock_transfer_request.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/material_requests_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/create_stock_transfer.dart';
import 'package:pos/screens/receive_stock_transfer.dart';
import 'package:pos/screens/transfer_dispatch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
    'Pending',
    'Completed',
    'Cancelled',
    'Draft',
  ];

  @override
  void initState() {
    super.initState();
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

    // Load stores
    context.read<StoreBloc>().add(
      GetAllStores(company: currentUserResponse!.message.company.name),
    );

    // Load material requests
    _loadMaterialRequests();
  }

  void _loadMaterialRequests() {
    if (currentUserResponse == null) {
      debugPrint('Cannot load material requests: currentUserResponse is null');
      return;
    }

    debugPrint(
      'Loading material requests for company: ${currentUserResponse!.message.company.name}',
    );
    debugPrint(
      'Filters - Status: $_selectedStatus, Origin: $_selectedOriginWarehouse, Destination: $_selectedDestinationWarehouse',
    );

    context.read<InventoryBloc>().add(
      GetMaterialRequests(
        request: GetMaterialRequestsRequest(
          company: currentUserResponse!.message.company.name,
          status: _selectedStatus,
          originWarehouse: _selectedOriginWarehouse,
          destinationWarehouse: _selectedDestinationWarehouse,
          fromDate: _fromDate != null
              ? DateFormat('yyyy-MM-dd').format(_fromDate!)
              : null,
          toDate: _toDate != null
              ? DateFormat('yyyy-MM-dd').format(_toDate!)
              : null,
        ),
      ),
    );
  }

  void _applyFilters() {
    _loadMaterialRequests();
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
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _showActionMenu(
    BuildContext context,
    String requestName,
    MaterialRequest materialRequest,
    String status,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Submit for Approval'),
              enabled: status == 'Draft',
              onTap: status == 'Draft'
                  ? () {
                      Navigator.pop(context);
                      _handleSubmit(requestName);
                    }
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.approval, color: Colors.purple),
              title: const Text('Approve'),
              enabled: status == 'Pending',
              onTap: status == 'Pending'
                  ? () {
                      Navigator.pop(context);
                      _handleApprove(requestName);
                    }
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.blue),
              title: const Text('Dispatch'),
              enabled: status == 'Pending',
              onTap: status == 'Pending'
                  ? () {
                     Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context2) => StockTransferDispatchScreen(
                            requestId: requestName,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.inbox, color: Colors.orange),
              title: const Text('Receive'),
              enabled:
                  status == 'In Transit' || status == 'Partially In Transit' || status == 'Partially Received',
              onTap:
                  (status == 'In Transit' || status == 'Partially In Transit'  || status == 'Partially Received')
                  ? () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context2) => StockReceiveStockScreen(
                            requestId: requestName,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.grey),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _handleViewDetails(requestName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleApprove(String requestName) {
    if (currentUserResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Submit Request'),
          content: Text(
            'Are you sure you want to approve request: $requestName for approval?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // Dispatch the submit event
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
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit(String requestName) {
    if (currentUserResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Submit Request'),
          content: Text(
            'Are you sure you want to submit request: $requestName for approval?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // Dispatch the submit event
                context.read<InventoryBloc>().add(
                  SubmitStockTransfer(
                    request: SubmitStockTransferRequest(requestId: requestName),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
  void _handleViewDetails(String requestName) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Viewing details: $requestName')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Material Requests",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Manage material transfer requests",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadMaterialRequests,
            tooltip: 'Refresh',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                _showCreateTransferForm(context);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Create Request",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [_filtersCard(), const SizedBox(height: 16), _tableCard()],
        ),
      ),
    );
  }

  void _showCreateTransferForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const StockTransfer(),
    );
  }

  Widget _filtersCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Row(
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(
                  _isFilterExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          if (_isFilterExpanded) ...[
            const SizedBox(height: 12),
            BlocBuilder<StoreBloc, StoreState>(
              builder: (context, storeState) {
                List<String> warehouses = [];
                if (storeState is StoreStateSuccess) {
                  warehouses = storeState.storeGetResponse.message.data
                      .map((store) => store.name)
                      .toList();
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _dropdownField(
                            "Origin Warehouse",
                            _selectedOriginWarehouse,
                            warehouses,
                            (value) {
                              setState(() {
                                _selectedOriginWarehouse = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dropdownField(
                            "Destination Warehouse",
                            _selectedDestinationWarehouse,
                            warehouses,
                            (value) {
                              setState(() {
                                _selectedDestinationWarehouse = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _dropdownField(
                            "Status",
                            _selectedStatus,
                            _statusOptions,
                            (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _dateField(
                            "From Date",
                            _fromDate,
                            () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateField(
                            "To Date",
                            _toDate,
                            () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              "Reset Filters",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Apply Filters",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _tableCard() {
    return Container(
      decoration: _cardDecoration(),
      child: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is MaterialRequestsError) {
            debugPrint('Error in BLoC: ${state.message}');
          } else if (state is MaterialRequestsLoaded) {
            debugPrint(
              'Successfully loaded ${state.response.data.requests.length} requests',
            );
          } else if (state is ApproveStockTransferSuccess) {
            // Handle approval/submit success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload the list
            _loadMaterialRequests();
          } else if (state is ApproveStockTransferSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: Colors.green,
              ),
            );
            // Reload the list
            _loadMaterialRequests();
          } else if (state is ApproveStockTransferError) {
            // Handle approval/submit error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SubmitStockTransferError) {
            // Handle approval/submit error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint('Current BLoC state: ${state.runtimeType}');

          // Show loading state for material requests and approval
          if (state is MaterialRequestsLoading ||
              state is ApproveStockTransferLoading ||
              state is SubmitStockTransferLoading) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Show error state
          if (state is MaterialRequestsError) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadMaterialRequests,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show loaded state
          if (state is MaterialRequestsLoaded) {
            debugPrint('MaterialRequestsLoaded state received');
            final requests = state.response.data.requests;
            debugPrint('Number of requests: ${requests.length}');

            if (requests.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No material requests found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF1F5F9),
                ),
                columns: const [
                  DataColumn(label: Text("Request ID")),
                  DataColumn(label: Text("Requested By")),
                  DataColumn(label: Text("Requested On")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Origin")),
                  DataColumn(label: Text("Destination")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: requests.map((request) {
                  debugPrint(
                    'Displaying request: ${request.name} - ${request.status}',
                  );

                  final dateTime = DateTime.tryParse(request.requestedOn);
                  final formattedDate = dateTime != null
                      ? DateFormat('dd MMM yyyy, HH:mm').format(dateTime)
                      : request.requestedOn;

                  return DataRow(
                    cells: [
                      DataCell(Text(request.name)),
                      DataCell(Text(request.requestedBy)),
                      DataCell(Text(formattedDate)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            request.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(request.originWarehouse)),
                      DataCell(Text(request.destinationWarehouse)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showActionMenu(
                            context,
                            request.name,
                            request,
                            request.status,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.search, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading material requests...',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMaterialRequests,
                    child: const Text('Load Data'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      case 'in transit':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _dropdownField(
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _inputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _dateField(String hint, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: _inputDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('dd MMM yyyy').format(date) : hint,
              style: TextStyle(
                color: date != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.6),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.4),
    );
  }
}
