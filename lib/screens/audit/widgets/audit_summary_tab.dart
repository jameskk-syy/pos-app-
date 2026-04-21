import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos/domain/models/audit_log.dart';
import 'package:pos/presentation/audit/bloc/audit_bloc.dart';
import 'package:pos/utils/themes/app_colors.dart';

class AuditSummaryTab extends StatelessWidget {
  final String? company;

  const AuditSummaryTab({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
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
              if (company != null) {
                context.read<AuditBloc>().add(
                  FetchAuditStatistics(company: company!),
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(context, stats),
                  const SizedBox(height: 16),
                  _buildChartsSection(context, stats),
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

  Widget _buildStatsGrid(BuildContext context, AuditStatistics stats) {
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

  Widget _buildChartsSection(BuildContext context, AuditStatistics stats) {
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
