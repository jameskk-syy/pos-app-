import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/requests/users/assign_staff_to_store.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/users/users_list.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/widgets/users/assign_staff_dialog.dart';
import 'package:pos/widgets/users/assigned_staff_bottom_sheet.dart';
import 'package:pos/widgets/common/responsive_table.dart';
import 'package:pos/domain/repository/users_repo.dart';
import 'package:pos/core/services/storage_service.dart';

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
    staffBloc.close();
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

    storeBloc.add(GetAllStores(company: savedUser.message.company.name));
  }

  Future<void> _fetchStaffList() async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
    });

    // Trigger the event to fetch staff
    staffBloc.add(GetUserListEvent());
  }

  Future<void> _showStaffAssignmentDialog(Warehouse store) async {
    if (_staffList.isEmpty && !_isLoadingStaff) {
      _fetchStaffList();
    }

    Widget buildDialogContent(BuildContext context) {
      return BlocProvider.value(
        value: staffBloc,
        child: BlocBuilder<StaffBloc, StaffState>(
          builder: (context, state) {
            List<StaffUser> currentStaff = _staffList;
            bool isLoading = _isLoadingStaff;
            String? error = _staffError;

            if (state is StaffStateLoading) {
              isLoading = true;
            } else if (state is StaffStateSuccess) {
              isLoading = false;
              currentStaff = state.staffUser.message.staffUsers;
              // Update local state as well to keep it in sync
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _isLoadingStaff) {
                  setState(() {
                    _staffList = currentStaff;
                    _isLoadingStaff = false;
                  });
                }
              });
            } else if (state is StaffStateFailure) {
              isLoading = false;
              error = state.error;
            }

            return AssignStaffBottomSheet(
              store: store,
              staffList: currentStaff,
              isLoading: isLoading,
              errorMessage: error,
              onAssign: (selectedStaff) {
                _assignStaffToStore(selectedStaff, store);
                Navigator.of(context).pop();
              },
              isTablet: MediaQuery.of(context).size.width >= 600,
            );
          },
        ),
      );
    }

    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    if (isTablet) {
      await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: buildDialogContent(context),
            ),
          );
        },
      );
    } else {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.95,
            child: buildDialogContent(context),
          );
        },
      );
    }
    _refreshPage();
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

  void _onStoresLoaded(List<Warehouse> stores) {
    for (var store in stores) {
      _fetchStoreAssignment(store);
    }
  }

  Future<void> _fetchStoreAssignment(Warehouse store) async {
    try {
      final response = await getIt<UserListRepo>().getWarehouseStaff(
        store.name,
      );
      if (mounted) {
        setState(() {
          if (response.message.data.isNotEmpty) {
            if (response.message.data.length == 1) {
              assignedStaff[store.name] = response.message.data.first.fullName;
            } else {
              assignedStaff[store.name] =
                  "${response.message.data.length} Staff Members";
            }
          } else {
            assignedStaff.remove(store.name);
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching assignment for ${store.name}: $e");
    }
  }

  Future<void> _showViewAssignedStaffSheet(Warehouse store) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: staffBloc,
        child: AssignedStaffBottomSheet(
          store: store,
          isTablet: MediaQuery.of(context).size.width >= 600,
          onRefresh: _refreshPage,
        ),
      ),
    );
    _refreshPage();
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
            } else if (state is StaffStateSuccess) {
              setState(() {
                _staffList = state.staffUser.message.staffUsers;
                _isLoadingStaff = false;
              });
            } else if (state is StaffStateLoading) {
              setState(() {
                _isLoadingStaff = true;
              });
            } else if (state is StaffAssignedSuccessful) {
              _showSnackBar('Staff assigned successfully', Colors.green);
              _refreshPage();
            } else if (state is StaffRemovalSuccess) {
              _refreshPage();
            }
          },
        ),
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              _onStoresLoaded(state.storeGetResponse.message.data);
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

          return RefreshIndicator(
            onRefresh: () async {
              _refreshPage();
              return Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: ResponsiveTable(
                  columns: const [
                    DataColumn(label: Text('Store Name')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: stores.map((store) {
                    final isAssigned = assignedStaff.containsKey(store.name);

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            store.warehouseName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(Text(store.city ?? 'N/A')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAssigned
                                  ? Colors.green[50]
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isAssigned
                                    ? Colors.green[200]!
                                    : Colors.orange[200]!,
                              ),
                            ),
                            child: Text(
                              isAssigned ? 'Assigned' : 'Unassigned',
                              style: TextStyle(
                                color: isAssigned
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'assign') {
                                _showStaffAssignmentDialog(store);
                              } else if (value == 'view') {
                                _showViewAssignedStaffSheet(store);
                              }
                            },
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: 'assign',
                                child: Row(
                                  children: [
                                    Icon(Icons.person_add, size: 20),
                                    SizedBox(width: 8),
                                    Text('Assign Staff'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 20),
                                    SizedBox(width: 8),
                                    Text('View Assigned'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
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

// End of file
