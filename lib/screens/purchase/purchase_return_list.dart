import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/presentation/purchase/bloc/purchase_bloc.dart';
import 'package:pos/domain/responses/purchase/list_purchase_returns_response.dart';
import 'dart:convert';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/widgets/common/app_empty_state.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class PurchaseReturnListScreen extends StatefulWidget {
  const PurchaseReturnListScreen({super.key});

  @override
  State<PurchaseReturnListScreen> createState() => _PurchaseReturnListScreenState();
}

class _PurchaseReturnListScreenState extends State<PurchaseReturnListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  static const int _pageSize = 20;
  String company = '';
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _scrollController.addListener(_onScroll);
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

    _fetchReturns(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<PurchaseBloc>().state;
      if (state is PurchaseReturnsLoaded && !state.hasReachedMax) {
        _fetchReturns();
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _fetchReturns({bool isRefresh = false}) {
    if (isRefresh) {
      _currentPage = 1;
    } else {
      _currentPage++;
    }

    context.read<PurchaseBloc>().add(
          FetchPurchaseReturnsEvent(
            company: company.isEmpty ? 'Savanna' : company,
            page: _currentPage,
            pageSize: _pageSize,
            searchTerm: _searchController.text,
            isRefresh: isRefresh,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Purchase Returns',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<PurchaseBloc, PurchaseState>(
              builder: (context, state) {
                if (state is PurchaseReturnsLoading && _currentPage == 1) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PurchaseReturnsError && _currentPage == 1) {
                  return AppEmptyState(
                    title: 'No Data Available',
                    message: 'Something went wrong while fetching data.',
                    icon: Icons.error_outline,
                    buttonText: 'Retry',
                    onTapButton: () => _fetchReturns(isRefresh: true),
                  );
                }

                List<PurchaseReturnListItem> returns = [];
                bool hasReachedMax = false;

                if (state is PurchaseReturnsLoaded) {
                  returns = state.response.data.returns;
                  hasReachedMax = state.hasReachedMax;
                }

                if (returns.isEmpty && state is PurchaseReturnsLoaded) {
                  return const AppEmptyState(
                    title: 'No Returns Found',
                    message: 'Your purchase returns will appear here.',
                    icon: Icons.assignment_return_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _fetchReturns(isRefresh: true);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: hasReachedMax ? returns.length : returns.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= returns.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final item = returns[index];
                      return _buildReturnCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by ID or Supplier...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchReturns(isRefresh: true);
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          // Debounce could be added here
          _fetchReturns(isRefresh: true);
        },
      ),
    );
  }

  Widget _buildReturnCard(PurchaseReturnListItem item) {
    final NumberFormat currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
    
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to details if needed
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  _buildStatusBadge(item.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.blueAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.supplier,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Text(
                        item.postingDate,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Against PO',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Text(
                        item.returnAgainst,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Text(
                        currencyFormat.format(item.grandTotal.abs()),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'return':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
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
}
