import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/inventory_discount_rule.dart';
import 'package:pos/domain/requests/disable_discount_rule_request.dart';
import 'package:pos/domain/requests/enable_discount_rule_request.dart';
import 'package:pos/domain/requests/get_inventory_discount_rules_request.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/inventory/create_discount_inventory.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class InventoryDiscountRulesScreen extends StatefulWidget {
  const InventoryDiscountRulesScreen({super.key});

  @override
  State<InventoryDiscountRulesScreen> createState() =>
      _InventoryDiscountRulesScreenState();
}

class _InventoryDiscountRulesScreenState
    extends State<InventoryDiscountRulesScreen> {
  CurrentUserResponse? currentUserResponse;
  bool _isFilterExpanded = false;

  String? _selectedRuleType;
  String? _selectedWarehouse;
  String? _selectedDiscountType;
  int? _selectedStatus;
  String? _searchTerm;
  DateTime? _fromDate;
  DateTime? _toDate;

  List<Warehouse> _warehouses = [];
  bool _warehousesLoaded = false;

  final List<String> _ruleTypeOptions = ['Item', 'Batch', 'Item Group'];

  final List<String> _discountTypeOptions = ['Amount', 'Percentage'];

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': null, 'label': 'All'},
    {'value': 1, 'label': 'Active'},
    {'value': 0, 'label': 'Inactive'},
  ];

  List<InventoryDiscountRule> _rules = [];
  List<InventoryDiscountRule> _allRules = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = false;
  int _totalCount = 0;

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

    setState(() {
      currentUserResponse = savedUser;
      _selectedRuleType = _ruleTypeOptions.first;
    });

    _loadWarehouses();
    _loadDiscountRules();
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

  void _loadDiscountRules({bool reset = false}) {
    if (currentUserResponse == null) {
      debugPrint('Cannot load discount rules: currentUserResponse is null');
      return;
    }

    if (reset) {
      setState(() {
        _currentPage = 1;
        _allRules = [];
      });
    }

    final request = GetInventoryDiscountRulesRequest(
      ruleType: _selectedRuleType ?? 'Item',
      company: currentUserResponse!.message.company.name,
      itemCode: _searchTerm,
      warehouse: _selectedWarehouse,
      isActive: _selectedStatus,
      searchTerm: _searchTerm,
      page: _currentPage,
      pageSize: _pageSize,
    );

    context.read<InventoryBloc>().add(
      GetInventoryDiscountRules(request: request),
    );

    setState(() {
      _isLoading = true;
    });
  }

  void _applyLocalFilters() {
    setState(() {
      _rules = _allRules.where((rule) {
        // Filter by discount type
        if (_selectedDiscountType != null &&
            rule.discountType != _selectedDiscountType) {
          return false;
        }

        // Filter by valid dates
        if (_fromDate != null || _toDate != null) {
          DateTime? validFrom;
          DateTime? validUpto;

          if (rule.validFrom != null) {
            validFrom = DateTime.tryParse(rule.validFrom!);
          }
          if (rule.validUpto != null) {
            validUpto = DateTime.tryParse(rule.validUpto!);
          }

          if (_fromDate != null) {
            if (validUpto != null &&
                validUpto.isBefore(
                  DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day),
                )) {
              return false;
            }
          }

          if (_toDate != null) {
            if (validFrom != null &&
                validFrom.isAfter(
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
    _loadDiscountRules(reset: true);
  }

  void _resetFilters() {
    setState(() {
      _selectedRuleType = _ruleTypeOptions.first;
      _selectedWarehouse = null;
      _selectedDiscountType = null;
      _selectedStatus = null;
      _searchTerm = null;
      _fromDate = null;
      _toDate = null;
    });
    _loadDiscountRules(reset: true);
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

  void _showActionMenu(BuildContext context, InventoryDiscountRule rule) {
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
                _showViewDetailsDialog(context, rule);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Edit Rule'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateDiscountRulePage(existingRule: rule),
                  ),
                ).then((_) {
                  _loadDiscountRules(reset: true);
                });
              },
            ),
            if (rule.isActive == 1)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Deactivate Rule'),
                onTap: () {
                  Navigator.pop(context);
                  _showDisableConfirmationDialog(context, rule);
                },
              ),
            if (rule.isActive == 0)
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                title: const Text('Activate Rule'),
                onTap: () {
                  Navigator.pop(context);
                  _showEnableConfirmationDialog(context, rule);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEnableConfirmationDialog(
    BuildContext context,
    InventoryDiscountRule rule,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Rule'),
        content: Text('Are you sure you want to activate "${rule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<InventoryBloc>().add(
                EnableDiscountRule(
                  request: EnableDiscountRuleRequest(name: rule.name),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _showDisableConfirmationDialog(
    BuildContext context,
    InventoryDiscountRule rule,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Rule'),
        content: Text('Are you sure you want to deactivate "${rule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<InventoryBloc>().add(
                DisableDiscountRule(
                  request: DisableDiscountRuleRequest(name: rule.name),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showViewDetailsDialog(
    BuildContext context,
    InventoryDiscountRule rule,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            constraints: const BoxConstraints(maxWidth: 800, minWidth: 600),
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.discount, color: Color(0xFF1976F3)),
                    const SizedBox(width: 12),
                    const Text(
                      'Discount Rule Details',
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
                        _detailRow('Rule Name', rule.name),
                        const Divider(height: 24),
                        _detailRow('Rule Type', rule.ruleType),
                        const Divider(height: 24),
                        _detailRow('Item Code', rule.itemCode),
                        const Divider(height: 24),
                        _detailRow('Warehouse', rule.warehouse),
                        const Divider(height: 24),
                        _detailRow('Batch No', rule.batchNo ?? 'N/A'),
                        const Divider(height: 24),
                        _detailRow('Item Group', rule.itemGroup ?? 'N/A'),
                        const Divider(height: 24),
                        _detailRow('Company', rule.company),
                        const Divider(height: 24),
                        _detailRow('Discount Type', rule.discountType),
                        const Divider(height: 24),
                        _detailRow(
                          'Discount Value',
                          rule.discountValue.toString(),
                        ),
                        const Divider(height: 24),
                        _detailRow('Priority', rule.priority.toString()),
                        const Divider(height: 24),
                        _detailRow(
                          'Status',
                          rule.status,
                          valueColor: rule.statusColor,
                        ),
                        const Divider(height: 24),
                        _detailRow('Valid From', rule.validFrom ?? 'N/A'),
                        const Divider(height: 24),
                        _detailRow('Valid Until', rule.validUpto ?? 'N/A'),
                        const Divider(height: 24),
                        _detailRow('Description', rule.description ?? 'N/A'),
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
            if (state is GetInventoryDiscountRulesLoaded) {
              final apiRules = state.response.message.data.rules
                  .map((e) => InventoryDiscountRule.fromApiModel(e))
                  .toList();

              final pagination = state.response.message.data.pagination;

              setState(() {
                _isLoading = false;
                _allRules = apiRules;
                _hasMore = _currentPage < pagination.totalPages;
                _totalCount = pagination.total;
              });

              _applyLocalFilters();
            } else if (state is GetInventoryDiscountRulesError) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to load discount rules: ${state.message}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is DisableDiscountRuleLoading) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is DisableDiscountRuleSuccess) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Discount rule deactivated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadDiscountRules(reset: true);
            } else if (state is DisableDiscountRuleError) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to deactivate rule: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is EnableDiscountRuleLoading) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is EnableDiscountRuleSuccess) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Discount rule activated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadDiscountRules(reset: true);
            } else if (state is EnableDiscountRuleError) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to activate rule: ${state.message}'),
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
                "Inventory Discount Rules",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _totalCount > 0
                    ? "Showing ${_rules.length} of $_totalCount rules"
                    : "Manage inventory discount rules",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                _loadWarehouses();
                _loadDiscountRules(reset: true);
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
                      builder: (context) => const CreateDiscountRulePage(),
                    ),
                  ).then((_) {
                    _loadDiscountRules(reset: true);
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Create Rule",
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
            children: [
              _filtersCard(),
              const SizedBox(height: 16),
              _tableCard(),
              if (_hasMore && !_isLoading) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPage++;
                    });
                    _loadDiscountRules();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    child: Text(
                      "Load More",
                      style: TextStyle(color: Colors.white),
                    ),
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
                  child: _dropdownField(
                    "Rule Type",
                    _selectedRuleType,
                    _ruleTypeOptions,
                    (value) {
                      setState(() {
                        _selectedRuleType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dropdownField(
                    "Discount Type",
                    _selectedDiscountType,
                    _discountTypeOptions,
                    (value) {
                      setState(() {
                        _selectedDiscountType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdownField(
                    "Status",
                    _statusOptions.firstWhere(
                      (s) => s['value'] == _selectedStatus,
                      orElse: () => _statusOptions.first,
                    )['label'],
                    _statusOptions.map((s) => s['label'] as String).toList(),
                    (value) {
                      final selectedOption = _statusOptions.firstWhere(
                        (s) => s['label'] == value,
                      );
                      setState(() {
                        _selectedStatus = selectedOption['value'];
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
                  child: _textField(
                    "Search (Item Code/Batch/Description)",
                    _searchTerm,
                    (value) {
                      setState(() {
                        _searchTerm = value;
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
                    "Valid From",
                    _fromDate,
                    () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField(
                    "Valid To",
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
    if (_isLoading && _allRules.isEmpty) {
      return Container(
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(40),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: _rules.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.discount, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No discount rules found',
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
                  DataColumn(label: Text("Rule Name")),
                  DataColumn(label: Text("Rule Type")),
                  DataColumn(label: Text("Item Code")),
                  DataColumn(label: Text("Warehouse")),
                  DataColumn(label: Text("Discount Type")),
                  DataColumn(label: Text("Discount Value")),
                  DataColumn(label: Text("Priority")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Valid From")),
                  DataColumn(label: Text("Valid Until")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: _rules.map((rule) {
                  String validFrom = rule.validFrom ?? 'N/A';
                  if (rule.validFrom != null) {
                    final date = DateTime.tryParse(rule.validFrom!);
                    if (date != null) {
                      validFrom = DateFormat('dd MMM yyyy').format(date);
                    }
                  }

                  String validUpto = rule.validUpto ?? 'N/A';
                  if (rule.validUpto != null) {
                    final date = DateTime.tryParse(rule.validUpto!);
                    if (date != null) {
                      validUpto = DateFormat('dd MMM yyyy').format(date);
                    }
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(rule.name)),
                      DataCell(Text(rule.ruleType)),
                      DataCell(Text(rule.itemCode)),
                      DataCell(Text(rule.warehouse)),
                      DataCell(Text(rule.discountType)),
                      DataCell(
                        Text(
                          '${rule.discountValue}${rule.discountType == 'Percentage' ? '%' : ''}',
                        ),
                      ),
                      DataCell(Text(rule.priority.toString())),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rule.statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            rule.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(validFrom)),
                      DataCell(Text(validUpto)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showActionMenu(context, rule),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
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

  Widget _textField(String hint, String? value, Function(String?) onChanged) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1976F3), width: 0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1976F3), width: 0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
      controller: TextEditingController(text: value ?? ''),
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
