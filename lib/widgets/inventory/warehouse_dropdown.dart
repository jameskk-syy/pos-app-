import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

class WarehouseSelectionBottomSheet extends StatefulWidget {
  final Warehouse? selectedWarehouse;
  final List<Warehouse> warehouses;
  final Function(Warehouse?) onWarehouseSelected;

  const WarehouseSelectionBottomSheet({
    super.key,
    required this.selectedWarehouse,
    required this.warehouses,
    required this.onWarehouseSelected,
  });

  @override
  State<WarehouseSelectionBottomSheet> createState() =>
      _WarehouseSelectionBottomSheetState();
}

class _WarehouseSelectionBottomSheetState
    extends State<WarehouseSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Warehouse> filteredWarehouses = [];
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    filteredWarehouses = widget.warehouses;
    // Fetch warehouses if list is empty
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
    });
    context.read<StoreBloc>().add(
      GetAllStores(company: savedUser.message.company.name),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWarehouses(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredWarehouses = widget.warehouses;
      } else {
        filteredWarehouses = widget.warehouses
            .where(
              (warehouse) => warehouse.warehouseName.toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterWarehouses('');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Warehouse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Search Field Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterWarehouses,
                        decoration: InputDecoration(
                          hintText: 'Search warehouses...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: _clearSearch,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.clear,
                              size: 24,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: BlocConsumer<StoreBloc, StoreState>(
                  listener: (context, state) {
                    if (state is StoreStateSuccess) {
                      setState(() {
                        filteredWarehouses =
                            state.storeGetResponse.message.data;
                      });
                    } else if (state is StoreStateFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.error}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is StoreInitial || state is StoreStateLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (filteredWarehouses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warehouse_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No warehouses found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state is StoreStateFailure
                                  ? state.error
                                  : 'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredWarehouses.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // "All Warehouses" Option
                          final isSelected = widget.selectedWarehouse == null;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.store_mall_directory,
                                color: isSelected ? Colors.blue : Colors.grey,
                              ),
                              title: Text(
                                'All Warehouses',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected ? Colors.blue : null,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                    )
                                  : null,
                              onTap: () {
                                widget.onWarehouseSelected(null);
                                Navigator.pop(context); // Also close the sheet
                              },
                            ),
                          );
                        }

                        final warehouse = filteredWarehouses[index - 1];
                        final isSelected =
                            warehouse == widget.selectedWarehouse;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade50
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Icon(
                              warehouse.isMainDepot
                                  ? Icons.home_work
                                  : Icons.warehouse,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                            title: Text(
                              warehouse.warehouseName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (warehouse.addressLine1 != null &&
                                    warehouse.addressLine1!.isNotEmpty)
                                  Text(
                                    warehouse.addressLine1!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                if (warehouse.city != null &&
                                    warehouse.state != null)
                                  Text(
                                    '${warehouse.city}, ${warehouse.state}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                if (warehouse.isDefault)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Default',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  )
                                : null,
                            onTap: () {
                              widget.onWarehouseSelected(warehouse);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
