import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/purchase/purchase_order_response.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';
import 'package:pos/screens/purchase/create_purchase_order.dart';
import 'package:pos/screens/purchase/purchase_order_details.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
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
}

class PurchaseOrdersPage extends StatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  State<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends State<PurchaseOrdersPage> {
  final List<String> statusOptions = [
    'All',
    'Draft',
    'To Receive and Bill',
    'To Bill',
    'To Receive',
    'Completed',
    'Cancelled',
  ];
  String selectedStatus = 'All';
  DateTime? selectedDate;
  String? selectedSupplier;
  CurrentUserResponse? currentUserResponse;
  // Removed hardcoded suppliers
  int currentPage = 1;
  final int itemsPerPage = 20;
  String company = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_searchDebounce?.isActive ?? false) {
        _searchDebounce!.cancel();
      }

      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            currentPage = 1;
          });
          _loadPurchaseOrders();
        }
      });
    });
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
      company = savedUser.message.company.name;
    });

    _loadPurchaseOrders();
    _fetchSuppliers();
  }

  void _fetchSuppliers({String? searchTerm}) {
    context.read<SuppliersBloc>().add(
      GetSuppliers(
        company: company,
        limit: 50,
        offset: 0,
        searchTerm: searchTerm,
      ),
    );
  }

  void _loadPurchaseOrders() {
    context.read<PurchaseBloc>().add(
      FetchPurchaseOrdersEvent(
        company: company,
        limit: itemsPerPage,
        offset: (currentPage - 1) * itemsPerPage,
        status: selectedStatus == 'All' || selectedStatus == ''
            ? null
            : selectedStatus,
        searchTerm: _searchController.text.trim(),
        filters: {
          'company': company,
          if (selectedSupplier != null) 'supplier': selectedSupplier,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.5,
        actions: [
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _createNewOrder,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search PO by ID or Name...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(child: _buildStatusFilterButton()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSupplierFilterButton()),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear_all, color: Colors.grey),
                        tooltip: 'Clear Filters',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<PurchaseBloc>().add(
                  RefreshPurchaseOrdersEvent(company: company),
                );
              },
              child: BlocBuilder<PurchaseBloc, PurchaseState>(
                builder: (context, state) {
                  if (state is PurchaseLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PurchaseError) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: _buildErrorState(state.message),
                      ),
                    );
                  } else if (state is PurchaseEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: _buildEmptyState(),
                      ),
                    );
                  } else if (state is PurchaseLoaded) {
                    final filteredOrders = _getFilteredOrders(
                      state.purchaseOrders,
                    );

                    if (filteredOrders.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: _buildEmptyState(),
                        ),
                      );
                    }

                    return _buildPurchaseTable(
                      filteredOrders
                          .map((data) => _convertToPurchaseOrder(data))
                          .toList(),
                    );
                  }
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: _buildEmptyState(),
                    ),
                  );
                },
              ),
            ),
          ),
          BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              if (state is PurchaseLoaded && state.purchaseOrders.isNotEmpty) {
                return _buildPagination(state.totalCount);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTable(List<PurchaseOrder> orders) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: Colors.white,
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
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 2,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              dataRowColor: WidgetStateProperty.all(Colors.white),
              horizontalMargin: 8,
              columnSpacing: 12,
              columns: _buildTableColumns(isMobile),
              rows: orders
                  .map((order) => _buildDataRow(order, isMobile))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns(bool isMobile) {
    return [
      const DataColumn(
        label: Text('PO Number', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataColumn(
        label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      if (!isMobile) ...[
        const DataColumn(
          label: Text(
            'Order Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const DataColumn(
          label: Text(
            'Expected',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const DataColumn(
          label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
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

  DataRow _buildDataRow(PurchaseOrder order, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            order.poNumber,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          onTap: () => _viewOrderDetails(order),
        ),
        DataCell(
          SizedBox(
            width: isMobile ? 100 : 150,
            child: Text(order.supplierName, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (!isMobile) ...[
          DataCell(Text(DateFormat('MMM dd, yyyy').format(order.orderDate))),
          DataCell(Text(DateFormat('MMM dd, yyyy').format(order.expectedDate))),
          DataCell(
            Text(
              '${order.currency} ${NumberFormat('#,##0.00').format(order.totalAmount)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        DataCell(_buildStatusBadge(order.status)),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (context) => _buildPopupMenuItems(order),
            onSelected: (value) => _handlePopupAction(value, order),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  PurchaseOrder _convertToPurchaseOrder(PurchaseOrderData data) {
    return PurchaseOrder(
      poNumber: data.name,
      supplierName: data.supplier,
      supplierCode: data.company,
      status: data.status,
      totalAmount: data.grandTotal,
      orderDate: DateTime.parse(data.transactionDate),
      expectedDate: DateTime.parse(
        data.transactionDate,
      ).add(const Duration(days: 7)),
      itemsCount: 0,
      progress: data.docstatus == 1 ? 1.0 : 0.0,
      currency: 'KES',
    );
  }

  Widget _buildStatusFilterButton() {
    return InkWell(
      onTap: _showStatusFilter,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedStatus,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  color: selectedStatus != 'All'
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierFilterButton() {
    return InkWell(
      onTap: () => _showSupplierFilter(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.business, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedSupplier ?? 'All Suppliers',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  color: selectedSupplier != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalCount) {
    final totalPages = (totalCount / itemsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${((currentPage - 1) * itemsPerPage) + 1} - ${currentPage * itemsPerPage > totalCount ? totalCount : currentPage * itemsPerPage} of $totalCount',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 1
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                        _loadPurchaseOrders();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                color: currentPage > 1 ? Colors.blue : Colors.grey[400],
                style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
              ),
              const SizedBox(width: 8),
              Text(
                'Page $currentPage of $totalPages',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: currentPage < totalPages
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                        _loadPurchaseOrders();
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                color: currentPage < totalPages
                    ? Colors.blue
                    : Colors.grey[400],
                style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Purchase Orders Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or create a new order',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewOrder,
            icon: const Icon(Icons.add),
            label: const Text('Create First Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _loadPurchaseOrders();
            },
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'to receive and bill':
        return Colors.orange;
      case 'to bill':
        return Colors.blue;
      case 'to receive':
        return Colors.purple;
      case 'received':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<PurchaseOrderData> _getFilteredOrders(List<PurchaseOrderData> orders) {
    return orders.where((order) {
      bool supplierMatch =
          selectedSupplier == null || order.supplier == selectedSupplier;
      bool dateMatch =
          selectedDate == null ||
          DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime.parse(order.transactionDate)) ==
              DateFormat('yyyy-MM-dd').format(selectedDate!);

      return supplierMatch && dateMatch;
    }).toList();
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...statusOptions.map((status) {
                  final isSelected = selectedStatus == status;
                  return ListTile(
                    onTap: () {
                      setState(() {
                        selectedStatus = status;
                        currentPage = 1;
                      });
                      _loadPurchaseOrders();
                      Navigator.pop(context);
                    },
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    title: Text(status),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSupplierFilter() {
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Supplier',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedSupplier != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedSupplier = null;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search suppliers...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      _fetchSuppliers(searchTerm: value);
                    },
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: BlocBuilder<SuppliersBloc, SuppliersState>(
                      builder: (context, state) {
                        if (state is SuppliersLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is SuppliersError) {
                          return Center(child: Text(state.message));
                        } else if (state is SuppliersLoaded) {
                          final suppliers = state.response.data.suppliers;

                          if (suppliers.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('No suppliers found'),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: suppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = suppliers[index];
                              final isSelected =
                                  selectedSupplier == supplier.supplierName;

                              return ListTile(
                                onTap: () {
                                  setState(() {
                                    selectedSupplier = supplier.supplierName;
                                    currentPage = 1;
                                  });
                                  _loadPurchaseOrders();
                                  Navigator.pop(context);
                                },
                                leading: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                                title: Text(supplier.supplierName),
                                subtitle: Text(supplier.name),
                                trailing: const Icon(
                                  Icons.business,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<PopupMenuItem<String>> _buildPopupMenuItems(PurchaseOrder order) {
    final isDraft = order.status.toLowerCase() == 'draft';
    final isCancelled = order.status.toLowerCase() == 'cancelled';
    final isCompleted = order.status.toLowerCase() == 'completed';

    final items = <PopupMenuItem<String>>[];

    // if (isDraft) {
    //   items.add(
    //     const PopupMenuItem(
    //       value: 'edit',
    //       child: Row(
    //         children: [
    //           Icon(Icons.edit, size: 18, color: Colors.blue),
    //           SizedBox(width: 8),
    //           Text('Edit'),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    if (isDraft) {
      items.add(
        const PopupMenuItem(
          value: 'submit',
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green),
              SizedBox(width: 8),
              Text('Submit'),
            ],
          ),
        ),
      );
    }

    // if (isDraft) {
    //   items.add(
    //     const PopupMenuItem(
    //       value: 'create_return',
    //       child: Row(
    //         children: [
    //           Icon(Icons.assignment_return, size: 18, color: Colors.orange),
    //           SizedBox(width: 8),
    //           Text('Create Return'),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    if (!isDraft && !isCancelled && !isCompleted) {
      items.add(
        const PopupMenuItem(
          value: 'create_grn',
          child: Row(
            children: [
              Icon(Icons.inventory, size: 18, color: Colors.purple),
              SizedBox(width: 8),
              Text('Create GRN'),
            ],
          ),
        ),
      );
    }

    if (!isDraft && !isCancelled) {
      items.add(
        const PopupMenuItem(
          value: 'create_return',
          child: Row(
            children: [
              Icon(Icons.assignment_return, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text('Purchase Return'),
            ],
          ),
        ),
      );
    }

    // items.addAll([
    //   const PopupMenuItem(
    //     value: 'print',
    //     child: Row(
    //       children: [
    //         Icon(Icons.print, size: 18, color: Colors.orange),
    //         SizedBox(width: 8),
    //         Text('Print'),
    //       ],
    //     ),
    //   ),
    // ]);

    // if (!isCancelled && !isCompleted) {
    //   items.add(
    //     const PopupMenuItem(
    //       value: 'cancel',
    //       child: Row(
    //         children: [
    //           Icon(Icons.cancel, size: 18, color: Colors.red),
    //           SizedBox(width: 8),
    //           Text('Cancel'),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    // items.add(
    //   const PopupMenuItem(
    //     value: 'delete',
    //     child: Row(
    //       children: [
    //         Icon(Icons.delete, size: 18, color: Colors.red),
    //         SizedBox(width: 8),
    //         Text('Delete'),
    //       ],
    //     ),
    //   ),
    // );

    return items;
  }

  void _handlePopupAction(String action, PurchaseOrder order) {
    switch (action) {
      case 'edit':
        _editOrder(order);
        break;
      case 'submit':
        _showSubmitConfirmation(order);
        break;
      case 'create_return':
        _createReturn(order);
        break;
      case 'create_grn':
        _createGRN(order);
        break;
      case 'duplicate':
        _duplicateOrder(order);
        break;
      case 'print':
        _printOrder(order);
        break;
      case 'cancel':
        _showCancelConfirmation(order);
        break;
      case 'delete':
        _showDeleteConfirmation(order);
        break;
    }
  }

  void _showSubmitConfirmation(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Purchase Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to submit purchase order ${order.poNumber}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Once submitted, the order cannot be edited.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitPurchaseOrder(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit Order'),
          ),
        ],
      ),
    );
  }

  void _submitPurchaseOrder(PurchaseOrder order) async {
    // Close the confirmation dialog
    Navigator.pop(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Dispatch the submit event to the BLoC
      context.read<PurchaseBloc>().add(
        SubmitPurchaseOrderEvent(lpoNo: order.poNumber),
      );

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.poNumber} submitted successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Refresh the list to show updated status
      _loadPurchaseOrders();
    } catch (error) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit order: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _createNewOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context2) => PurchaseOrderScreen()),
    );

    if (result == true) {
      _loadPurchaseOrders();
    }
  }

  Future<void> _viewOrderDetails(PurchaseOrder order) async {
    await Navigator.pushNamed(
      context,
      '/purchase-order-details',
      arguments: order,
    );
    _loadPurchaseOrders();
  }

  void _editOrder(PurchaseOrder order) {
    Navigator.pushNamed(context, '/edit-purchase-order', arguments: order);
  }

  void _duplicateOrder(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Order'),
        content: const Text('Create a copy of this purchase order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Duplicate'),
          ),
        ],
      ),
    );
  }

  void _printOrder(PurchaseOrder order) {}

  void _createReturn(PurchaseOrder order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Create Return for ${order.poNumber}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _createGRN(PurchaseOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context2) =>
            PurchaseOrderDetailScreen(poName: order.poNumber),
      ),
    );
  }

  void _showCancelConfirmation(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Purchase Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel purchase order ${order.poNumber}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order, 'Cancelled');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text(
          'Are you sure you want to delete this purchase order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadPurchaseOrders();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      selectedStatus = 'All';
      selectedSupplier = null;
      selectedDate = null;
      currentPage = 1;
    });
    _loadPurchaseOrders();
  }

  void _updateOrderStatus(PurchaseOrder order, String newStatus) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.poNumber} status updated to $newStatus'),
        backgroundColor: Colors.green,
      ),
    );
    _loadPurchaseOrders();
  }
}

class PurchaseOrder {
  final String poNumber;
  final String supplierName;
  final String supplierCode;
  String status;
  final double totalAmount;
  final DateTime orderDate;
  final DateTime expectedDate;
  final int itemsCount;
  final double progress;
  final String currency;

  PurchaseOrder({
    required this.poNumber,
    required this.supplierName,
    required this.supplierCode,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.expectedDate,
    required this.itemsCount,
    required this.progress,
    required this.currency,
  });
}
