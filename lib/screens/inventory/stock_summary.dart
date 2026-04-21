import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/inventory/stock_summary_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/inventory/create_stock_transfer.dart';
import 'package:pos/screens/inventory/stock_entry_page.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/screens/inventory/widgets/stock_summary_widgets.dart';

class StockSummaryPage extends StatefulWidget {
  const StockSummaryPage({super.key});

  @override
  State<StockSummaryPage> createState() => _StockSummaryPageState();
}

class _StockSummaryPageState extends State<StockSummaryPage> {
  CurrentUserResponse? currentUserResponse;
  late InventoryBloc inventoryBloc;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedWarehouse;
  String? _selectedItemGroup;
  bool _isFiltersExpanded = true;
  List<String> warehouseList = [];
  List<String> itemGroupList = [];

  @override
  void initState() {
    super.initState();
    inventoryBloc = getIt<InventoryBloc>();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    inventoryBloc.close();
    _searchController.dispose();
    super.dispose();
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

    inventoryBloc.add(
      GetStockSummary(
        company: savedUser.message.company.name,
        limit: 100,
        offset: 0,
      ),
    );
  }

  void _fetchWarehouses() {
    if (currentUserResponse == null) return;
    context.read<StoreBloc>().add(
      GetAllStores(company: currentUserResponse!.message.company.companyName),
    );
  }

  void _extractItemGroups(List<StockSummaryItem> items) {
    try {
      final groups = items.map((item) => item.itemGroup).toSet().toList();
      setState(() {
        itemGroupList = groups;
      });
    } catch (e) {
      setState(() {
        itemGroupList = [];
      });
    }
  }

  void _loadStockSummary() {
    if (currentUserResponse == null) return;
    inventoryBloc.add(
      GetStockSummary(
        company: currentUserResponse!.message.company.name,
        limit: 100,
        offset: 0,
        warehouse: _selectedWarehouse,
        itemGroup: _selectedItemGroup,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedWarehouse = null;
      _selectedItemGroup = null;
    });
    _loadStockSummary();
  }

  void _showItemDetails(StockSummaryItem item) {
    showDialog(
      context: context,
      builder: (context) => StockSummaryDetailDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final double padding = isMobile ? 12.0 : 16.0;

    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              try {
                final warehouses = state.storeGetResponse.message.data;
                setState(() {
                  warehouseList = warehouses
                      .where((wh) => wh.disabled == 0)
                      .map((wh) => wh.warehouseName)
                      .toList();
                  warehouseList.insert(0, "All Warehouses");
                });
              } catch (e) {
                setState(() { warehouseList = ["All Warehouses"]; });
              }
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is StockSummaryLoaded) {
              try {
                _extractItemGroups(state.response.data);
              } catch (e) {
                debugPrint('Error in StockSummaryLoaded listener: $e');
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Stock Summary",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: isMobile ? 8 : 16),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download, size: isMobile ? 16 : 18),
                label: Text("Export CSV", style: TextStyle(fontSize: isMobile ? 12 : 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 10),
                ),
              ),
            ),
          ],
        ),
        body: BlocConsumer<InventoryBloc, InventoryState>(
          bloc: inventoryBloc,
          listener: (context, state) {
            if (state is StockSummaryError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            }
          },
          builder: (context, state) {
            List<StockSummaryItem> items = [];
            bool isLoading = false;
            String? errorMessage;

            if (state is StockSummaryLoading) {
              isLoading = true;
            } else if (state is StockSummaryError) {
              errorMessage = state.message;
            } else if (state is StockSummaryLoaded) {
              try {
                items = state.response.data;
                if (warehouseList.isEmpty) _fetchWarehouses();
              } catch (e) {
                errorMessage = 'Error loading data';
              }
            }

            if (isLoading) return const Center(child: CircularProgressIndicator());
            if (errorMessage != null) return _buildErrorView(errorMessage);

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  StockSummaryFilters(
                    searchController: _searchController,
                    selectedWarehouse: _selectedWarehouse,
                    selectedItemGroup: _selectedItemGroup,
                    warehouseList: warehouseList,
                    itemGroupList: itemGroupList,
                    isFiltersExpanded: _isFiltersExpanded,
                    onToggleFilters: () => setState(() => _isFiltersExpanded = !_isFiltersExpanded),
                    onWarehouseChanged: (val) {
                      setState(() => _selectedWarehouse = val);
                      _loadStockSummary();
                    },
                    onItemGroupChanged: (val) {
                      setState(() => _selectedItemGroup = val);
                      _loadStockSummary();
                    },
                    onClearFilters: _clearFilters,
                    onApplyFilters: _loadStockSummary,
                    onLoadStockSummary: _loadStockSummary,
                  ),
                  SizedBox(height: isMobile ? 16 : 20),
                  _buildSummaryHeader(items.length, isMobile),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: items.isEmpty
                          ? _buildEmptyState(isMobile)
                          : StockSummaryTable(
                              items: items,
                              onViewDetails: _showItemDetails,
                              onAdjustItem: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StockEntryPage())),
                              onTransferItem: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StockTransfer())),
                            ),
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

  Widget _buildSummaryHeader(int count, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Items: $count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16)),
          Text('Showing: $count items', style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 12 : 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: isMobile ? 48 : 64, color: Colors.grey),
          SizedBox(height: isMobile ? 12 : 16),
          Text('No items found', style: TextStyle(color: Colors.grey, fontSize: isMobile ? 14 : 16)),
          SizedBox(height: isMobile ? 8 : 12),
          Text('Try adjusting your filters', style: TextStyle(color: Colors.grey, fontSize: isMobile ? 12 : 14)),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error', style: const TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadStockSummary, child: const Text('Retry')),
        ],
      ),
    );
  }
}
