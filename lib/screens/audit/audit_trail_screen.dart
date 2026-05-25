import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/audit/bloc/audit_bloc.dart';
import 'package:pos/utils/themes/app_colors.dart';

import 'package:pos/screens/audit/widgets/audit_log_card.dart';
import 'package:pos/screens/audit/widgets/audit_filters.dart';
import 'package:pos/screens/audit/widgets/audit_summary_tab.dart';

class AuditTrailScreen extends StatelessWidget {
  const AuditTrailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuditBloc>(),
      child: const _AuditTrailBody(),
    );
  }
}

class _AuditTrailBody extends StatefulWidget {
  const _AuditTrailBody();

  @override
  State<_AuditTrailBody> createState() => _AuditTrailBodyState();
}

class _AuditTrailBodyState extends State<_AuditTrailBody> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  String? _company;
  String? _selectedActivityType;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  final List<String> _activityTypes = [
    'Create',
    'Update',
    'Delete',
    'Submit',
    'API Call',
  ];

  final List<String> _statuses = ['Success', 'Failed', 'Pending'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadCurrentUserAndFetch();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (!mounted) return;

    String? company;
    if (userString != null) {
      try {
        final userResponse = CurrentUserResponse.fromJson(
          jsonDecode(userString),
        );
        company = userResponse.message.company.name;
      } catch (_) {}
    }

    setState(() {
      _company = company;
    });

    _fetchLogs(isRefresh: true, overrideCompany: company);
    if (company != null) {
      context.read<AuditBloc>().add(FetchAuditStatistics(company: company));
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.9) {
      context.read<AuditBloc>().add(LoadMoreAuditLogs());
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 600), () {
      if (_searchController.text.trim() != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text.trim();
        });
        _fetchLogs(isRefresh: true);
      }
    });
  }

  void _fetchLogs({bool isRefresh = false, String? overrideCompany}) {
    context.read<AuditBloc>().add(
      FetchAuditLogs(
        isRefresh: isRefresh,
        company: overrideCompany ?? _company,
        activityType: _selectedActivityType,
        status: _selectedStatus,
        startDate: _startDate != null
            ? DateFormat('yyyy-MM-dd').format(_startDate!)
            : null,
        endDate: _endDate != null
            ? DateFormat('yyyy-MM-dd').format(_endDate!)
            : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchLogs(isRefresh: true);
    }
  }

  bool get _hasActiveFilters =>
      _selectedActivityType != null ||
      _selectedStatus != null ||
      _startDate != null ||
      _searchQuery.isNotEmpty;

  void _clearFilters() {
    setState(() {
      _selectedActivityType = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _fetchLogs(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.gray,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Audit Trail',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Logs'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildAuditTrailTab(), _buildSummaryTab()]),
      ),
    );
  }

  // ─── Audit Trail Tab ───────────────────────────────────────────────────────

  Widget _buildAuditTrailTab() {
    return Column(
      children: [
        AuditFilters(
          searchController: _searchController,
          searchQuery: _searchQuery,
          selectedActivityType: _selectedActivityType,
          selectedStatus: _selectedStatus,
          startDate: _startDate,
          endDate: _endDate,
          activityTypes: _activityTypes,
          statuses: _statuses,
          onFetchLogs: () => _fetchLogs(isRefresh: true),
          onClearFilters: _clearFilters,
          onSelectDateRange: _selectDateRange,
          onActivityTypeChanged: (v) {
            setState(() => _selectedActivityType = v);
            _fetchLogs(isRefresh: true);
          },
          onStatusChanged: (v) {
            setState(() => _selectedStatus = v);
            _fetchLogs(isRefresh: true);
          },
          onSearchQueryChanged: (v) {
            setState(() => _searchQuery = v);
          },
        ),
        Expanded(
          child: BlocBuilder<AuditBloc, AuditState>(
            builder: (context, state) {
              if (state is AuditInitial ||
                  (state is AuditLoading && state.isFirstFetch)) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                );
              }

              if (state is AuditFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load logs',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _fetchLogs(isRefresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is AuditLoaded) {
                if (state.logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No audit logs found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text(
                              'Clear Filters',
                              style: TextStyle(color: AppColors.blue),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _fetchLogs(isRefresh: true),
                  color: AppColors.blue,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: state.logs.length + (state.hasNext ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.logs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.blue,
                            ),
                          ),
                        );
                      }
                      return AuditLogCard(log: state.logs[index]);
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
  Widget _buildSummaryTab() {
    return AuditSummaryTab(company: _company);
  }
}
