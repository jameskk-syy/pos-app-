import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/presentation/roles/bloc/role_bloc.dart';
import 'package:pos/domain/responses/users/roles.dart';
import 'package:pos/widgets/users/create_role.dart';
import 'package:pos/widgets/users/role_details_dialog.dart';
import 'package:pos/screens/users/manage_role_permission.dart';

class RoleManagementPage extends StatefulWidget {
  const RoleManagementPage({super.key});

  @override
  State<RoleManagementPage> createState() => _RoleManagementPageState();
}

class _RoleManagementPageState extends State<RoleManagementPage> {
  final List<RoleData> _roles = [];
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadRoles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
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
      _currentPage++;
    });
    _loadRoles();
  }

  void _refreshRoles() {
    setState(() {
      _currentPage = 1;
      _roles.clear();
      _hasMore = true;
    });
    _loadRoles();
  }

  void _onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
      });
      _refreshRoles();
    });
  }

  void _loadRoles() {
    context.read<RoleBloc>().add(
      GetAllRoles(
        page: _currentPage,
        size: _pageSize,
        searchTerm: _searchQuery,
      ),
    );
  }

  void _navigateToCreateRole() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRolePage()),
    );

    // Refresh roles if role was created successfully
    if (result == true) {
      _refreshRoles();
    }
  }

  void _navigateToEditRole(RoleData role) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateRolePage(role: role)),
    );

    if (result == true) {
      _refreshRoles();
    }
  }

  void _showRoleDetailsDialog(RoleData role) {
    showDialog(
      context: context,
      builder: (context) => RoleDetailsDialog(role: role),
    );
  }

  void _handleDelete(String roleName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "$roleName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // context.read<RoleBloc>().add(DeleteRole(roleName: roleName));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Role deleted successfully')),
              );
              _refreshRoles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleDisable(String roleName, bool currentDisabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentDisabled ? 'Enable Role' : 'Disable Role'),
        content: Text(
          'Are you sure you want to ${currentDisabled ? 'enable' : 'disable'} "$roleName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (currentDisabled) {
                context.read<RoleBloc>().add(EnableRole(roleName: roleName));
              } else {
                context.read<RoleBloc>().add(DisableRole(roleName: roleName));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentDisabled ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(currentDisabled ? 'Enable' : 'Disable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        title: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search roles (e.g. Hr)...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.blue[600], size: 22),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _navigateToCreateRole,
              icon: const Icon(Icons.add),
              label: const Text('Create Role'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<RoleBloc, RoleState>(
        listener: (context, state) {
          if (state is RoleStateSuccess) {
            setState(() {
              _isLoading = false;
              final newRoles = state.roleResponse.message.data.roles;
              if (newRoles.length < _pageSize) {
                _hasMore = false;
              }
              if (_currentPage == 1) {
                _roles.clear();
              }
              _roles.addAll(newRoles);
            });
          } else if (state is RoleStateFailure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _loadRoles,
                ),
              ),
            );
          } else if (state is RoleActionSuccess) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _refreshRoles();
          }
        },
        builder: (context, state) {
          if (state is RoleStateLoading && _roles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_roles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No roles found',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreateRole,
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Role'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshRoles();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildRoleTable(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  dataRowColor: WidgetStateProperty.all(Colors.white),
                  horizontalMargin: 16,
                  columnSpacing: 20,
                  columns: _buildTableColumns(isMobile),
                  rows: _roles
                      .map((role) => _buildDataRow(role, isMobile))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildTableColumns(bool isMobile) {
    return [
      const DataColumn(
        label: Text('Role Name', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Users', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      if (!isMobile) ...[
        const DataColumn(
          label: Text('Custom', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text(
            'Desk Access',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      const DataColumn(
        label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  DataRow _buildDataRow(RoleData role, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: isMobile ? 120 : 200,
            child: Text(
              role.roleName,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(role.userCount.toString())),
        if (!isMobile) ...[
          DataCell(
            role.isCustomRole
                ? _buildDataTableBadge('Custom', Colors.purple)
                : const Text('-'),
          ),
          DataCell(
            role.hasDeskAccess
                ? _buildDataTableBadge('Enabled', Colors.blue)
                : const Text('-'),
          ),
        ],
        DataCell(
          role.isDisabled
              ? _buildDataTableBadge('Disabled', Colors.red)
              : _buildDataTableBadge('Active', Colors.green),
        ),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'view') {
                _showRoleDetailsDialog(role);
              } else if (value == 'edit') {
                _navigateToEditRole(role);
              } else if (value == 'permissions') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RolePermissionsPage(roleName: role.roleName),
                  ),
                );
              } else if (value == 'delete') {
                _handleDelete(role.name);
              } else if (value == 'disable') {
                _handleDisable(role.name, role.isDisabled);
              }
            },
            icon: const Icon(Icons.more_vert, size: 20),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'permissions',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Manage Permission'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'disable',
                child: Row(
                  children: [
                    Icon(
                      role.isDisabled
                          ? Icons.check_circle_outline
                          : Icons.block,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(role.isDisabled ? 'Enable' : 'Disable'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataTableBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
