import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/widgets/common/responsive_table.dart';

class AssignedStaffBottomSheet extends StatefulWidget {
  final Warehouse store;
  final bool isTablet;
  final VoidCallback? onRefresh;

  const AssignedStaffBottomSheet({
    super.key,
    required this.store,
    required this.isTablet,
    this.onRefresh,
  });

  @override
  State<AssignedStaffBottomSheet> createState() =>
      _AssignedStaffBottomSheetState();
}

class _AssignedStaffBottomSheetState extends State<AssignedStaffBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allStaff = [];
  List<Map<String, dynamic>> _filteredStaff = [];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  void _loadStaff() {
    context.read<StaffBloc>().add(
      GetWarehouseStaff(warehouseName: widget.store.name),
    );
  }

  void _filterStaff(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStaff = List.from(_allStaff);
      } else {
        _filteredStaff = _allStaff
            .where(
              (staff) =>
                  staff['fullName'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  staff['email'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  void _showRemoveConfirmation(
    BuildContext context,
    String email,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Removal'),
        content: Text(
          'Are you sure you want to remove $name from ${widget.store.warehouseName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<StaffBloc>().add(
                RemoveStaffFromWarehouse(
                  email: email,
                  warehouseName: widget.store.name,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle buffer
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Staff Assigned to ${widget.store.warehouseName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search staff...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: _filterStaff,
                ),
              ),

              Expanded(
                child: BlocConsumer<StaffBloc, StaffState>(
                  listener: (context, state) {
                    if (state is WarehouseStaffLoaded) {
                      setState(() {
                        _allStaff = state.response.message.data
                            .map(
                              (s) => {
                                'name': s.name,
                                'fullName': s.fullName.isNotEmpty
                                    ? s.fullName
                                    : (s.name.isNotEmpty ? s.name : 'Unknown'),
                                'email': s.email,
                                'enabled': s.enabled == 1 ? 'Yes' : 'No',
                              },
                            )
                            .toList();
                        _filteredStaff = List.from(_allStaff);
                      });
                    } else if (state is StaffRemovalSuccess) {
                      if (widget.onRefresh != null) {
                        widget.onRefresh!();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is StaffStateLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is StaffStateFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${state.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadStaff,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_filteredStaff.isEmpty &&
                        state is WarehouseStaffLoaded) {
                      return const Center(
                        child: Text('No staff assigned to this warehouse.'),
                      );
                    }

                    return ResponsiveTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Enabled')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _filteredStaff
                          .map(
                            (staff) => DataRow(
                              cells: [
                                DataCell(Text(staff['fullName'] ?? '')),
                                DataCell(Text(staff['email'] ?? '')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: staff['enabled'] == 'Yes'
                                          ? Colors.green.withAlpha(10)
                                          : Colors.red.withAlpha(10),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      staff['enabled'] ?? '',
                                      style: TextStyle(
                                        color: staff['enabled'] == 'Yes'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Remove',
                                    onPressed: () {
                                      _showRemoveConfirmation(
                                        context,
                                        staff['email'] ?? '',
                                        staff['fullName'] ?? '',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
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
