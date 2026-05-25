import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';
import 'package:pos/screens/purchase/create_purchase_order.dart';
import 'package:pos/screens/purchase/purchase_order_details.dart';
import 'package:pos/presentation/suppliers/bloc/suppliers_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/screens/purchase/create_purchase_return_dialog.dart';
import 'package:pos/screens/purchase/widgets/purchase_order_list_widgets.dart';

class PurchaseOrdersPage extends StatefulWidget {
  const PurchaseOrdersPage({super.key});
  @override
  State<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends State<PurchaseOrdersPage> {
  final List<String> statusOptions = ['All', 'Draft', 'To Receive and Bill', 'To Bill', 'To Receive', 'Completed', 'Cancelled'];
  String selectedStatus = 'All';
  String? selectedSupplier;
  CurrentUserResponse? currentUserResponse;
  int currentPage = 1;
  final int itemsPerPage = 20;
  String company = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isWaitingForReturn = false, _isLoadingShown = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() { _searchController.dispose(); _searchDebounce?.cancel(); super.dispose(); }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) { setState(() => currentPage = 1); _loadPurchaseOrders(); }
    });
  }

  Future<void> _loadCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return;
    final savedUser = CurrentUserResponse.fromJson(jsonDecode(userString));
    if (!mounted) return;
    setState(() { currentUserResponse = savedUser; company = savedUser.message.company.name; });
    _loadPurchaseOrders();
    _fetchSuppliers();
  }

  void _fetchSuppliers({String? searchTerm}) { context.read<SuppliersBloc>().add(GetSuppliers(company: company, limit: 100, offset: 0, searchTerm: searchTerm)); }

  void _loadPurchaseOrders() {
    context.read<PurchaseBloc>().add(FetchPurchaseOrdersEvent(
      company: company, limit: itemsPerPage, offset: (currentPage - 1) * itemsPerPage,
      status: selectedStatus == 'All' || selectedStatus == '' ? null : selectedStatus,
      searchTerm: _searchController.text.trim(),
      filters: {'company': company, if (selectedSupplier != null) 'supplier': selectedSupplier},
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Purchase Orders'), backgroundColor: Colors.white, foregroundColor: Colors.blue, elevation: 0.5,
        actions: [ElevatedButton.icon(onPressed: _createNewOrder, icon: const Icon(Icons.add, size: 18), label: const Text('Create Order'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10))), const SizedBox(width: 8)],
      ),
      body: BlocListener<PurchaseBloc, PurchaseState>(
        listener: _handleBlocState,
        child: Column(
          children: [
            PurchaseOrderFilters(
              searchController: _searchController, selectedStatus: selectedStatus, selectedSupplier: selectedSupplier,
              onStatusTap: _showStatusFilter, onSupplierTap: _showSupplierFilter, onClear: _clearFilters,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => context.read<PurchaseBloc>().add(RefreshPurchaseOrdersEvent(company: company)),
                child: BlocBuilder<PurchaseBloc, PurchaseState>(
                  builder: (context, state) {
                    if (state is PurchaseLoading) return const Center(child: CircularProgressIndicator());
                    if (state is PurchaseError) return SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: SizedBox(height: MediaQuery.of(context).size.height * 0.7, child: PurchaseOrderErrorState(message: state.message, onRetry: _loadPurchaseOrders)));
                    if (state is PurchaseLoaded) {
                      final filtered = state.purchaseOrders.where((o) => selectedSupplier == null || o.supplier == selectedSupplier).toList();
                      if (filtered.isEmpty) return _emptyView();
                      return PurchaseOrderDataTable(
                        orders: filtered.map((d) => PurchaseOrderUIModel(poNumber: d.name, supplierName: d.supplier, status: d.status, totalAmount: d.grandTotal, orderDate: DateTime.parse(d.transactionDate), expectedDate: DateTime.parse(d.transactionDate).add(const Duration(days: 7)))).toList(),
                        onViewDetails: (o) => _viewOrderDetails(o.poNumber),
                        onAction: _handlePopupAction,
                        buildActions: _buildPopupMenuItems,
                      );
                    }
                    return _emptyView();
                  },
                ),
              ),
            ),
            BlocBuilder<PurchaseBloc, PurchaseState>(builder: (context, state) => state is PurchaseLoaded ? PurchaseOrderPagination(currentPage: currentPage, itemsPerPage: itemsPerPage, totalCount: state.totalCount, onPrevious: () => setState(() { currentPage--; _loadPurchaseOrders(); }), onNext: () => setState(() { currentPage++; _loadPurchaseOrders(); })) : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() => SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: SizedBox(height: MediaQuery.of(context).size.height * 0.7, child: PurchaseOrderEmptyState(onCreateStarted: _createNewOrder)));

  void _handleBlocState(BuildContext context, PurchaseState state) {
    if (state is PurchaseOrderDetailLoaded && _isWaitingForReturn) {
      _isWaitingForReturn = false;
      if (_isLoadingShown) { Navigator.pop(context); _isLoadingShown = false; }
      CreatePurchaseReturnDialog.show(context, state.response.purchaseOrder);
    } else if (state is PurchaseOrderDetailError && _isWaitingForReturn) {
      _isWaitingForReturn = false;
      if (_isLoadingShown) { Navigator.pop(context); _isLoadingShown = false; }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
    } else if (state is PurchaseReturnCreated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase return created successfully'), backgroundColor: Colors.green));
      _loadPurchaseOrders();
    }
  }

  void _showStatusFilter() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (context) => SingleChildScrollView(child: Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Select Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16), ...statusOptions.map((s) => ListTile(onTap: () { setState(() { selectedStatus = s; currentPage = 1; }); _loadPurchaseOrders(); Navigator.pop(context); }, leading: Icon(selectedStatus == s ? Icons.check_circle : Icons.circle_outlined, color: selectedStatus == s ? Colors.blue : Colors.grey), title: Text(s)))]))));
  }

  void _showSupplierFilter() {
    final search = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))), builder: (context) => StatefulBuilder(builder: (context, setModalState) => Container(padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Select Supplier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), if (selectedSupplier != null) TextButton(onPressed: () { setState(() => selectedSupplier = null); Navigator.pop(context); }, child: const Text('Clear'))]), const SizedBox(height: 16), TextField(controller: search, decoration: InputDecoration(hintText: 'Search suppliers...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 16)), onChanged: (v) => _fetchSuppliers(searchTerm: v)), const SizedBox(height: 16), Expanded(child: BlocBuilder<SuppliersBloc, SuppliersState>(builder: (context, state) { if (state is SuppliersLoading) return const Center(child: CircularProgressIndicator()); if (state is SuppliersLoaded) { final list = state.response.data.suppliers; return ListView.builder(shrinkWrap: true, itemCount: list.length, itemBuilder: (context, i) { final s = list[i]; return ListTile(onTap: () { setState(() { selectedSupplier = s.supplierName; currentPage = 1; }); _loadPurchaseOrders(); Navigator.pop(context); }, leading: Icon(selectedSupplier == s.supplierName ? Icons.check_circle : Icons.circle_outlined, color: selectedSupplier == s.supplierName ? Colors.blue : Colors.grey), title: Text(s.supplierName)); }); } return const SizedBox.shrink(); }))]))));
  }

  void _viewOrderDetails(String poNumber) async { await Navigator.pushNamed(context, '/purchase-order-details', arguments: poNumber); _loadPurchaseOrders(); }

  void _createNewOrder() async { if (await Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchaseOrderScreen())) == true) _loadPurchaseOrders(); }

  void _clearFilters() { setState(() { _searchController.clear(); selectedStatus = 'All'; selectedSupplier = null; currentPage = 1; }); _loadPurchaseOrders(); }

  List<PopupMenuItem<String>> _buildPopupMenuItems(PurchaseOrderUIModel o) {
    final s = o.status.toLowerCase();
    final items = <PopupMenuItem<String>>[];
    if (s == 'draft') items.add(const PopupMenuItem(value: 'submit', child: Row(children: [Icon(Icons.check_circle, size: 18, color: Colors.green), SizedBox(width: 8), Text('Submit')])));
    if (s != 'draft' && s != 'cancelled' && s != 'completed') items.add(const PopupMenuItem(value: 'create_grn', child: Row(children: [Icon(Icons.inventory, size: 18, color: Colors.purple), SizedBox(width: 8), Text('Create GRN')])));
    if (s != 'draft' && s != 'cancelled') items.add(const PopupMenuItem(value: 'create_return', child: Row(children: [Icon(Icons.assignment_return, size: 18, color: Colors.orange), SizedBox(width: 8), Text('Purchase Return')])));
    return items;
  }

  void _handlePopupAction(String action, PurchaseOrderUIModel o) {
    switch (action) {
      case 'submit': _confirmSubmit(o.poNumber); break;
      case 'create_return': _startReturn(o.poNumber); break;
      case 'create_grn': Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseOrderDetailScreen(poName: o.poNumber))); break;
    }
  }

  void _confirmSubmit(String poNumber) {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Submit Order'), content: Text('Are you sure you want to submit $poNumber? Once submitted, it cannot be edited.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () { Navigator.pop(context); context.read<PurchaseBloc>().add(SubmitPurchaseOrderEvent(lpoNo: poNumber)); _loadPurchaseOrders(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text('Submit'))]));
  }

  void _startReturn(String poNumber) { _isWaitingForReturn = true; _isLoadingShown = true; showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator())); context.read<PurchaseBloc>().add(FetchPurchaseOrderDetailEvent(poName: poNumber)); }
}
