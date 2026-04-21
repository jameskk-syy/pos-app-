import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/suppliers/suppliers_response.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
import 'package:pos/screens/suppliers/supplier_entry.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/suppliers/widgets/supplier_list_widgets.dart';

class SuppliersListPage extends StatefulWidget {
  const SuppliersListPage({super.key});

  @override
  State<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends State<SuppliersListPage> {
  String? selectedSupplierGroup;
  String? selectedSupplierType;
  String? selectedCountry;
  bool? selectedDisabledStatus;
  bool _isFiltersExpanded = true;
  Timer? _debounceTimer;

  final TextEditingController _searchController = TextEditingController();

  CurrentUserResponse? currentUserResponse;
  List<String> supplierGroups = ["All"];
  List<String> supplierTypes = ["All", "Company", "Individual"];
  List<String> countries = ["All", "Kenya", "Uganda", "Tanzania", "Rwanda"];
  int _currentOffset = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  int _totalSuppliers = 0;
  final List<Supplier> _suppliers = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedSupplierGroup = supplierGroups.first;
    selectedSupplierType = supplierTypes.first;
    selectedCountry = countries.first;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCurrentUser();
      }
    });
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

    _fetchSupplierGroups();
    _loadSuppliers();
  }

  void _fetchSupplierGroups() {
    context.read<SuppliersBloc>().add(GetSupplierGroups());
  }

  void _loadSuppliers() {
    if (currentUserResponse == null) return;

    context.read<SuppliersBloc>().add(
      GetSuppliers(
        searchTerm: _searchController.text.isEmpty ? null : _searchController.text,
        supplierGroup: selectedSupplierGroup == "All" ? null : selectedSupplierGroup,
        company: currentUserResponse!.message.company.name,
        limit: _limit,
        offset: _currentOffset,
        supplierType: selectedSupplierType == "All" ? null : selectedSupplierType,
        country: selectedCountry == "All" ? null : selectedCountry,
        disabled: selectedDisabledStatus,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    setState(() {
      _isLoading = true;
      _currentOffset += _limit;
    });
    _loadSuppliers();
  }

  void _resetFilters() {
    setState(() {
      selectedSupplierGroup = supplierGroups.first;
      selectedSupplierType = supplierTypes.first;
      selectedCountry = countries.first;
      selectedDisabledStatus = null;
      _currentOffset = 0;
      _suppliers.clear();
      _hasMore = true;
      _searchController.clear();
    });
    _loadSuppliers();
  }

  void _onFilterChanged() {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentOffset = 0;
        _suppliers.clear();
        _hasMore = true;
      });
      _loadSuppliers();
    });
  }

  void _showAddSupplier() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSupplierPage()),
    ).then((_) => _loadSuppliers());
  }

  void _showSupplierDetails(Supplier supplier) {
    showDialog(context: context, builder: (context) => SupplierDetailDialog(supplier: supplier));
  }

  void _editSupplier(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSupplierPage(supplier: supplier)),
    ).then((_) => _loadSuppliers());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Suppliers", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: isMobile ? 16 : 18)),
          Text("View and manage all suppliers", style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey)),
        ]),
        actions: [IconButton(icon: Icon(Icons.add, size: isMobile ? 20 : 24), onPressed: _showAddSupplier)],
      ),
      body: BlocConsumer<SuppliersBloc, SuppliersState>(
        listener: (context, state) {
          if (state is SuppliersLoaded) {
            setState(() {
              _isLoading = false;
              final newSuppliers = state.response.data.suppliers;
              if (newSuppliers.length < _limit) _hasMore = false;
              _totalSuppliers = state.response.data.count;
              if (_currentOffset == 0) _suppliers.clear();
              _suppliers.addAll(newSuppliers);
            });
          } else if (state is SupplierGroupsSuccess) {
            setState(() {
              supplierGroups = ["All", ...state.response.message.data.map((g) => g.name)];
            });
          } else if (state is SuppliersError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Column(
              children: [
                SupplierFilterSection(
                  isExpanded: _isFiltersExpanded,
                  onToggle: () => setState(() => _isFiltersExpanded = !_isFiltersExpanded),
                  searchController: _searchController,
                  selectedGroup: selectedSupplierGroup,
                  selectedType: selectedSupplierType,
                  selectedCountry: selectedCountry,
                  groups: supplierGroups,
                  types: supplierTypes,
                  countries: countries,
                  onGroupChanged: (val) => setState(() { selectedSupplierGroup = val; _onFilterChanged(); }),
                  onTypeChanged: (val) => setState(() { selectedSupplierType = val; _onFilterChanged(); }),
                  onCountryChanged: (val) => setState(() { selectedCountry = val; _onFilterChanged(); }),
                  onSearch: _onFilterChanged,
                  onReset: _resetFilters,
                  onApply: _loadSuppliers,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Column(
                    children: [
                      if ((state is SuppliersLoading || state is SupplierGroupsLoading) && _suppliers.isEmpty)
                        const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator())),
                      if (_suppliers.isNotEmpty)
                        SupplierDataTable(
                          suppliers: _suppliers,
                          totalCount: _totalSuppliers,
                          isLoading: _isLoading,
                          onView: _showSupplierDetails,
                          onEdit: _editSupplier,
                        ),
                      if (state is SuppliersInitial || (state is SuppliersLoaded && _suppliers.isEmpty))
                        SupplierEmptyState(onAdd: _showAddSupplier),
                      if (state is SuppliersError && _suppliers.isEmpty)
                        _buildErrorState(state.message),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text("Error loading suppliers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red)),
          Text(message, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSuppliers,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
