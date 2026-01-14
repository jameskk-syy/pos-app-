import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/requests/assign_staff_to_store.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/domain/responses/users_list.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/widgets/assign_staff_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffAssignmentPage extends StatefulWidget {
  const StaffAssignmentPage({super.key});

  @override
  State<StaffAssignmentPage> createState() => _StaffAssignmentPageState();
}

class _StaffAssignmentPageState extends State<StaffAssignmentPage> {
  CurrentUserResponse? currentUserResponse;
  late StoreBloc storeBloc;
  late StaffBloc staffBloc;
  bool _initialized = false;
  Map<String, String> assignedStaff = {};
  List<StaffUser> _staffList = [];
  bool _isLoadingStaff = false;
  String? _staffError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      storeBloc = context.read<StoreBloc>();
      staffBloc = getIt<StaffBloc>();
      _loadCurrentUser();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    staffBloc.close(); // Close StaffBloc when done
    super.dispose();
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

    storeBloc.add(GetAllStores(company: savedUser.message.company.name));
  }

  Future<void> _fetchStaffList() async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
    });

    // Add listener to staff bloc
    staffBloc.stream.listen((state) {
      if (state is StaffStateSuccess) {
        setState(() {
          _staffList = state.staffUser.message.staffUsers;
          _isLoadingStaff = false;
        });
      } else if (state is StaffStateFailure) {
        setState(() {
          _staffError = state.error;
          _isLoadingStaff = false;
        });
      } else if (state is StaffStateLoading) {
        setState(() {
          _isLoadingStaff = true;
        });
      }
    });

    // Trigger the event to fetch staff
    staffBloc.add(GetUserListEvent());
  }

  void _showStaffAssignmentDialog(Warehouse store) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    if (_staffList.isEmpty && !_isLoadingStaff) {
      _fetchStaffList();
    }

    if (isTablet) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600, // Increased for better tablet view
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: AssignStaffBottomSheet(
                store: store,
                staffList: _staffList,
                isLoading: _isLoadingStaff,
                errorMessage: _staffError,
                onAssign: (selectedStaff) {
                  _assignStaffToStore(selectedStaff, store);
                  Navigator.of(context).pop();
                },
                isTablet: true,
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.95,
            child: AssignStaffBottomSheet(
              store: store,
              staffList: _staffList,
              isLoading: _isLoadingStaff,
              errorMessage: _staffError,
              onAssign: (selectedStaff) {
                _assignStaffToStore(selectedStaff, store);
                Navigator.of(context).pop();
              },
              isTablet: false,
            ),
          );
        },
      );
    }
  }

  void _assignStaffToStore(List<StaffUser> staffList, Warehouse store) {
    if (staffList.isEmpty) return;

    for (var staff in staffList) {
      final request = AssignWarehousesRequest(
        userEmail: staff.email,
        warehouses: [store.name],
        replaceExisting: true,
      );

      staffBloc.add(AssignStaffToStore(assignWarehousesRequest: request));
    }

    setState(() {
      // Just showing the last assigned staff or maybe a count if multiple?
      // For now, let's just show comma separated names or similar if possible,
      // but the map is String->String.
      // Let's just show "Multiple Staff" if > 1, or name if 1.
      if (staffList.length == 1) {
        assignedStaff[store.name] = staffList.first.fullName.isNotEmpty
            ? staffList.first.fullName
            : staffList.first.name;
      } else {
        assignedStaff[store.name] = "${staffList.length} Staff Members";
      }
    });

    staffBloc.stream.listen(
      (state) {
        if (state is StaffAssignedSuccessful) {
          // We could show a success for each, but that might be spammy.
          // Maybe just rely on the UI updating.
        } else if (state is StaffStateFailure) {
          _showSnackBar('Failed to assign staff: ${state.error}', Colors.red);
          // Logic to remove from assignedStaff if failure is complex with multiple requests
          // For now leaving as is.
        }
      },
      onDone: () {},
      cancelOnError: true,
    );

    _showSnackBar(
      'Assigning ${staffList.length} staff to ${store.warehouseName}...',
      Colors.blue,
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _refreshPage() {
    if (currentUserResponse != null) {
      storeBloc.add(
        GetAllStores(company: currentUserResponse!.message.company.name),
      );
      _fetchStaffList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StaffBloc, StaffState>(
          bloc: staffBloc,
          listener: (context, state) {
            if (state is StaffStateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Staff Error: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Staff Assignment'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshPage,
              tooltip: 'Refresh stores and staff',
            ),
            if (_isLoadingStaff)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        body: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Stats/Info Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [],
          ),
        ),
        Expanded(child: _buildStoresList()),
      ],
    );
  }

  Widget _buildStoresList() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        if (state is StoreStateLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading stores...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (state is StoreStateFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading stores',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.error,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _refreshPage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is StoreStateSuccess) {
          final stores = state.storeGetResponse.message.data;

          if (stores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No stores found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add stores to start assigning staff',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshPage,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              int crossAxisCount;
              double childAspectRatio;
              EdgeInsets padding;
              double spacing;

              if (screenWidth >= 1200) {
                crossAxisCount = 4;
                childAspectRatio = 1.0;
                padding = const EdgeInsets.all(24);
                spacing = 20;
              } else if (screenWidth >= 900) {
                crossAxisCount = 3;
                childAspectRatio = 1.0;
                padding = const EdgeInsets.all(20);
                spacing = 16;
              } else if (screenWidth >= 600) {
                crossAxisCount = 2;
                childAspectRatio = 1.0;
                padding = const EdgeInsets.all(16);
                spacing = 12;
              } else {
                crossAxisCount = 2; // Two columns on mobile
                childAspectRatio = 0.8; // Adjusted aspect ratio for 2 columns
                padding = const EdgeInsets.all(12);
                spacing = 12;
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _refreshPage();
                  return Future.delayed(const Duration(seconds: 1));
                },
                child: Padding(
                  padding: padding,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      final isAssigned = assignedStaff.containsKey(store.name);

                      // Find the assigned staff details if any
                      String? assignedStaffName;
                      if (isAssigned) {
                        assignedStaffName = assignedStaff[store.name];
                      }

                      return StoreCardAssignment(
                        store: store,
                        isAssigned: isAssigned,
                        assignedStaffName: assignedStaffName,
                        onAssignStaff: () => _showStaffAssignmentDialog(store),
                        isTablet: screenWidth >= 600,
                      );
                    },
                  ),
                ),
              );
            },
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}

// Update StoreCardAssignment to show assigned staff name
class StoreCardAssignment extends StatelessWidget {
  final Warehouse store;
  final bool isAssigned;
  final String? assignedStaffName;
  final VoidCallback onAssignStaff;
  final bool isTablet;

  const StoreCardAssignment({
    super.key,
    required this.store,
    required this.isAssigned,
    this.assignedStaffName,
    required this.onAssignStaff,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onAssignStaff,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Store Name and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.warehouseName,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAssigned ? Icons.person : Icons.person_outline,
                              size: 12,
                              color: isAssigned
                                  ? Colors.green[800]
                                  : Colors.blue[800],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAssigned ? 'Assigned' : 'Unassigned',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isAssigned
                                    ? Colors.green[800]
                                    : Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),

              // Assigned Staff Info
              if (isAssigned && assignedStaffName != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.green[100],
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Staff',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              assignedStaffName!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isAssigned)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blue[100],
                        child: Icon(
                          Icons.person_add,
                          size: 16,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap to assign staff',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAssignStaff,
                  icon: Icon(
                    isAssigned ? Icons.swap_horiz : Icons.person_add,
                    size: 16,
                  ),
                  label: Text(
                    isAssigned ? 'Change Staff' : 'Assign Staff',
                    style: TextStyle(fontSize: isTablet ? 14 : 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    backgroundColor: isAssigned
                        ? Colors.orange[100]
                        : Colors.blue[100],
                    foregroundColor: isAssigned
                        ? Colors.orange[800]
                        : Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
