import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/models/biller_models.dart';
import 'package:pos/presentation/biller/bloc/biller_bloc.dart';
import 'package:pos/widgets/biller/industry_helpers.dart';
import 'package:pos/screens/biller/create_biller_page.dart';
import 'package:pos/screens/biller/biller_detail_page.dart';

class BillerManagementPage extends StatefulWidget {
  const BillerManagementPage({super.key});

  @override
  State<BillerManagementPage> createState() => _BillerManagementPageState();
}

class _BillerManagementPageState extends State<BillerManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  List<BillerProfile> _billers = [];
  bool _hasReachedMax = false;
  final int _currentLimit = 20; // Reduced from 100 for better pagination demo/feel.


  @override
  void initState() {
    super.initState();
    _fetchBillers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_hasReachedMax) {
      _fetchMoreBillers();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }


  void _fetchBillers([String searchTerm = '']) {
    _hasReachedMax = false;
    context.read<BillerBloc>().add(
          ListBillers(ListBillersRequest(searchTerm: searchTerm, limit: _currentLimit, offset: 0)),
        );
  }

  void _fetchMoreBillers() {
    final state = context.read<BillerBloc>().state;
    if (state is ListBillersLoading || state is ListBillersMoreLoading) return;

    context.read<BillerBloc>().add(
          ListBillers(
            ListBillersRequest(
              searchTerm: _searchController.text,
              limit: _currentLimit,
              offset: _billers.length,
            ),
          ),
        );
  }


  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchBillers(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches / Billers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: 'Add New Biller',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateBillerPage()),
              );
              if (result == true && mounted) {
                // Wait briefly for backend to sync the newly created record
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  _fetchBillers(_searchController.text);
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchBillers(_searchController.text);
          // Wait briefly so spinner shows
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search branches...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                ),
              ),
            ),
            Expanded(
              child: BlocConsumer<BillerBloc, BillerState>(
                listener: (context, state) {
                  if (state is ListBillersLoaded) {
                    setState(() {
                      _billers = state.response.billers;
                      _hasReachedMax = state.hasReachedMax;
                    });
                  } else if (state is ListBillersError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ListBillersLoading && _billers.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_billers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No branches found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Responsive Grid
                  int crossAxisCount = 1;
                  if (MediaQuery.of(context).size.width >= 1200) {
                    crossAxisCount = 4;
                  } else if (MediaQuery.of(context).size.width >= 900) {
                    crossAxisCount = 3;
                  } else if (isTablet) {
                    crossAxisCount = 2;
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _hasReachedMax ? _billers.length : _billers.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= _billers.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final biller = _billers[index];
                      return _BillerCard(biller: biller);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillerCard extends StatelessWidget {
  final BillerProfile biller;

  const _BillerCard({required this.biller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BillerDetailPage(billerName: biller.name),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: getIndustryIcon(biller.industry),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      biller.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    IndustryBadge(industry: biller.industry),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
