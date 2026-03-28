import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/models/biller_models.dart';
import 'package:pos/presentation/biller/bloc/biller_bloc.dart';
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
  final int _currentLimit = 20;

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Branches / Billers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0.5,
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
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search branches...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.grey[50],
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                if (!isMobile) const SizedBox(width: 120),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchBillers(_searchController.text);
                await Future.delayed(const Duration(milliseconds: 500));
              },
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
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'No branches found',
                                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      margin: const EdgeInsets.all(0),
                      color: Colors.white,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                            columnSpacing: 20,
                            columns: [
                              const DataColumn(label: Text('Branch Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('Industry', style: TextStyle(fontWeight: FontWeight.bold))),
                              if (!isMobile)
                                const DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _billers.map((biller) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      biller.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BillerDetailPage(billerName: biller.name),
                                        ),
                                      );
                                    },
                                  ),
                                  DataCell(Text(biller.industry)),
                                  if (!isMobile) DataCell(Text(biller.company)),
                                  DataCell(_buildStatusBadge(biller)),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BillerDetailPage(billerName: biller.name),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BillerProfile biller) {
    final bool isDefault = biller.isDefault == 1;
    final color = isDefault ? Colors.green : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        isDefault ? 'DEFAULT' : 'ACTIVE',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
