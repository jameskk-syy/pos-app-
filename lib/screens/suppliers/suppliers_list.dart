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
  List<String> disabledOptions = ["All", "Active", "Disabled"];
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
    selectedDisabledStatus = null;
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
        searchTerm: _searchController.text.isEmpty
            ? null
            : _searchController.text,
        supplierGroup: selectedSupplierGroup == "All"
            ? null
            : selectedSupplierGroup,
        company: currentUserResponse!.message.company.name,
        limit: _limit,
        offset: _currentOffset,
        supplierType: selectedSupplierType == "All"
            ? null
            : selectedSupplierType,
        country: selectedCountry == "All" ? null : selectedCountry,
        disabled: selectedDisabledStatus,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
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
        _currentOffset = 0; // Reset to first page on filter change
        _suppliers.clear();
        _hasMore = true;
      });
      _loadSuppliers();
    });
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

  DataRow _buildSupplierRow(Supplier supplier, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                supplier.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                supplier.supplierName,
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
              color: supplier.supplierType == "Company"
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              supplier.supplierType,
              style: TextStyle(
                color: supplier.supplierType == "Company"
                    ? const Color(0xFF166534)
                    : const Color(0xFF1E40AF),
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            supplier.supplierGroup ?? "N/A",
            style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black),
          ),
        ),
        DataCell(
          Text(
            supplier.country,
            style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.black),
          ),
        ),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: supplier.disabled == 1
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              supplier.disabled == 1 ? "Disabled" : "Active",
              style: TextStyle(
                color: supplier.disabled == 1
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF059669),
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              //               IconButton(
              //                 icon: Icon(Icons.remove_red_eye, size: isMobile ? 16 : 18),
              //                 onPressed: () {
              //                   _showSupplierDetails(supplier, context);
              //                 },
              //               ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: isMobile ? 16 : 18),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddSupplierPage(supplier: supplier),
                      ),
                    ).then((_) => _loadSuppliers());
                  } else if (value == 'view') {
                    _showSupplierDetails(supplier, context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text('View'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSupplierDetails(Supplier supplier, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Supplier Details",
          style: TextStyle(fontSize: isMobile ? 16 : 18, color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow("Supplier ID:", supplier.name, context),
              _detailRow("Supplier Name:", supplier.supplierName, context),
              _detailRow("Supplier Type:", supplier.supplierType, context),
              _detailRow(
                "Supplier Group:",
                supplier.supplierGroup ?? "N/A",
                context,
              ),
              _detailRow("Tax ID:", supplier.taxId ?? "N/A", context),
              _detailRow("Country:", supplier.country, context),
              _detailRow(
                "Default Currency:",
                supplier.defaultCurrency ?? "N/A",
                context,
              ),
              _detailRow(
                "Status:",
                supplier.disabled == 1 ? "Disabled" : "Active",
                context,
              ),
              _detailRow(
                "Internal Supplier:",
                supplier.isInternalSupplier == 1 ? "Yes" : "No",
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
    _scrollController.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    final double padding = isMobile ? 12.0 : 16.0;

    return Scaffold(
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
              "Suppliers",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 16 : 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "View and manage all suppliers",
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: isMobile ? 20 : 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSupplierPage(),
                ),
              ).then((_) => _loadSuppliers());
            },
          ),
        ],
      ),
      body: BlocConsumer<SuppliersBloc, SuppliersState>(
        listener: (context, state) {
          if (state is SuppliersLoaded) {
            setState(() {
              _isLoading = false;
              final newSuppliers = state.response.data.suppliers;
              if (newSuppliers.length < _limit) {
                _hasMore = false;
              }
              _totalSuppliers = state.response.data.count;
              if (_currentOffset == 0) {
                _suppliers.clear();
              }
              _suppliers.addAll(newSuppliers);
            });
          } else if (state is SuppliersError) {
            setState(() {
              _isLoading = false;
            });
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
            controller: _scrollController,
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
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
                        if (isMobile) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _input(
                                  "Search Supplier",
                                  TextFormField(
                                    controller: _searchController,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      color: Colors.black,
                                    ),
                                    decoration:
                                        _decoration(
                                          "Search by name, tax ID...",
                                          context,
                                        ).copyWith(
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              Icons.search,
                                              size: isMobile ? 16 : 18,
                                              color: Colors.grey[700],
                                            ),
                                            onPressed: () {
                                              _onFilterChanged();
                                            },
                                          ),
                                        ),
                                    onChanged: (value) => _onFilterChanged(),
                                  ),
                                  context,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 4.0 : 6.0,
                                  ),
                                  child: _input(
                                    "Supplier Group",
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: selectedSupplierGroup,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      decoration: _decoration(
                                        "Select group",
                                        context,
                                      ),
                                      items: supplierGroups.map((group) {
                                        return DropdownMenuItem<String>(
                                          value: group,
                                          child: Text(
                                            group,
                                            style: TextStyle(
                                              fontSize: isMobile ? 13 : 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedSupplierGroup = value;
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
                          Row(
                            children: [
                              Expanded(
                                child: _input(
                                  "Supplier Type",
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: selectedSupplierType,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      color: Colors.black,
                                    ),
                                    decoration: _decoration(
                                      "Select type",
                                      context,
                                    ),
                                    items: supplierTypes.map((type) {
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
                                        selectedSupplierType = value;
                                      });
                                      _onFilterChanged();
                                    },
                                  ),
                                  context,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 4.0 : 6.0,
                                  ),
                                  child: _input(
                                    "Country",
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: selectedCountry,
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      decoration: _decoration(
                                        "Select country",
                                        context,
                                      ),
                                      items: countries.map((country) {
                                        return DropdownMenuItem<String>(
                                          value: country,
                                          child: Text(
                                            country,
                                            style: TextStyle(
                                              fontSize: isMobile ? 13 : 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCountry = value;
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
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _input(
                                  "Search Supplier",
                                  TextFormField(
                                    controller: _searchController,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    decoration:
                                        _decoration(
                                          "Search by name...",
                                          context,
                                        ).copyWith(
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              Icons.search,
                                              size: 18,
                                              color: Colors.grey[700],
                                            ),
                                            onPressed: () {
                                              _onFilterChanged();
                                            },
                                          ),
                                        ),
                                    onChanged: (value) => _onFilterChanged(),
                                  ),
                                  context,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _input(
                                  "Supplier Group",
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: selectedSupplierGroup,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    decoration: _decoration(
                                      "Select group",
                                      context,
                                    ),
                                    items: supplierGroups.map((group) {
                                      return DropdownMenuItem<String>(
                                        value: group,
                                        child: Text(
                                          group,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSupplierGroup = value;
                                      });
                                      _onFilterChanged();
                                    },
                                  ),
                                  context,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _input(
                                  "Supplier Type",
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: selectedSupplierType,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    decoration: _decoration(
                                      "Select type",
                                      context,
                                    ),
                                    items: supplierTypes.map((type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSupplierType = value;
                                      });
                                      _onFilterChanged();
                                    },
                                  ),
                                  context,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _input(
                                  "Country",
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: selectedCountry,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    decoration: _decoration(
                                      "Select country",
                                      context,
                                    ),
                                    items: countries.map((country) {
                                      return DropdownMenuItem<String>(
                                        value: country,
                                        child: Text(
                                          country,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCountry = value;
                                      });
                                      _onFilterChanged();
                                    },
                                  ),
                                  context,
                                ),
                              ),
                            ],
                          ),
                        ],

                        SizedBox(height: isMobile ? 12 : 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Reset Filters Button
                            OutlinedButton(
                              onPressed: _resetFilters,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.0,
                                ),
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

                            // Apply Filters Button
                            ElevatedButton(
                              onPressed: _loadSuppliers,
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
                      if ((state is SuppliersLoading ||
                              state is SupplierGroupsLoading) &&
                          _suppliers.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 20 : 40,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      // Loaded State
                      if (_suppliers.isNotEmpty) _buildSuppliersTable(context),

                      // Empty or Initial State
                      if (state is SuppliersInitial ||
                          (state is SuppliersLoaded && _suppliers.isEmpty))
                        _buildEmptyState(context),

                      // Error State
                      if (state is SuppliersError && _suppliers.isEmpty)
                        _buildErrorState(state.message, context),
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

  Widget _buildSuppliersTable(BuildContext context) {
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
                "Showing ${_suppliers.length} of $_totalSuppliers suppliers",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // Data Table
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: isMobile ? 0.0 : constraints.maxWidth,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF1F5F9),
                  ),
                  dataRowMinHeight: isMobile ? 40 : 56,
                  dataRowMaxHeight: isMobile ? 40 : 56,
                  columnSpacing: isMobile ? 12 : 24,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.black,
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        "Supplier Details",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Type",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Supplier Group",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Country",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Status",
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
                  rows: _suppliers
                      .map((supplier) => _buildSupplierRow(supplier, context))
                      .toList(),
                ),
              ),
            );
          },
        ),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
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
            Icons.people_outline,
            size: isMobile ? 48 : 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            "No suppliers found",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            "Try adjusting your filters or add a new supplier",
            style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              minimumSize: Size(isMobile ? 120 : 140, 40),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: isMobile ? 16 : 18),
                SizedBox(width: isMobile ? 4 : 8),
                Text(
                  "Add Supplier",
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 40),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: isMobile ? 48 : 64,
            color: Colors.red,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            "Error loading suppliers",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            message,
            style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ElevatedButton(
            onPressed: _loadSuppliers,
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
              "Retry",
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
