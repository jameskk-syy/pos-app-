import 'dart:convert';
import 'package:flutter/material.dart' hide DataCell;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/users/create_staff.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/users/role_response.dart';
import 'package:pos/domain/responses/users/users_list.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';
import 'package:pos/presentation/biller/bloc/biller_bloc.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/models/biller_models.dart';
import 'package:pos/widgets/users/edit_staff.dart';
import 'package:pos/widgets/users/manage_user_roles.dart';
import 'package:pos/widgets/users/staff_multi_select_dialog.dart';
import 'package:pos/widgets/users/view_staff_widget.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/pages/widgets/staff_list_widgets.dart';
import 'package:pos/screens/pages/widgets/staff_form_widgets.dart';

class RegisterStaff extends StatefulWidget {
  const RegisterStaff({super.key});

  @override
  State<RegisterStaff> createState() => _RegisterStaffState();
}

class _RegisterStaffState extends State<RegisterStaff> {
  bool _showCreateStaff = false;
  bool _isObscure = true;
  List<Role> availableRolesList = [];
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> _selectedRoles = [];
  List<BillerProfile> _availableBillers = [];
  List<String> _selectedBillers = [];
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_filterStaff);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
      context.read<StaffBloc>().add(GetUserRoles());
      context.read<BillerBloc>().add(ListBillers(ListBillersRequest(limit: 100)));
    });
  }

  void _filterStaff() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) { _filteredStaffUsers = List.from(_staffUsers); }
      else { _filteredStaffUsers = _staffUsers.where((u) => u.fullName.toLowerCase().contains(query) || u.email.toLowerCase().contains(query) || u.phone.toLowerCase().contains(query)).toList(); }
    });
  }

  Future<void> _loadCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (!mounted || userString == null) {
      return;
    }
    setState(() => currentUserResponse = CurrentUserResponse.fromJson(jsonDecode(userString)));
    _loadStaff();
  }

  void _loadStaff() => context.read<StaffBloc>().add(GetUserListEvent(limit: _limit, offset: _currentOffset));
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }
  void _loadMore() { setState(() { _isLoading = true; _currentOffset += _limit; }); _loadStaff(); }
  void _refreshStaff() { setState(() { _currentOffset = 0; _staffUsers.clear(); _hasMore = true; }); _loadStaff(); }

  @override
  void dispose() {
    _scrollController.dispose(); _firstNameController.dispose(); _lastNameController.dispose();
    _emailController.dispose(); _phoneController.dispose(); _passwordController.dispose(); _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MultiBlocListener(
        listeners: [
          BlocListener<StaffBloc, StaffState>(listener: (context, state) {
            if (state is StaffStateSuccess) {
              setState(() { _isLoading = false; final newUsers = state.staffUser.message.staffUsers; if (newUsers.length < _limit) _hasMore = false; _totalStaff = state.staffUser.message.count; if (_currentOffset == 0) _staffUsers.clear(); _staffUsers.addAll(newUsers); _filterStaff(); });
            } else if (state is StaffUpdateSuccess || state is StaffRolesAssignSuccess) { _refreshStaff(); }
            else if (state is StaffCreateUser) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff user created successfully'), backgroundColor: Colors.green)); setState(() { _showCreateStaff = false; _resetForm(); }); _refreshStaff(); }
            else if (state is StaffRoleList) { setState(() => availableRolesList = state.response.message.roles); }
            else if (state is StaffStateFailure) { setState(() => _isLoading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red)); }
          }),
          BlocListener<BillerBloc, BillerState>(listener: (context, state) {
            if (state is ListBillersLoaded) {
              setState(() => _availableBillers = state.response.billers);
            }
          }),
        ],
        child: Container(color: const Color(0xFFF6F8FB), padding: const EdgeInsets.all(16), child: _showCreateStaff ? _buildCreateStaffUI() : _buildUsersListUI()),
      ),
    );
  }

  Widget _buildUsersListUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaffListHeader(searchController: _searchController, onAddStaff: () => setState(() => _showCreateStaff = true)),
        const SizedBox(height: 16),
        Expanded(
          child: StaffTable(
            totalStaff: _totalStaff,
            child: _buildUserListContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserListContent() {
    final state = context.read<StaffBloc>().state;
    if (_staffUsers.isEmpty && state is StaffStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_staffUsers.isEmpty) {
      return const StaffEmptyState();
    }
    if (_filteredStaffUsers.isEmpty && _searchController.text.isNotEmpty) {
      return StaffEmptyState(searchQuery: _searchController.text);
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshStaff(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: _filteredStaffUsers.length + (_isLoading ? 1 : 0),
        itemBuilder: (_, index) {
          if (index == _filteredStaffUsers.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return StaffRow(staff: _filteredStaffUsers[index], onAction: _handleMenuAction);
        },
      ),
    );
  }

  Widget _buildCreateStaffUI() {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        return CreateStaffForm(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () { setState(() { _showCreateStaff = false; _resetForm(); }); }),
              const Text('Create New Staff User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          body: StaffFormLayout(
            firstNameController: _firstNameController,
            lastNameController: _lastNameController,
            emailController: _emailController,
            phoneController: _phoneController,
            passwordController: _passwordController,
            isObscure: _isObscure,
            onObscureTap: () => setState(() => _isObscure = !_isObscure),
            selectedRoles: _selectedRoles,
            selectedBillers: _selectedBillers,
            onRolesTap: () => _showMultiSelectRolesDialog(),
            onBillersTap: () => _showMultiSelectBillersDialog(),
            toggles: StaffTogglesSection(
              isEnabled: _isEnabled,
              sendWelcomeEmail: _sendWelcomeEmail,
              onEnabledChanged: (v) => setState(() => _isEnabled = v),
              onEmailChanged: (v) => setState(() => _sendWelcomeEmail = v),
            ),
            actions: StaffFormActions(
              isLoading: state is StaffStateLoading,
              onCancel: () { setState(() { _showCreateStaff = false; _resetForm(); }); },
              onCreate: () => _createStaffUser(),
            ),
          ),
        );
      },
    );
  }

  void _handleMenuAction(StaffMenuAction action, StaffUser staff) {
    switch (action) {
      case StaffMenuAction.viewDetails: showDialog(context: context, builder: (_) => ViewStaffDetailsDialog(staff: staff)); break;
      case StaffMenuAction.edit: showDialog(context: context, builder: (_) => BlocProvider.value(value: context.read<StaffBloc>(), child: EditStaffUserDialog(user: staff))); break;
      case StaffMenuAction.manange: _showManageRolesDialog(staff); break;
    }
  }

  void _showManageRolesDialog(StaffUser staff) {
    if (availableRolesList.isEmpty) {
      context.read<StaffBloc>().add(GetUserRoles());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading roles...'), duration: Duration(seconds: 1)));
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && availableRolesList.isNotEmpty) {
          _showManageRolesDialogNow(staff);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to load roles. Please try again.'),
              backgroundColor: Colors.red));
        }
      });
      return;
    }
    _showManageRolesDialogNow(staff);
  }

  void _showManageRolesDialogNow(StaffUser staff) {
    showDialog(context: context, builder: (context) => BlocProvider.value(value: this.context.read<StaffBloc>(), child: ManageRolesDialog(availableRoles: availableRolesList, currentRoles: staff.roles, staffName: staff.fullName, staffEmail: staff.email)));
  }

  Future<void> _showMultiSelectRolesDialog() async {
    final result = await showDialog<List<String>>(context: context, builder: (context) => StaffMultiSelectDialog(title: 'Select Staff Roles', availableItems: availableRolesList.map((r) => r.name).toList(), initialSelectedItems: _selectedRoles, searchHint: 'Search roles...'));
    if (result != null) {
      setState(() => _selectedRoles = result);
    }
  }

  Future<void> _showMultiSelectBillersDialog() async {
    final result = await showDialog<List<String>>(context: context, builder: (context) => StaffMultiSelectDialog(title: 'Select Allowed Branches', availableItems: _availableBillers.map((b) => b.name).toList(), initialSelectedItems: _selectedBillers, searchHint: 'Search branches...'));
    if (result != null) {
      setState(() => _selectedBillers = result);
    }
  }

  void _createStaffUser() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty || _selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields and select at least one role'), backgroundColor: Colors.red)); return;
    }
    final staffRequest = StaffUserRequest(email: _emailController.text, firstName: _firstNameController.text, lastName: _lastNameController.text, password: _passwordController.text, phone: _phoneController.text, roles: _selectedRoles, enabled: _isEnabled, sendWelcomeEmail: _sendWelcomeEmail, company: currentUserResponse!.message.company.companyName, billers: _selectedBillers.isNotEmpty ? _selectedBillers : null);
    context.read<StaffBloc>().add(CreateStaff(staffCreateRequest: staffRequest));
  }

  void _resetForm() {
    _firstNameController.clear(); _lastNameController.clear(); _emailController.clear(); _phoneController.clear(); _passwordController.clear();
    _selectedRoles.clear(); _selectedBillers.clear(); _isEnabled = true; _sendWelcomeEmail = false;
  }
}
