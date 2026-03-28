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
      backgroundColor: Colors.grey[50], // Light grey background for a clean look
      body: BlocBuilder<BillerBloc, BillerState>(
        builder: (context, state) {
          if (state is BillerDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BillerDetailsError) {
            return _buildErrorState(state.message);
          }

          if (state is BillerDetailsLoaded) {
            final data = state.response.data;
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(data),
                SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth >= 720;
                      return Padding(
                        padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
                        child: isTablet
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        _buildWarehousesCard(data.warehouses),
                                        const SizedBox(height: 24),
                                        _buildPosProfilesCard(data.posProfiles),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    flex: 2,
                                    child: _buildConfigCard(data),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildWarehousesCard(data.warehouses),
                                  const SizedBox(height: 24),
                                  _buildPosProfilesCard(data.posProfiles),
                                  const SizedBox(height: 24),
                                  _buildConfigCard(data),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BillerDetailsData data) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      floating: false,
      backgroundColor: Colors.blue[700],
      iconTheme: const IconThemeData(color: Colors.white), // Set back arrow to white
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          data.billerName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade600,
                Colors.blue.shade400,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                bottom: -40,
                child: Icon(
                  Icons.business_rounded,
                  size: 200,
                  color: Colors.white.withAlpha(20),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(200), width: 2),
                      ),
                      child: getIndustryIcon(data.industry, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeaderBadge(data.industry, Icons.category),
                        if (data.isDefault == 1) ...[
                          const SizedBox(width: 8),
                          _buildHeaderBadge('Default', Icons.star, color: Colors.amber[400]!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(String label, IconData icon, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue[800]),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehousesCard(List<BillerWarehouse> warehouses) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionHeader('Warehouses', Icons.warehouse_rounded),
            if (warehouses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No warehouses assigned', style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: warehouses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final w = warehouses[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.blue),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (w.location != null)
                                Text(w.location!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosProfilesCard(List<BillerPosProfile> profiles) {
    return Card(
       elevation: 6,
      color: Colors.white,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionHeader('POS Profiles', Icons.settings_remote_rounded),
            if (profiles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No POS profiles assigned', style: TextStyle(color: Colors.grey)),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: profiles.map((p) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withAlpha(100),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.point_of_sale_rounded, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard(BillerDetailsData data) {
    return Card(
      elevation: 6,
      color: Colors.white,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionHeader('Configuration', Icons.tune_rounded),
            _buildConfigItem('Default Cost Center', data.defaultCostCenter ?? 'Not configured', Icons.account_balance_rounded),
            const Divider(height: 32),
            _buildConfigItem('Default Price List', data.defaultPriceList ?? 'Not configured', Icons.list_alt_rounded),
            const Divider(height: 32),
            _buildConfigItem('Default Tax Template', data.defaultTaxTemplate ?? 'Not configured', Icons.receipt_long_rounded),
            const Divider(height: 32),
            _buildConfigItem('Parent Company', data.company, Icons.business_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.blueGrey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Opps! Something went wrong',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<BillerBloc>().add(
                        GetBillerDetails(GetBillerDetailsRequest(billerName: widget.billerName)),
                      );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
