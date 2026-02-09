import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/users/staff_assign_to_store.dart';
import 'package:pos/widgets/inventory/warehouse_list_view.dart';
import 'package:pos/widgets/inventory/warehouse_form.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double getResponsivePadding(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static EdgeInsets getResponsivePagePadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12.0);
    if (isTablet(context)) return const EdgeInsets.all(20.0);
    return const EdgeInsets.all(24.0);
  }
}

class StoreManagementPage extends StatefulWidget {
  const StoreManagementPage({super.key});

  @override
  State<StoreManagementPage> createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage> {
  String _currentView = 'list';
  CurrentUserResponse? currentUserResponse;
  Warehouse? warehouseToEdit;
  late StoreBloc storeBloc;
  bool _initialized = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      storeBloc = context.read<StoreBloc>();
      _loadCurrentUser();
      _initialized = true;
    }
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

  void _switchView(String view, {Warehouse? warehouse}) {
    setState(() {
      _currentView = view;
      warehouseToEdit = warehouse;
    });
  }

  void _handleFormSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          warehouseToEdit == null
              ? 'Warehouse created successfully!'
              : 'Warehouse updated successfully!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    _switchView('list');
    if (currentUserResponse != null) {
      storeBloc.add(
        GetAllStores(company: currentUserResponse!.message.company.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoreBloc, StoreState>(
      listener: (context, state) {
        if (state is StoreStateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: _currentView == 'list' ? _buildListView() : _buildFormView(),
      ),
    );
  }

  Widget _buildListView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveHelper.getResponsivePagePadding(
                context,
              ).copyWith(left: 0, right: 0),
              child: _buildHeader(),
            ),
            SizedBox(height: ResponsiveHelper.isMobile(context) ? 16 : 24),
            Expanded(
              child: WarehouseListView(
                currentUserResponse: currentUserResponse,
                onAddWarehouse: () => _switchView('form'),
                onEditWarehouse: (warehouse) =>
                    _switchView('form', warehouse: warehouse),
                searchQuery: _searchController.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SafeArea(
      child: Padding(
        padding: ResponsiveHelper.getResponsivePagePadding(context),
        child: WarehouseForm(
          warehouseToEdit: warehouseToEdit,
          currentUserResponse: currentUserResponse,
          onCancel: () => _switchView('list'),
          onSuccess: _handleFormSuccess,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search stores by name or type...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffAssignmentPage(),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text("Assign Staff"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _switchView('form'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("New Warehouse"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
