import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/get_stock_reconciliations_request.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/stock_reconciliations_response.dart'
    as pos;
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/create_stock_taking.dart';
import 'package:pos/screens/multi_level_stock_reconciliation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/add_stock_take_request.dart';

class StockReconciliation {
  final String name;
  final String company;
  final String warehouse;
  final String postingDate;
  final String postingTime;
  final String purpose;
  final int docstatus;
  final String workflowStatus;
  final String creation;
  final String modified;
  final String owner;
  final int itemsCount;
  final List<String> warehouses;

  StockReconciliation({
    required this.name,
    required this.company,
    required this.warehouse,
    required this.postingDate,
    required this.postingTime,
    required this.purpose,
    required this.docstatus,
    required this.workflowStatus,
    required this.creation,
    required this.modified,
    required this.owner,
    required this.itemsCount,
    required this.warehouses,
  });

  String get workflowState => workflowStatus;
  String get expenseAccount => 'Stock Adjustment - ${company.split(' ').last}';
  String get costCenter => 'Main - ${company.split(' ').last}';

  factory StockReconciliation.fromApiModel(pos.StockReconciliation apiModel) {
    return StockReconciliation(
      name: apiModel.name,
      company: apiModel.company,
      warehouse: apiModel.warehouse,
      postingDate: apiModel.postingDate,
      postingTime: apiModel.postingTime,
      purpose: apiModel.purpose,
      docstatus: apiModel.docstatus,
      workflowStatus: apiModel.workflowStatus,
      creation: apiModel.creation,
      modified: apiModel.modified,
      owner: apiModel.owner,
      itemsCount: apiModel.itemsCount,
      warehouses: apiModel.warehouses,
    );
  }
}

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

    _loadWarehouses();
    _loadReconciliations();
  }

  void _loadWarehouses() {
    if (currentUserResponse == null) {
      debugPrint('Cannot load warehouses: currentUserResponse is null');
      return;
    }

    context.read<StoreBloc>().add(
      GetAllStores(company: currentUserResponse!.message.company.name),
    );
  }

  void _loadReconciliations({bool reset = false}) {
    if (currentUserResponse == null) {
      debugPrint('Cannot load reconciliations: currentUserResponse is null');
      return;
    }

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

    context.read<InventoryBloc>().add(
      GetStockReconciliations(request: request),
    );

    setState(() {
      _isLoading = true;
    });
  }

  void _applyLocalFilters() {
    setState(() {
      _reconciliations = _allReconciliations.where((reconciliation) {
        // Filter by purpose
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
                  DateTime(
                    _toDate!.year,
                    _toDate!.month,
                    _toDate!.day,
                    23,
                    59,
                    59,
                  ),
                )) {
              return false;
            }
          }
        }

        return true;
      }).toList();
    });
  }

  void _applyFilters() {
    _loadReconciliations(reset: true);
  }

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

  StockTakeRole? _getRoleForStatus(String status) {
    if (currentUserResponse == null) return null;
    final roles = currentUserResponse!.message.roles;

    if ((status == 'Pending Sales User' || status == 'Pending Sales Person') &&
        roles.contains('Sales User')) {
      return StockTakeRole.salesPerson;
    }
    if (status == 'Pending Stock Manager' && roles.contains('Stock Manager')) {
      return StockTakeRole.stockManager;
    }
    if (status == 'Pending Quality Manager' &&
        (roles.contains('Quality Manager') ||
            roles.contains('Stock Controller'))) {
      return StockTakeRole.stockController;
    }
    return null;
  }

  void _showActionMenu(
    BuildContext context,
    StockReconciliation reconciliation,
  ) {
    final role = _getRoleForStatus(reconciliation.workflowStatus);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.blue),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _showViewDetailsDialog(context, reconciliation);
              },
            ),
            if (role != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_box, color: Colors.green),
                title: Text(
                  role == StockTakeRole.stockManager
                      ? 'Submit Reconciliation'
                      : 'Add Stock Take',
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockTakePage(
                        reconciliationName: reconciliation.name,
                        role: role,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showViewDetailsDialog(
    BuildContext context,
    StockReconciliation reconciliation,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            constraints: BoxConstraints(maxWidth: 800, minWidth: 600),
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Color(0xFF1976F3)),
                    const SizedBox(width: 12),
                    const Text(
                      'Reconciliation Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow('Reconciliation ID', reconciliation.name),
                        const Divider(height: 24),
                        _detailRow('Company', reconciliation.company),
                        const Divider(height: 24),
                        _detailRow('Warehouse', reconciliation.warehouse),
                        const Divider(height: 24),
                        _detailRow('Posting Date', reconciliation.postingDate),
                        const Divider(height: 24),
                        _detailRow('Posting Time', reconciliation.postingTime),
                        const Divider(height: 24),
                        _detailRow('Purpose', reconciliation.purpose),
                        const Divider(height: 24),
                        _detailRow(
                          'Workflow State',
                          reconciliation.workflowState,
                          valueColor: _getStatusColor(
                            reconciliation.workflowState,
                          ),
                        ),
                        const Divider(height: 24),
                        _detailRow(
                          'Expense Account',
                          reconciliation.expenseAccount,
                        ),
                        const Divider(height: 24),
                        _detailRow('Cost Center', reconciliation.costCenter),
                        const Divider(height: 24),
                        _detailRow(
                          'Items Count',
                          '${reconciliation.itemsCount}',
                        ),
                        const Divider(height: 24),
                        _detailRow('Owner', reconciliation.owner),
                        const Divider(height: 24),
                        _detailRow('Created', reconciliation.creation),
                        const Divider(height: 24),
                        _detailRow('Modified', reconciliation.modified),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
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
              final apiReconciliations = state
                  .response
                  .message
                  .data
                  .reconciliations
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
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to load reconciliations: ${state.message}',
                  ),
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
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateReconciliationPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Create Reconciliation",
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
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _filtersCard(),
              const SizedBox(height: 16),
              _tableCard(),
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
            Row(
              children: [
                Expanded(
                  child: _warehousesLoaded
                      ? _dropdownField(
                          "Warehouse",
                          _selectedWarehouse,
                          _warehouses.map((w) => w.name).toList(),
                          (value) {
                            setState(() {
                              _selectedWarehouse = value;
                            });
                          },
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: _inputDecoration(),
                          child: const Text(
                            'Loading warehouses...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdownField(
                    "Workflow State",
                    _selectedWorkflowState,
                    _workflowStateOptions,
                    (value) {
                      setState(() {
                        _selectedWorkflowState = value;
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
                    "Purpose",
                    _selectedPurpose,
                    _purposeOptions,
                    (value) {
                      setState(() {
                        _selectedPurpose = value;
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
        ],
      ),
    );
  }

  Widget _tableCard() {
    if (_isLoading && _allReconciliations.isEmpty) {
      return Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(40),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: _reconciliations.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No stock reconciliations found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF1F5F9),
                ),
                columns: const [
                  DataColumn(label: Text("Reconciliation ID")),
                  DataColumn(label: Text("Warehouse")),
                  DataColumn(label: Text("Posting Date")),
                  DataColumn(label: Text("Posting Time")),
                  DataColumn(label: Text("Purpose")),
                  DataColumn(label: Text("Workflow State")),
                  DataColumn(label: Text("Expense Account")),
                  DataColumn(label: Text("Cost Center")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: _reconciliations.map((reconciliation) {
                  final dateTime = DateTime.tryParse(
                    reconciliation.postingDate,
                  );
                  final formattedDate = dateTime != null
                      ? DateFormat('dd MMM yyyy').format(dateTime)
                      : reconciliation.postingDate;

                  return DataRow(
                    cells: [
                      DataCell(Text(reconciliation.name)),
                      DataCell(Text(reconciliation.warehouse)),
                      DataCell(Text(formattedDate)),
                      DataCell(Text(reconciliation.postingTime)),
                      DataCell(Text(reconciliation.purpose)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              reconciliation.workflowState,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reconciliation.workflowState,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(reconciliation.expenseAccount)),
                      DataCell(Text(reconciliation.costCenter)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () =>
                              _showActionMenu(context, reconciliation),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Color _getStatusColor(String workflowState) {
    switch (workflowState.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'pending sales user':
      case 'pending sale':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
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
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
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
