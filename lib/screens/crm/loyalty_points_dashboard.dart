import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/crm/get_loyalty_programs_request.dart';
import 'package:pos/domain/responses/crm/get_loyalty_programs_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/screens/crm/create_loyalty_points.dart';

class LoyaltyProgramsListScreen extends StatefulWidget {
  const LoyaltyProgramsListScreen({super.key});

  @override
  State<LoyaltyProgramsListScreen> createState() =>
      _LoyaltyProgramsListScreenState();
}

class _LoyaltyProgramsListScreenState extends State<LoyaltyProgramsListScreen> {
  bool _activeOnly = false;

  @override
  void initState() {
    super.initState();
    _fetchLoyaltyPrograms();
  }

  void _fetchLoyaltyPrograms() {
    final request = GetLoyaltyProgramsRequest(activeOnly: _activeOnly);
    context.read<InventoryBloc>().add(GetLoyaltyPrograms(request: request));
  }

  List<LoyaltyProgramData> _convertToLoyaltyProgramData(
    List<LoyaltyProgramItem> programs,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return programs.map((program) {
      bool isActive = false;
      try {
        if (program.fromDate.isNotEmpty && program.toDate.isNotEmpty) {
          final from = DateTime.parse(program.fromDate);
          final to = DateTime.parse(program.toDate);

          final fromDate = DateTime(from.year, from.month, from.day);
          final toDate = DateTime(to.year, to.month, to.day);

          isActive =
              (today.isAtSameMomentAs(fromDate) || today.isAfter(fromDate)) &&
              (today.isAtSameMomentAs(toDate) || today.isBefore(toDate));
        }
      } catch (e) {
        debugPrint('Error parsing loyalty program dates: $e');
      }

      return LoyaltyProgramData(
        name: program.loyaltyProgramName,
        pointsPerUnit: 'N/A',
        programType: program.loyaltyProgramType,
        id: program.name,
        isActive: isActive,
        fromDate: program.fromDate,
        toDate: program.toDate,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 8,
              vertical: 0,
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoyaltyProgramScreen(),
                  ),
                ).then((_) {
                  _fetchLoyaltyPrograms();
                });
              },
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'Create Program',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 8 : 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is GetLoyaltyProgramsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GetLoyaltyProgramsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
              ),
            );
          }

          List<LoyaltyProgramData> programs = [];

          if (state is GetLoyaltyProgramsLoaded) {
            programs = _convertToLoyaltyProgramData(
              state.response.message.programs,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchLoyaltyPrograms();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E88E5).withAlpha(10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Color(0xFF1E88E5),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'About Loyalty Programs',
                                  style: TextStyle(
                                    color: const Color(0xFF1E40AF),
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isTablet ? 16 : 12),
                          Text(
                            'Loyalty programs allow you to reward customers with points based on their purchases. Points are calculated using the collection factor (points per unit) you define.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: isTablet ? 15 : 14,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: isTablet ? 16 : 12),
                          Container(
                            padding: EdgeInsets.all(isTablet ? 16 : 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBAE6FD),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Points Calculation:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 15 : 14,
                                    color: const Color(0xFF0C4A6E),
                                  ),
                                ),
                                SizedBox(height: isTablet ? 8 : 6),
                                Text(
                                  'If your collection factor is 10, customers earn 1 point for every 10 currency units spent. For example:',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 13,
                                    color: const Color(0xFF0C4A6E),
                                  ),
                                ),
                                SizedBox(height: isTablet ? 8 : 6),
                                _buildBulletPoint(
                                  'Purchase of 100 = 10 points',
                                  isTablet,
                                ),
                                _buildBulletPoint(
                                  'Purchase of 25 = 2 points (integer division)',
                                  isTablet,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Active Programs Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Programs',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            if (state is GetLoyaltyProgramsLoaded)
                              Text(
                                '${state.response.message.totalPrograms} program${state.response.message.totalPrograms != 1 ? 's' : ''} found',
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _fetchLoyaltyPrograms,
                              icon: const Icon(
                                Icons.refresh,
                                size: 20,
                                color: Color(0xFF1E88E5),
                              ),
                              tooltip: 'Refresh',
                            ),
                            SizedBox(width: isTablet ? 8 : 4),
                            Row(
                              children: [
                                Switch(
                                  value: _activeOnly,
                                  onChanged: (value) {
                                    setState(() {
                                      _activeOnly = value;
                                    });
                                    _fetchLoyaltyPrograms();
                                  },
                                  activeThumbColor: const Color(0xFF1E88E5),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Active Only',
                                  style: TextStyle(
                                    fontSize: isTablet ? 15 : 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 16 : 12),

                    if (programs.isEmpty)
                      _buildEmptyState(isTablet)
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildLoyaltyTable(programs),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48 : 32),
        child: Column(
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              'No loyalty programs found',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'Create your first loyalty program to get started',
              style: TextStyle(
                fontSize: isTablet ? 15 : 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF0C4A6E)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: const Color(0xFF0C4A6E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyTable(List<LoyaltyProgramData> programs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF8FAFC),
                  ),
                  dataRowColor: WidgetStateProperty.all(Colors.white),
                  horizontalMargin: 16,
                  columnSpacing: 20,
                  columns: _buildTableColumns(isMobile),
                  rows: programs
                      .map((program) => _buildDataRow(program, isMobile))
                      .toList(),
                ),
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
          'Program Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const DataColumn(
        label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      if (!isMobile) ...[
        const DataColumn(
          label: Text(
            'Points/Unit',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const DataColumn(
          label: Text(
            'Duration',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      const DataColumn(
        label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ];
  }

  DataRow _buildDataRow(LoyaltyProgramData program, bool isMobile) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: isMobile ? 120 : 180,
            child: Text(
              program.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(program.programType)),
        if (!isMobile) ...[
          DataCell(Text(program.pointsPerUnit)),
          DataCell(
            Text(
              '${_formatDate(program.fromDate)} - ${_formatDate(program.toDate)}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: program.isActive
                  ? const Color(0xFFDCFCE7)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              program.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: program.isActive
                    ? const Color(0xFF166534)
                    : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }
}

class LoyaltyProgramData {
  final String name;
  final String pointsPerUnit;
  final String programType;
  final String id;
  final bool isActive;
  final String fromDate;
  final String toDate;

  LoyaltyProgramData({
    required this.name,
    required this.pointsPerUnit,
    required this.programType,
    required this.id,
    required this.isActive,
    required this.fromDate,
    required this.toDate,
  });
}
