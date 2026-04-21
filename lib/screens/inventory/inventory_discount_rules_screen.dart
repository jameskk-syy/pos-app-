import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:pos/screens/inventory/widgets/discount_rules_widgets.dart';

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
    if (currentUserResponse == null) return;

    context.read<StoreBloc>().add(
          GetAllStores(company: currentUserResponse!.message.company.name),
        );
  }

  void _loadDiscountRules({bool reset = false}) {
    if (currentUserResponse == null) return;

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
        if (_selectedDiscountType != null && rule.discountType != _selectedDiscountType) {
          return false;
        }

        if (_fromDate != null || _toDate != null) {
          DateTime? validFrom = rule.validFrom != null ? DateTime.tryParse(rule.validFrom!) : null;
          DateTime? validUpto = rule.validUpto != null ? DateTime.tryParse(rule.validUpto!) : null;

          if (_fromDate != null && validUpto != null) {
            if (validUpto.isBefore(DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day))) {
              return false;
            }
          }

          if (_toDate != null && validFrom != null) {
            if (validFrom.isAfter(DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59))) {
              return false;
            }
          }
        }
        return true;
      }).toList();
    });
  }

  void _applyFilters() => _loadDiscountRules(reset: true);

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
      builder: (context) => DiscountRuleActionMenu(
        rule: rule,
        onViewDetails: () {
          Navigator.pop(context);
          _showViewDetailsDialog(context, rule);
        },
        onEdit: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateDiscountRulePage(existingRule: rule),
            ),
          ).then((_) => _loadDiscountRules(reset: true));
        },
        onDeactivate: rule.isActive == 1 ? () {
          Navigator.pop(context);
          _showDisableConfirmationDialog(context, rule);
        } : null,
        onActivate: rule.isActive == 0 ? () {
          Navigator.pop(context);
          _showEnableConfirmationDialog(context, rule);
        } : null,
      ),
    );
  }

  void _showEnableConfirmationDialog(BuildContext context, InventoryDiscountRule rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Rule'),
        content: Text('Are you sure you want to activate "${rule.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<InventoryBloc>().add(EnableDiscountRule(request: EnableDiscountRuleRequest(name: rule.name)));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _showDisableConfirmationDialog(BuildContext context, InventoryDiscountRule rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Rule'),
        content: Text('Are you sure you want to deactivate "${rule.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<InventoryBloc>().add(DisableDiscountRule(request: DisableDiscountRuleRequest(name: rule.name)));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showViewDetailsDialog(BuildContext context, InventoryDiscountRule rule) {
    showDialog(context: context, builder: (context) => DiscountRuleDetailsDialog(rule: rule));
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load warehouses: ${state.error}'), backgroundColor: Colors.red));
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is GetInventoryDiscountRulesLoaded) {
              final apiRules = state.response.message.data.rules.map((e) => InventoryDiscountRule.fromApiModel(e)).toList();
              final pagination = state.response.message.data.pagination;
              setState(() {
                _isLoading = false;
                _allRules = apiRules;
                _hasMore = _currentPage < pagination.totalPages;
                _totalCount = pagination.total;
              });
              _applyLocalFilters();
            } else if (state is GetInventoryDiscountRulesError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load discount rules: ${state.message}'), backgroundColor: Colors.red));
            } else if (state is DisableDiscountRuleLoading || state is EnableDiscountRuleLoading) {
              setState(() => _isLoading = true);
            } else if (state is DisableDiscountRuleSuccess || state is EnableDiscountRuleSuccess) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state is DisableDiscountRuleSuccess ? 'Discount rule deactivated successfully' : 'Discount rule activated successfully'), backgroundColor: Colors.green));
              _loadDiscountRules(reset: true);
            } else if (state is DisableDiscountRuleError || state is EnableDiscountRuleError) {
              setState(() => _isLoading = false);
              final error = state is DisableDiscountRuleError ? state.message : (state as EnableDiscountRuleError).message;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Inventory Discount Rules", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              Text(_totalCount > 0 ? "Showing ${_rules.length} of $_totalCount rules" : "Manage inventory discount rules", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: Colors.black), onPressed: () { _loadWarehouses(); _loadDiscountRules(reset: true); }, tooltip: 'Refresh'),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateDiscountRulePage())).then((_) => _loadDiscountRules(reset: true));
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Create Rule", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976F3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DiscountRulesFilters(
                isExpanded: _isFilterExpanded,
                onToggleExpand: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
                selectedRuleType: _selectedRuleType,
                ruleTypeOptions: _ruleTypeOptions,
                onRuleTypeChanged: (value) => setState(() => _selectedRuleType = value),
                warehouses: _warehouses,
                selectedWarehouse: _selectedWarehouse,
                onWarehouseChanged: (value) => setState(() => _selectedWarehouse = value),
                discountTypeOptions: _discountTypeOptions,
                selectedDiscountType: _selectedDiscountType,
                onDiscountTypeChanged: (value) => setState(() => _selectedDiscountType = value),
                statusOptions: _statusOptions,
                selectedStatus: _selectedStatus,
                onStatusChanged: (value) {
                  final selectedOption = _statusOptions.firstWhere((s) => s['label'] == value);
                  setState(() => _selectedStatus = selectedOption['value']);
                },
                searchTerm: _searchTerm,
                onSearchChanged: (value) => setState(() => _searchTerm = value),
                fromDate: _fromDate,
                toDate: _toDate,
                onSelectFromDate: () => _selectDate(context, true),
                onSelectToDate: () => _selectDate(context, false),
                onReset: _resetFilters,
                onApply: _applyFilters,
                warehousesLoaded: _warehousesLoaded,
              ),
              const SizedBox(height: 16),
              DiscountRulesTable(
                isLoading: _isLoading,
                rules: _rules,
                onActionMenu: (rule) => _showActionMenu(context, rule),
              ),
              if (_hasMore && !_isLoading) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () { setState(() => _currentPage++); _loadDiscountRules(); },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976F3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Padding(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12), child: Text("Load More", style: TextStyle(color: Colors.white))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
