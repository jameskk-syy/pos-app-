import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/models/audit_log.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/audit/bloc/audit_bloc.dart';
import 'package:pos/utils/themes/app_colors.dart';

import 'package:fl_chart/fl_chart.dart';

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

    _fetchLogs(isRefresh: true);
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

  void _fetchLogs({bool isRefresh = false}) {
    context.read<AuditBloc>().add(
      FetchAuditLogs(
        isRefresh: isRefresh,
        company: _company,
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
        _buildFilters(),
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
                      return _buildAuditCard(state.logs[index]);
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

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──
          TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search logs...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _fetchLogs(isRefresh: true);
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.blue),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          // ── Dropdown row ──
          Row(
            children: [
              // Activity type
              Expanded(
                child: _buildDropdown<String>(
                  hint: 'Activity Type',
                  value: _selectedActivityType,
                  items: _activityTypes,
                  onChanged: (v) {
                    setState(() => _selectedActivityType = v);
                    _fetchLogs(isRefresh: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Status
              Expanded(
                child: _buildDropdown<String>(
                  hint: 'Status',
                  value: _selectedStatus,
                  items: _statuses,
                  onChanged: (v) {
                    setState(() => _selectedStatus = v);
                    _fetchLogs(isRefresh: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Date range picker
              GestureDetector(
                onTap: () => _selectDateRange(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _startDate != null
                        ? AppColors.blue.withAlpha(20)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _startDate != null
                          ? AppColors.blue
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: _startDate != null
                            ? AppColors.blue
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _startDate == null
                            ? 'Dates'
                            : '${DateFormat('MMM d').format(_startDate!)} – ${DateFormat('MMM d').format(_endDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _startDate != null
                              ? AppColors.blue
                              : Colors.grey[700],
                          fontWeight: _startDate != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Active filter chips ──
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  if (_selectedActivityType != null)
                    _filterChip(_selectedActivityType!, () {
                      setState(() => _selectedActivityType = null);
                      _fetchLogs(isRefresh: true);
                    }),
                  if (_selectedStatus != null)
                    _filterChip(_selectedStatus!, () {
                      setState(() => _selectedStatus = null);
                      _fetchLogs(isRefresh: true);
                    }),
                  if (_startDate != null)
                    _filterChip(
                      '${DateFormat('MMM d').format(_startDate!)} – ${DateFormat('MMM d').format(_endDate!)}',
                      () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        _fetchLogs(isRefresh: true);
                      },
                    ),
                  if (_searchQuery.isNotEmpty)
                    _filterChip('"$_searchQuery"', () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      _fetchLogs(isRefresh: true);
                    }),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: value != null ? AppColors.blue.withAlpha(15) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value != null ? AppColors.blue : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: value != null ? AppColors.blue : Colors.grey,
          ),
          isDense: true,
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text(
                'All $hint',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blue.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.blue),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: AppColors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditCard(AuditLog log) {
    final date = DateTime.tryParse(log.creation);
    final formattedDate = date != null
        ? DateFormat('MMM d, yyyy HH:mm').format(date)
        : log.creation;

    final isSuccess = log.status == 'Success';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _getActivityColor(log.activityType).withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(log.activityType),
              color: _getActivityColor(log.activityType),
              size: 18,
            ),
          ),
          title: Text(
            log.activityDescription,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _infoChip(Icons.person_outline, log.user, Colors.grey),
                _infoChip(
                  Icons.access_time_outlined,
                  formattedDate,
                  Colors.grey,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSuccess
                          ? Colors.green.withAlpha(80)
                          : Colors.red.withAlpha(80),
                    ),
                  ),
                  child: Text(
                    log.status,
                    style: TextStyle(
                      color: isSuccess ? Colors.green[700] : Colors.red[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),
                  _buildDetailRow('Log ID', log.name),
                  if (log.referenceDoctype != null || log.referenceName != null)
                    _buildDetailRow(
                      'Reference',
                      '${log.referenceDoctype ?? 'N/A'}: ${log.referenceName ?? 'N/A'}',
                    ),
                  if (log.ipAddress != null)
                    _buildDetailRow('IP Address', log.ipAddress!),
                  _buildDetailRow(
                    'Exec Time',
                    '${log.executionTime?.toStringAsFixed(3) ?? '0'}s',
                  ),
                  if (log.metadata != null) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      'Endpoint',
                      log.metadata!['endpoint']?.toString() ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Method',
                      log.metadata!['method']?.toString() ?? 'N/A',
                    ),
                  ],
                  if (log.errorMessage != null)
                    _buildDetailRow('Error', log.errorMessage!, isError: true),
                  if (log.requestData != null) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Request Data:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        const JsonEncoder.withIndent(
                          '  ',
                        ).convert(log.requestData),
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Create':
        return Icons.add_circle_outline;
      case 'Update':
        return Icons.edit_note;
      case 'Delete':
        return Icons.delete_outline;
      case 'Submit':
        return Icons.send;
      case 'API Call':
        return Icons.api;
      default:
        return Icons.history;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'Create':
        return Colors.green;
      case 'Update':
        return Colors.orange;
      case 'Delete':
        return Colors.red;
      case 'Submit':
        return Colors.blue;
      case 'API Call':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // ─── Summary Tab ───────────────────────────────────────────────────────────

  Widget _buildSummaryTab() {
    return BlocBuilder<AuditBloc, AuditState>(
      builder: (context, state) {
        if (state is AuditLoading && state.isFirstFetch) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          );
        }
        if (state is AuditLoaded && state.statistics != null) {
          final stats = state.statistics!;
          return RefreshIndicator(
            color: AppColors.blue,
            onRefresh: () async {
              if (_company != null) {
                context.read<AuditBloc>().add(
                  FetchAuditStatistics(company: _company!),
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(stats),
                  const SizedBox(height: 16),
                  _buildChartsSection(stats),
                  const SizedBox(height: 16),
                  _buildTopUsersSection(stats),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }
        if (state is AuditFailure) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blue),
        );
      },
    );
  }

  Widget _buildStatsGrid(AuditStatistics stats) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 4 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Logs',
          stats.total.toString(),
          Icons.history,
          AppColors.blue,
        ),
        _buildStatCard(
          'Successful',
          stats.byStatus['Success']?.toString() ?? '0',
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildStatCard(
          'Failed',
          stats.byStatus['Failed']?.toString() ?? '0',
          Icons.error_outline,
          Colors.red,
        ),
        _buildStatCard(
          'Activity Types',
          stats.byActivityType.length.toString(),
          Icons.category_outlined,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(AuditStatistics stats) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: _buildPieChartCard('Status Distribution', stats.byStatus),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildPieChartCard('Activity Types', stats.byActivityType),
          ),
        ],
      );
    }
    return Column(
      children: [
        _buildPieChartCard('Status Distribution', stats.byStatus),
        const SizedBox(height: 16),
        _buildPieChartCard('Activity Types', stats.byActivityType),
      ],
    );
  }

  Widget _buildPieChartCard(String title, Map<String, int> data) {
    final List<Color> colors = [
      AppColors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    final sections = <PieChartSectionData>[];
    int i = 0;
    data.forEach((key, value) {
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: value.toDouble(),
            title: value.toString(),
            radius: 48,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        i++;
      }
    });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 38,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildChartLegend(data, colors),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChartLegend(Map<String, int> data, List<Color> colors) {
    final legends = <Widget>[];
    int i = 0;
    data.forEach((key, value) {
      if (value > 0) {
        legends.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$key ($value)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        );
        i++;
      }
    });
    return legends;
  }

  Widget _buildTopUsersSection(AuditStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Active Users',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.topUsers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final user = stats.topUsers[index];
              final progress = stats.total > 0 ? user.count / stats.total : 0.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user.user,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${user.count} logs',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[100],
                    color: AppColors.blue,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
