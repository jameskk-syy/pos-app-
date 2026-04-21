import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/crm/loyalty_history_models.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/widgets/crm/loyalty_points_widgets.dart';

class PointsHistoryBottomSheet extends StatefulWidget {
  final Customer customer;

  const PointsHistoryBottomSheet({super.key, required this.customer});

  @override
  State<PointsHistoryBottomSheet> createState() =>
      _PointsHistoryBottomSheetState();
}

class _PointsHistoryBottomSheetState extends State<PointsHistoryBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _sheetHeight = 0.5;
  final double _minHeight = 0.3;
  final double _maxHeight = 0.95;
  bool _isExpanded = false;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  final List<String> _typeOptions = ['All Types', 'Earn', 'Redeem'];

  int _currentPage = 1;
  final int _itemsPerPage = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLoyaltyHistory();
    });
  }

  void _fetchLoyaltyHistory() {
    context.read<CrmBloc>().add(
      GetLoyaltyHistory(
        customerId: widget.customer.name,
        page: _currentPage,
        limit: _itemsPerPage,
        transactionType: _selectedType == 'All Types' ? null : _selectedType,
      ),
    );
  }

  void _loadMore() {
    if (!_hasMoreData()) return;
    setState(() => _currentPage++);
    _fetchLoyaltyHistory();
  }

  bool _hasMoreData() {
    final state = context.read<CrmBloc>().state;
    if (state is LoyaltyHistoryLoaded) {
      return state.historyResponse.pagination.page <
          state.historyResponse.pagination.totalPages;
    }
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSheetHeight() {
    setState(() {
      _sheetHeight = _isExpanded ? _minHeight : _maxHeight;
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blue, onPrimary: Colors.white, onSurface: Colors.black),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.blue)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyFilters() {
    setState(() => _currentPage = 1);
    _fetchLoyaltyHistory();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filters applied'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = null;
      _currentPage = 1;
    });
    _fetchLoyaltyHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * _sheetHeight,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          LoyaltyHeader(customer: widget.customer, isExpanded: _isExpanded, onToggle: _toggleSheetHeight),
          if (_isExpanded) ...[
            LoyaltyFilterSection(
              startDate: _startDate, endDate: _endDate, selectedType: _selectedType, typeOptions: _typeOptions,
              onDateSelected: (date, isStart) => _selectDate(context, isStart),
              onTypeSelected: (val) => setState(() => _selectedType = val),
              onApply: _applyFilters, onClear: _clearFilters,
            ),
            _buildTransactionList(),
          ] else
            _buildCollapsedState(),
        ],
      ),
    );
  }

  Widget _buildCollapsedState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 48, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
              child: Icon(Icons.expand_less, color: Colors.blue[400], size: 24),
            ),
            const Text('Drag up to view filters and transactions', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<CrmBloc, CrmState>(
      builder: (context, state) {
        if (state is LoyaltyHistoryLoading && _currentPage == 1) {
          return const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        if (state is LoyaltyHistoryError) return _buildErrorState(state.error);
        if (state is LoyaltyHistoryLoaded) {
          final transactions = state.transactions;
          final pagination = state.historyResponse.pagination;
          return Expanded(
            child: Column(
              children: [
                _buildListHeader(state.historyResponse.filters.transactionType),
                if (transactions.isEmpty) _buildEmptyState() else _buildList(transactions, state),
                _buildPaginationFooter(pagination),
              ],
            ),
          );
        }
        return const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
      },
    );
  }

  Widget _buildListHeader(String? filterType) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          if (filterType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Text('Filter: $filterType', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue[700])),
            ),
        ],
      ),
    );
  }

  Widget _buildList(List<LoyaltyHistoryTransaction> transactions, LoyaltyHistoryLoaded state) {
    return Expanded(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: transactions.length + 1,
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            if (state is LoyaltyHistoryLoading && _currentPage > 1) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
            if (_hasMoreData()) return _buildLoadMoreButton();
            return Container();
          }
          return TransactionCard(transaction: transactions[index]);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: OutlinedButton(
          onPressed: _loadMore,
          style: OutlinedButton.styleFrom(foregroundColor: Colors.blue[500], side: BorderSide(color: Colors.blue[200]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
          child: const Text('Load More'),
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(Pagination pagination) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[100]!))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing ${pagination.page * pagination.limit > pagination.totalRecords ? pagination.totalRecords : pagination.page * pagination.limit} of ${pagination.totalRecords}', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(children: [const Text('Per page: ', style: TextStyle(fontSize: 12, color: Colors.grey)), Text(pagination.limit.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle), child: Icon(Icons.error_outline, size: 40, color: Colors.red[400])),
            const SizedBox(height: 20),
            const Text('Failed to load transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            Text(error, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _fetchLoyaltyHistory, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle), child: Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey[400])),
            const SizedBox(height: 20),
            const Text('No transactions found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const Text('Try adjusting your filters or dates', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
