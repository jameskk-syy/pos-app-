import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/models/biller_models.dart';
import 'package:pos/presentation/biller/bloc/biller_bloc.dart';
import 'package:pos/widgets/biller/industry_helpers.dart';

class BillerDetailPage extends StatefulWidget {
  final String billerName;

  const BillerDetailPage({super.key, required this.billerName});

  @override
  State<BillerDetailPage> createState() => _BillerDetailPageState();
}

class _BillerDetailPageState extends State<BillerDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<BillerBloc>().add(
          GetBillerDetails(GetBillerDetailsRequest(billerName: widget.billerName)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Details'),
      ),
      body: BlocBuilder<BillerBloc, BillerState>(
        builder: (context, state) {
          if (state is BillerDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BillerDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load: ${state.message}'),
                  TextButton(
                    onPressed: () {
                      context.read<BillerBloc>().add(
                            GetBillerDetails(GetBillerDetailsRequest(
                                billerName: widget.billerName)),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is BillerDetailsLoaded) {
            final data = state.response.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(data),
                  const SizedBox(height: 24),
                  _buildWarehousesSection(data.warehouses),
                  const SizedBox(height: 24),
                  _buildPosProfilesSection(data.posProfiles),
                  const SizedBox(height: 24),
                  _buildConfigSection(data),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeaderCard(BillerDetailsData data) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: getIndustryIcon(data.industry, size: 36),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.billerName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IndustryBadge(industry: data.industry),
                      if (data.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Company: ${data.company}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehousesSection(List<BillerWarehouse> warehouses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warehouses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (warehouses.isEmpty)
          const Text('No warehouses assigned.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: warehouses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final w = warehouses[index];
              return ListTile(
                leading: const Icon(Icons.warehouse_outlined),
                title: Text(w.name),
                subtitle: w.location != null ? Text(w.location!) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                tileColor: Theme.of(context).colorScheme.surface,
              );
            },
          ),
      ],
    );
  }

  Widget _buildPosProfilesSection(List<BillerPosProfile> profiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POS Profiles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (profiles.isEmpty)
          const Text('No POS profiles assigned.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profiles.map((p) => Chip(
              avatar: const Icon(Icons.point_of_sale, size: 16),
              label: Text(p.name),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildConfigSection(BillerDetailsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _ConfigRow(
                label: 'Default Cost Center',
                value: data.defaultCostCenter ?? 'Not set',
              ),
              const Divider(height: 1),
              _ConfigRow(
                label: 'Default Price List',
                value: data.defaultPriceList ?? 'Not set',
              ),
              const Divider(height: 1),
              _ConfigRow(
                label: 'Default Tax Template',
                value: data.defaultTaxTemplate ?? 'Not set',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfigRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
