import 'dart:convert';

import 'package:flutter/material.dart' hide DataCell;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_staff.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/role_response.dart';
import 'package:pos/domain/responses/users_list.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/widgets/edit_staff.dart';

import 'package:pos/widgets/manage_user_roles.dart';
import 'package:pos/widgets/view_staff_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StaffMenuAction { viewDetails, edit, manange }

class RegisterStaff extends StatefulWidget {
  const RegisterStaff({super.key});

  @override
  State<RegisterStaff> createState() => _RegisterStaffState();
}

class _RegisterStaffState extends State<RegisterStaff> {
  bool _showCreateStaff = false;
  bool _isObscure = true;
  Role? role;
  List<Role> availableRolesList = []; // Store fetched roles
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<String> _selectedRoles = [];
  bool _isEnabled = true;
  bool _sendWelcomeEmail = false;
  CurrentUserResponse? currentUserResponse;
  final List<StaffUser> _staffUsers = [];
  List<StaffUser> _filteredStaffUsers = [];
  int _currentOffset = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  int _totalStaff = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('RegisterStaff initState called');
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_filterStaff);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
      // Fetch roles on init
      context.read<StaffBloc>().add(GetUserRoles());
    });
  }

  void _filterStaff() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStaffUsers = List.from(_staffUsers);
      } else {
        _filteredStaffUsers = _staffUsers.where((user) {
          final fullName = user.fullName.toLowerCase();
          final email = user.email.toLowerCase();
          final phone = user.phone.toLowerCase();
          return fullName.contains(query) ||
              email.contains(query) ||
              phone.contains(query);
        }).toList();
      }
    });
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
    _loadStaff();
  }

  void _loadStaff() {
    context.read<StaffBloc>().add(
      GetUserListEvent(limit: _limit, offset: _currentOffset),
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
    _loadStaff();
  }

  void _refreshStaff() {
    setState(() {
      _currentOffset = 0;
      _staffUsers.clear();
      _hasMore = true;
    });
    _loadStaff();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'RegisterStaff build called, showCreateStaff: $_showCreateStaff',
    );

    return SafeArea(
      child: BlocListener<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is StaffStateSuccess) {
            setState(() {
              _isLoading = false;
              final newUsers = state.staffUser.message.staffUsers;
              if (newUsers.length < _limit) {
                _hasMore = false;
              }
              _totalStaff = state.staffUser.message.count;
              if (_currentOffset == 0) {
                _staffUsers.clear();
              }
              _staffUsers.addAll(newUsers);
              _filterStaff();
            });
          }
          // Handle staff update success
          else if (state is StaffUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            // Refresh the user list
            _refreshStaff();
          }
          // Handle staff create success
          else if (state is StaffCreateUser) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Staff user created successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            setState(() {
              _showCreateStaff = false;
              _resetForm();
            });
            _refreshStaff();
          }
          // Store available roles when loaded
          else if (state is StaffRoleList) {
            setState(() {
              availableRolesList = state.response.message.roles;
            });
          }
          // Handle failures
          else if (state is StaffStateFailure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: Container(
          color: const Color(0xFFF6F8FB),
          padding: const EdgeInsets.all(16),
          child: _showCreateStaff ? _createStaffUI() : _usersListUI(),
        ),
      ),
    );
  }

  Widget _usersListUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search staff...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 150,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint('Add Staff button pressed');
                  setState(() {
                    _showCreateStaff = true;
                  });
                },
                icon: const Icon(Icons.add, color: AppColors.white),
                label: const Text(
                  'Add Staff',
                  style: TextStyle(color: AppColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: _usersTable()),
      ],
    );
  }

  Widget _usersTable() {
    return BlocProvider.value(
      value: context.read<StaffBloc>(),
      child: BlocBuilder<StaffBloc, StaffState>(
        builder: (context, state) {
          debugPrint('StaffBloc state: $state');

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Users List ($_totalStaff)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _tableHeader(),
                      const Divider(),
                      Expanded(child: _buildUserList()),
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

  Widget _buildUserList() {
    if (_staffUsers.isEmpty &&
        context.read<StaffBloc>().state is StaffStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_staffUsers.isEmpty) {
      if (context.read<StaffBloc>().state is StaffStateLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            'Click "Add Staff" to create new users',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    }

    if (_filteredStaffUsers.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No users found matching "${_searchController.text}"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredStaffUsers.length + (_isLoading ? 1 : 0),
      itemBuilder: (_, index) {
        if (index == _filteredStaffUsers.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final staff = _filteredStaffUsers[index];
        return _staffRowWithData(staff);
      },
    );
  }

  Widget _tableHeader() {
    return Row(
      children: const [
        Expanded(
          flex: 2,
          child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 1,
          child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _staffRowWithData(StaffUser staff) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              staff.fullName,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: staff.enabled == 1 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  staff.enabled == 1 ? 'Active' : 'Inactive',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<StaffMenuAction>(
                color: Colors.white,
                onSelected: (action) {
                  _handleMenuAction(action, staff);
                },
                itemBuilder: (_) => [
                  _menuItem(
                    Icons.visibility,
                    'View Details',
                    StaffMenuAction.viewDetails,
                  ),
                  _menuItem(Icons.edit, 'Edit', StaffMenuAction.edit),
                  _menuItem(
                    Icons.assignment,
                    'Manage Roles',
                    StaffMenuAction.manange,
                  ),
                  // _menuItem(Icons.block, 'Disable', StaffMenuAction.disable),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<StaffMenuAction> _menuItem(
    IconData icon,
    String text,
    StaffMenuAction value,
  ) {
    return PopupMenuItem<StaffMenuAction>(
      value: value,
      child: Row(
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text)],
      ),
    );
  }

  void _handleMenuAction(StaffMenuAction action, StaffUser staff) {
    debugPrint('Menu action: $action for ${staff.name}');
    switch (action) {
      case StaffMenuAction.viewDetails:
        _openViewDetailsDialog(staff);
        break;
      case StaffMenuAction.edit:
        showEditStaffDialog(context, staff);
        break;
      // case StaffMenuAction.disable:
      //   _confirmDisableStaff(staff);
      //   break;
      case StaffMenuAction.manange:
        showManageRolesDialog(context, staff);
        break;
    }
  }

  void showManageRolesDialog(BuildContext context, StaffUser staff) {
    // If roles are not loaded yet, fetch them first
    if (availableRolesList.isEmpty) {
      context.read<StaffBloc>().add(GetUserRoles());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading roles...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Wait a bit and try again
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (availableRolesList.isNotEmpty) {
          // ignore: use_build_context_synchronously
          _showManageRolesDialogNow(context, staff);
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load roles. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      return;
    }

    _showManageRolesDialogNow(context, staff);
  }

  void _showManageRolesDialogNow(BuildContext context, StaffUser staff) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StaffBloc>(),
        child: ManageRolesDialog(
          availableRoles: availableRolesList,
          currentRoles: staff.roles,
          staffName: staff.fullName,
          staffEmail: staff.email,
        ),
      ),
    );
  }

  void _openViewDetailsDialog(StaffUser staff) {
    showDialog(
      context: context,
      builder: (_) => ViewStaffDetailsDialog(staff: staff),
    );
  }

  void showEditStaffDialog(BuildContext context, StaffUser user) {
    showDialog<StaffUser>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StaffBloc>(),
        child: EditStaffUserDialog(user: user),
      ),
    );
  }

  // void _confirmDisableStaff(StaffUser staff) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Disable Staff'),
  //       content: Text('Disable ${staff.name}?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           child: const Text('Disable'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _createStaffUI() {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {},
      builder: (context, state) {
        final roleNames = availableRolesList.map((role) => role.name).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    debugPrint('Back button pressed');
                    setState(() {
                      _showCreateStaff = false;
                      _resetForm();
                    });
                  },
                ),
                const Text(
                  'Create New Staff User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth > 600;

                    // Define the buttons row to reuse or inline
                    final buttonsRow = Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              debugPrint('Cancel button pressed');
                              setState(() {
                                _showCreateStaff = false;
                                _resetForm();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: state is StaffStateLoading
                                ? null
                                : () {
                                    _createStaffUser(context);
                                  },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: state is StaffStateLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Create',
                                    style: TextStyle(color: Colors.white),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );

                    // Define Toggles Row (Common)
                    final togglesRow = SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Switch(
                                value: _isEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isEnabled = value;
                                  });
                                },
                                activeThumbColor: Colors.white,
                                activeTrackColor: Colors.blueAccent,
                              ),
                              const Text('Enabled'),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Row(
                            children: [
                              Switch(
                                value: _sendWelcomeEmail,
                                onChanged: (value) {
                                  setState(() {
                                    _sendWelcomeEmail = value;
                                  });
                                },
                                activeThumbColor: Colors.white,
                                activeTrackColor: Colors.blueAccent,
                              ),
                              const Text('Send Welcome Email'),
                            ],
                          ),
                        ],
                      ),
                    );

                    if (isTablet) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _isObscure,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isObscure
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    await _showMultiSelectRolesDialog(
                                      roleNames,
                                    );
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Roles',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      _selectedRoles.isEmpty
                                          ? 'Choose roles'
                                          : _selectedRoles.join(', '),
                                      style: TextStyle(
                                        color: _selectedRoles.isEmpty
                                            ? Colors.grey.shade600
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          togglesRow,
                          const SizedBox(height: 24),
                          buttonsRow,
                        ],
                      );
                    }

                    // Mobile Layout
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            await _showMultiSelectRolesDialog(roleNames);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Roles',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _selectedRoles.isEmpty
                                  ? 'Choose roles'
                                  : _selectedRoles.join(', '),
                              style: TextStyle(
                                color: _selectedRoles.isEmpty
                                    ? Colors.grey.shade600
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        togglesRow,
                        const SizedBox(height: 24),
                        buttonsRow,
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMultiSelectRolesDialog(List<String> availableRoles) async {
    final List<String> tempSelectedRoles = List.from(_selectedRoles);

    await showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              insetPadding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
                  : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              title: const Text('Select Staff Roles'),
              content: SizedBox(
                width: isMobile ? screenWidth : 500,
                child: SingleChildScrollView(
                  child: ListBody(
                    children: availableRoles.map((role) {
                      return CheckboxListTile(
                        value: tempSelectedRoles.contains(role),
                        title: Text(role),
                        activeColor: Colors.blue,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              tempSelectedRoles.add(role);
                            } else {
                              tempSelectedRoles.remove(role);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _selectedRoles = tempSelectedRoles;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _createStaffUser(BuildContext context) {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields and select at least one role',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final staffRequest = StaffUserRequest(
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      roles: _selectedRoles,
      enabled: _isEnabled,
      sendWelcomeEmail: _sendWelcomeEmail,
      company: currentUserResponse!.message.company.name,
    );

    context.read<StaffBloc>().add(
      CreateStaff(staffCreateRequest: staffRequest),
    );
  }

  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _selectedRoles.clear();
    _isEnabled = true;
    _sendWelcomeEmail = false;
  }
}

// DataCell widget helper
class DataCell extends StatelessWidget {
  final String text;
  final double width;

  const DataCell(this.text, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
