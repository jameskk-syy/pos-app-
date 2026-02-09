import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/pos_opening_entry_model.dart';
import 'package:pos/presentation/sales/bloc/pos_opening_entries_bloc.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/screens/users/staff_assign_to_store.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'dart:convert';

class PosOpeningEntriesPage extends StatefulWidget {
  const PosOpeningEntriesPage({super.key});

  @override
  State<PosOpeningEntriesPage> createState() => _PosOpeningEntriesPageState();
}

class _PosOpeningEntriesPageState extends State<PosOpeningEntriesPage> {
  final ScrollController _scrollController = ScrollController();
  String? companyName;
  bool isFiltersExpanded = false;

  // Filter states
  String selectedStatus = 'All';
  String? searchTerm;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadCompany();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<PosOpeningEntriesBloc>().state;
      if (state is PosOpeningEntriesLoaded && state.hasMore) {
        _fetchEntries(loadMore: true);
      }
    }
  }

  Future<void> _loadCompany() async {
    final storage = getIt<StorageService>();
    final userJson = await storage.getString('current_user');
    if (userJson != null) {
      final data = jsonDecode(userJson);
      setState(() {
        companyName = data['message']['company']?['name'];
      });
      _fetchEntries();
    }
  }

  void _fetchEntries({bool loadMore = false}) {
    if (companyName == null) return;

    final state = context.read<PosOpeningEntriesBloc>().state;
    int offset = 0;
    if (loadMore && state is PosOpeningEntriesLoaded) {
      offset = state.entries.length;
    }

    context.read<PosOpeningEntriesBloc>().add(
      GetPosOpeningEntries(
        company: companyName!,
        offset: offset,
        loadMore: loadMore,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PosOpeningEntriesBloc, PosOpeningEntriesState>(
      listener: (context, state) {
        if (state is PosOpeningEntryCloseSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _fetchEntries(); // Refresh list
        } else if (state is PosOpeningEntriesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212)
            : AppColors.gray,

        appBar: AppBar(
          title: const Text(
            'Opening Entries',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // actions: [
          //   TextButton.icon(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => const StaffAssignmentPage(),
          //         ),
          //       );
          //     },
          //     icon: const Icon(Icons.person_add, size: 20),
          //     label: const Text('Assign Staff'),
          //     style: TextButton.styleFrom(foregroundColor: Colors.blue),
          //   ),
          //   const SizedBox(width: 8),
          // ],
        ),
        body: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: BlocBuilder<PosOpeningEntriesBloc, PosOpeningEntriesState>(
                builder: (context, state) {
                  if (state is PosOpeningEntriesLoaded) {
                    if (state.entries.isEmpty) {
                      return const Center(
                        child: Text('No opening entries found'),
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 700;
                        final isTablet =
                            constraints.maxWidth >= 700 &&
                            constraints.maxWidth < 1100;

                        return Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth - 32,
                                ),
                                child: DataTable(
                                  columnSpacing: isMobile ? 20 : 40,
                                  headingTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  columns: _buildColumns(isMobile, isTablet),
                                  rows: state.entries
                                      .map(
                                        (entry) => _buildRow(
                                          entry,
                                          isMobile,
                                          isTablet,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Please wait...'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => isFiltersExpanded = !isFiltersExpanded),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Search & Filters',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(isFiltersExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (isFiltersExpanded) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildDropdownFilter(
                  label: 'Status',
                  value: selectedStatus,
                  items: ['All', 'Open', 'Closed'],
                  onChanged: (val) {
                    setState(() => selectedStatus = val!);
                    _fetchEntries();
                  },
                ),
                _buildDateFilter(),
                _buildSearchFilter(),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedStatus = 'All';
                      searchTerm = null;
                      selectedDateRange = null;
                    });
                    _fetchEntries();
                  },
                  child: const Text(
                    'Clear Filters',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Range',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: selectedDateRange,
              );
              if (picked != null) {
                setState(() => selectedDateRange = picked);
                _fetchEntries();
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                suffixIcon: const Icon(
                  Icons.date_range,
                  size: 18,
                  color: Colors.blue,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
              child: Text(
                selectedDateRange == null
                    ? 'Select Dates'
                    : '${DateFormat('MMM d').format(selectedDateRange!.start)} - ${DateFormat('MMM d').format(selectedDateRange!.end)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter() {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search User',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search user...',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              hintStyle: const TextStyle(fontSize: 13),
            ),
            onChanged: (val) {
              searchTerm = val.isEmpty ? null : val;
              _fetchEntries();
            },
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(bool isMobile, bool isTablet) {
    if (isMobile) {
      return const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('POS Profile')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ];
    }
    if (isTablet) {
      return const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('POS Profile')),
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ];
    }
    return const [
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('POS Profile')),
      DataColumn(label: Text('User')),
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Actions')),
    ];
  }

  DataRow _buildRow(PosOpeningEntry entry, bool isMobile, bool isTablet) {
    final List<DataCell> cells = [
      DataCell(
        Text(
          entry.name,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataCell(Text(entry.posProfile)),
    ];

    if (!isMobile) {
      cells.add(DataCell(Text(entry.user)));
    }

    if (!isMobile && !isTablet) {
      cells.add(DataCell(Text(entry.postingDate)));
    }

    cells.add(DataCell(_buildStatusBadge(entry.status)));
    cells.add(DataCell(_buildActionMenu(entry)));

    return DataRow(cells: cells);
  }

  Widget _buildStatusBadge(String status) {
    Color color = status.toLowerCase() == 'open' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionMenu(PosOpeningEntry entry) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view':
            _viewInvoice(entry);
            break;
          case 'close':
            _confirmClose(entry);
            break;
          case 'assign':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StaffAssignmentPage(),
              ),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 18, color: Colors.blue),
              SizedBox(width: 8),
              Text('View'),
            ],
          ),
        ),
        if (entry.status.toLowerCase() == 'open')
          const PopupMenuItem(
            value: 'close',
            child: Row(
              children: [
                Icon(Icons.block, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Close'),
              ],
            ),
          ),
        // const PopupMenuItem(
        //   value: 'assign',
        //   child: Row(
        //     children: [
        //       Icon(Icons.person_add_alt_1, size: 18, color: Colors.green),
        //       SizedBox(width: 8),
        //       Text('Assign Staff'),
        //     ],
        //   ),
        // ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }

  void _viewInvoice(PosOpeningEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('Entry Details: ${entry.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('POS Profile', entry.posProfile),
              _detailRow('User', entry.user),
              _detailRow('Company', entry.company),
              _detailRow('Posting Date', entry.postingDate),
              _detailRow('Status', entry.status),
              const Divider(),
              const Text(
                'Opening Balances:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...entry.balanceDetails.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4),
                  child: Text(
                    '${b.modeOfPayment}: ${NumberFormat.currency(symbol: 'KES ').format(b.openingAmount)}',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _confirmClose(PosOpeningEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ), // Square corners
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
          ), // Large width
          title: const Text('Confirm Close'),
          content: SizedBox(
            width: screenWidth * 0.8, // Explicit width
            child: Text(
              'Are you sure you want to close the POS opening entry ${entry.name}?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<PosOpeningEntriesBloc>().add(
                  CloseOpeningEntry(posOpeningEntry: entry.name),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text('Close Entry'),
            ),
          ],
        );
      },
    );
  }
}
