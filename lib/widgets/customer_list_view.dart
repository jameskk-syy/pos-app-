import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/assign_loyalty_program_request.dart';
import 'package:pos/domain/requests/get_customer_request.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/widgets/assign_loyalty_program.dart';
import 'package:pos/widgets/points_widget_dialog.dart';
import 'package:pos/widgets/redeem_points_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerListView extends StatefulWidget {
  final VoidCallback onAddCustomer;
  final Function(Customer) onEditCustomer;

  const CustomerListView({
    super.key,
    required this.onAddCustomer,
    required this.onEditCustomer,
  });

  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  CurrentUserResponse? currentUserResponse;
  late CustomerRequest _searchRequest;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 20;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoading && _hasMore) {
        _loadMoreCustomers();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.dispose();
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

    _loadCustomers(reset: true);
  }

  void _loadCustomers({bool reset = false}) {
    if (_isLoading) return;

    if (reset) {
      setState(() {
        _customers.clear();
        _hasMore = true;
        _searchRequest = CustomerRequest(
          searchTerm: _searchController.text,
          customerGroup: '',
          territory: '',
          customerType: '',
          disabled: false,
          filterByCompanyTransactions: false,
          company: currentUserResponse!.message.company.name,
          limit: _limit,
          offset: 0,
        );
      });
    }

    setState(() {
      _isLoading = true;
    });

    context.read<CrmBloc>().add(
      GetAllCustomers(custmoerRequest: _searchRequest),
    );
  }

  void _loadMoreCustomers() {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _searchRequest.offset += _limit;
    });
    _loadCustomers();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _loadCustomers(reset: true);
    });
  }

  void _onMenuItemSelected(String value, Customer customer) {
    switch (value) {
      case 'attach_loyalty':
        _showAssignLoyaltyDialog(customer);
        break;
      case 'redeem_points':
        _showRedeemPointsDialog(customer);
        break;
      case 'view_point_history':
        showPointsHistoryBottomSheet(customer: customer, context: context);
        break;
    }
  }

  Future<void> _showRedeemPointsDialog(Customer customer) async {
    final crmBloc = context.read<CrmBloc>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider<CrmBloc>.value(
          value: crmBloc,
          child: RedeemPointsDialog(
            customerId: customer.name,
            customerName: customer.customerName,
          ),
        );
      },
    );

    if (result == true && mounted) {
      _refreshCustomerList();
    }
  }

  Future<bool?> showPointsHistoryBottomSheet({
    required BuildContext context,
    required Customer customer,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocProvider<CrmBloc>.value(
          value: context.read<CrmBloc>(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.90,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return PointsHistoryBottomSheet(customer: customer);
            },
          ),
        );
      },
    );
  }

  Future<void> _showAssignLoyaltyDialog(Customer customer) async {
    final inventoryBloc = context.read<InventoryBloc>();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return BlocProvider<InventoryBloc>.value(
          value: inventoryBloc,
          child: AssignLoyaltyDialog(
            customerName: customer.customerName,
            companyName: currentUserResponse?.message.company.name ?? '',
            onAssign: (programName) {
              Navigator.of(dialogContext).pop();
              final request = AssignLoyaltyProgramRequest(
                customerId: customer.name, // Use customer ID
                loyaltyProgramName: programName,
              );

              context.read<CrmBloc>().add(
                AssignLoyaltyProgram(request: request),
              );
            },
            onCancel: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrmBloc, CrmState>(
      listener: (context, state) {
        // Listen for Assign Loyalty Program events
        if (state is AssignLoyaltyProgramSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.message.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          _refreshCustomerList();
        } else if (state is AssignLoyaltyProgramError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign loyalty program: ${state.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: _buildContent(),
    );
  }

  void _refreshCustomerList() {
    _loadCustomers(reset: true);
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Expanded(child: _buildSearchField()),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: widget.onAddCustomer,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Customer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                      shadowColor: Colors.blue.withAlpha(20),
                    ),
                  ),
                ],
              ),
            ),
            _buildCustomersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search customers...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildCustomersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildCustomersList(),
        if (_isLoading && _customers.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomersList() {
    return BlocConsumer<CrmBloc, CrmState>(
      listener: (context, state) {
        if (state is CrmStateSuccess) {
          setState(() {
            _isLoading = false;
            final newCustomers = state.customerResponse.message.data;
            if (newCustomers.length < _limit) {
              _hasMore = false;
            }

            // Add new customers if not already in the list to avoid duplicates
            // Or simply append if offset logic is robust.
            // Since we control offset, appending is safe.
            // Check for potential strict equality or ID overlap if needed,
            // but for now simple append is standard for offset-based.

            // However, we must ensure we don't duplicate on re-renders/bloc rebuilds
            // from other events unless it's the specific GetAllCustomers success we triggered.
            // But CrmBloc emits CrmStateSuccess only on GetAllCustomers.

            // Wait, if we use BlocBuilder below, it will rebuild with valid state.
            // We need to synchronize _customers list with what Bloc gives us only when fetching.

            // To handle "append", we must rely on our internal _customers list accumulation.
            // If it's a reset (offset 0), we replace.
            if (_searchRequest.offset == 0) {
              _customers = newCustomers;
            } else {
              _customers.addAll(newCustomers);
            }
          });
        } else if (state is CrmStateFailure) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        // Handle Assign Loyalty Program loading state
        if (state is AssignLoyaltyProgramLoading) {
          // Keep showing current list if assigning loyalty
          if (_customers.isNotEmpty) return _buildCustomerTable(_customers);
        }

        if (state is CrmStateLoading && _customers.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is CrmStateFailure && _customers.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Failed to load customers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refreshCustomerList,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Display current customer list if available
        if (_customers.isNotEmpty) {
          return _buildCustomerTable(_customers);
        }

        if (state is CrmStateSuccess && _customers.isEmpty) {
          // Should have been caught by listener updating _customers,
          // but if empty response on first load:
          // Note: Builder runs after listener.
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'No customers found'
                      : 'No customers found for "${_searchController.text}"',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isEmpty
                      ? 'Add your first customer to get started'
                      : 'Try a different search term',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                if (_searchController.text.isEmpty)
                  ElevatedButton.icon(
                    onPressed: widget.onAddCustomer,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Customer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          );
        }

        // Initial state or unexpected
        return _isLoading
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox();
      },
    );
  }

  Widget _buildCustomerTable(List<Customer> customers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isTablet = width >= 600;

        // Define minimum widths to ensure content is readable
        // On mobile, use the available width to adhere to "remain how it was"
        final double minTableWidth = isTablet ? 1000.0 : width;
        // Use the larger of the screen width or the minimum table width
        final double tableWidth = width > minTableWidth ? width : minTableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Table(
              columnWidths: isTablet
                  ? const {
                      0: FlexColumnWidth(2), // Name
                      1: FlexColumnWidth(1), // Type
                      2: FlexColumnWidth(1), // Group
                      3: FlexColumnWidth(1), // Territory
                      4: FlexColumnWidth(1.2), // Mobile
                      5: FlexColumnWidth(1.5), // Email
                      6: FlexColumnWidth(1), // Outstanding
                      7: FixedColumnWidth(60), // Actions
                    }
                  : const {
                      0: FlexColumnWidth(2), // Name
                      1: FlexColumnWidth(1), // Type
                      2: FlexColumnWidth(1.5), // Mobile
                      3: FixedColumnWidth(60), // Actions
                    },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                bottom: BorderSide(color: Colors.grey.shade200),
                horizontalInside: BorderSide(color: Colors.grey.shade100),
              ),
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    _buildHeaderCell('Customer Name'),
                    _buildHeaderCell('Type'),
                    if (isTablet) ...[
                      _buildHeaderCell('Group'),
                      _buildHeaderCell('Territory'),
                    ],
                    _buildHeaderCell('Mobile'),
                    if (isTablet) ...[
                      _buildHeaderCell('Email'),
                      _buildHeaderCell('Outstanding'),
                    ],
                    _buildHeaderCell('Actions', align: TextAlign.center),
                  ],
                ),
                // Data Rows
                ...customers.map((customer) {
                  return TableRow(
                    children: [
                      _buildDataCell(
                        Text(
                          customer.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      _buildDataCell(
                        Text(
                          customer.customerType,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (isTablet) ...[
                        _buildDataCell(
                          Text(
                            customer.customerGroup ?? '-',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        _buildDataCell(
                          Text(
                            customer.territory ?? '-',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                      _buildDataCell(
                        Text(
                          customer.mobileNo ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (isTablet) ...[
                        _buildDataCell(
                          Text(
                            customer.emailId ?? '-',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        _buildDataCell(
                          Text(
                            customer.outstandingAmount.toStringAsFixed(2),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                      // Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'edit') {
                              widget.onEditCustomer(customer);
                            } else {
                              _onMenuItemSelected(value, customer);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'attach_loyalty',
                              child: Row(
                                children: [
                                  Icon(Icons.card_membership, size: 20),
                                  SizedBox(width: 8),
                                  Text('Attach Loyalty'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'redeem_points',
                              child: Row(
                                children: [
                                  Icon(Icons.redeem, size: 20),
                                  SizedBox(width: 8),
                                  Text('Redeem Points'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'view_point_history',
                              child: Row(
                                children: [
                                  Icon(Icons.history, size: 20),
                                  SizedBox(width: 8),
                                  Text('Point History'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text, {TextAlign align = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: child,
    );
  }
}
