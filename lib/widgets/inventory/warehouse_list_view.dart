import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/widgets/inventory/warehouse_detail_dialog.dart';

// Responsive helper class
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

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 3;
    return 4;
  }
}

class WarehouseListView extends StatefulWidget {
  final CurrentUserResponse? currentUserResponse;
  final VoidCallback onAddWarehouse;
  final Function(Warehouse) onEditWarehouse;
  final String searchQuery;

  const WarehouseListView({
    super.key,
    required this.currentUserResponse,
    required this.onAddWarehouse,
    required this.onEditWarehouse,
    this.searchQuery = '',
  });

  @override
  State<WarehouseListView> createState() => _WarehouseListViewState();
}

class _WarehouseListViewState extends State<WarehouseListView> {
  final ScrollController _scrollController = ScrollController();
  final List<Warehouse> _warehouses = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    final company = widget.currentUserResponse?.message.company.name;
    if (company == null) return;

    setState(() {
      _isLoading = true;
      _currentOffset += _limit;
    });

    context.read<StoreBloc>().add(
      GetAllStores(company: company, limit: _limit, offset: _currentOffset),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final filteredWarehouses = _warehouses.where((w) {
      if (widget.searchQuery.isEmpty) return true;
      final query = widget.searchQuery.toLowerCase();
      return w.warehouseName.toLowerCase().contains(query) ||
          (w.warehouseType?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BlocConsumer<StoreBloc, StoreState>(
            listener: (context, state) {
              if (state is StoreStateSuccess) {
                setState(() {
                  _isLoading = false;
                  final newWarehouses = state.storeGetResponse.message.data;
                  if (newWarehouses.length < _limit) {
                    _hasMore = false;
                  }

                  if (_currentOffset == 0) {
                    _warehouses.clear();
                  }
                  _warehouses.addAll(newWarehouses);
                });
              } else if (state is StoreStateFailure) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            builder: (context, state) {
              if (state is StoreStateLoading && _warehouses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is StoreStateFailure && _warehouses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: isMobile ? 48 : 64,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'Error loading warehouses',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 18,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          state.error,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 14,
                            ),
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (filteredWarehouses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warehouse_outlined,
                        size: isMobile ? 48 : 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        widget.searchQuery.isEmpty
                            ? 'No warehouses found'
                            : 'No matches found',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 18,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Text(
                        widget.searchQuery.isEmpty
                            ? 'Add your first warehouse to get started'
                            : 'Try a different search term',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 13,
                            tablet: 14,
                            desktop: 14,
                          ),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(child: _buildWarehouseTable(filteredWarehouses)),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showWarehouseDetails(BuildContext context, Warehouse warehouse) {
    showDialog(
      context: context,
      builder: (context) => WarehouseDetailDialog(
        warehouse: warehouse,
        onEdit: () {
          Navigator.pop(context);
          widget.onEditWarehouse(warehouse);
        },
      ),
    );
  }

  Widget _buildWarehouseTable(List<Warehouse> warehouses) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
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
                rows: warehouses
                    .map((warehouse) => _buildDataRow(warehouse, isMobile))
                    .toList(),
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
        label: Text(
          'Warehouse Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn(
        label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      if (!isMobile) ...[
        const DataColumn(
          label: Text('Parent', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const DataColumn(
          label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      const DataColumn(
        label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  DataRow _buildDataRow(Warehouse warehouse, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: isMobile ? 120 : 180,
            child: Text(
              warehouse.warehouseName,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(Text(warehouse.warehouseType ?? '-')),
        DataCell(
          SizedBox(
            width: isMobile ? 80 : 150,
            child: Text(warehouse.company, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (!isMobile) ...[
          DataCell(Text(warehouse.parentWarehouse ?? '-')),
          DataCell(
            SizedBox(
              width: 150,
              child: Text(
                [
                  warehouse.addressLine1,
                  warehouse.city,
                  warehouse.state,
                ].where((e) => e != null).join(', '),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          DataCell(_buildStatusBadges(warehouse)),
        ],
        DataCell(
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                widget.onEditWarehouse(warehouse);
              } else if (value == 'view') {
                _showWarehouseDetails(context, warehouse);
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadges(Warehouse warehouse) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (warehouse.isDefault) _buildDataTableBadge('Default', Colors.green),
        if (warehouse.disabled == 1)
          _buildDataTableBadge('Disabled', Colors.red),
        if (warehouse.isGroup == 1)
          _buildDataTableBadge('Group', Colors.purple),
        if (warehouse.isMainDepot) _buildDataTableBadge('Main', Colors.orange),
      ],
    );
  }

  Widget _buildDataTableBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
