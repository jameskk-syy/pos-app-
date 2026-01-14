import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/presentation/industries/bloc/industries_bloc.dart';
import 'package:pos/screens/dashboard.dart';
import 'package:pos/screens/items_seed.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/utils/themes/app_sizes.dart';

class BussinessTypePage extends StatefulWidget {
  const BussinessTypePage({super.key});

  @override
  State<BussinessTypePage> createState() => _BussinessTypePageState();
}

class _BussinessTypePageState extends State<BussinessTypePage> {
  static final List<Map<String, dynamic>> _colorPalette = [
    {
      'iconColor': Color(0xFF3B82F6),
      'bgColor': Color(0xFFEAF2FF),
      'icon': Icons.restaurant,
    },
    {
      'iconColor': Color(0xFFF59E0B),
      'bgColor': Color(0xFFFFF3E6),
      'icon': Icons.local_bar,
    },
    {
      'iconColor': Color(0xFF22C55E),
      'bgColor': Color(0xFFEAFBEA),
      'icon': Icons.store,
    },
    {
      'iconColor': Color(0xFFEF4444),
      'bgColor': Color(0xFFFFEBEB),
      'icon': Icons.checkroom,
    },
    {
      'iconColor': Color(0xFF8B5CF6),
      'bgColor': Color(0xFFF3E8FF),
      'icon': Icons.chair,
    },
    {
      'iconColor': Color(0xFFF97316),
      'bgColor': Color(0xFFFFF7ED),
      'icon': Icons.bakery_dining,
    },
    {
      'iconColor': Color(0xFF14B8A6),
      'bgColor': Color(0xFFE6FFFA),
      'icon': Icons.local_pharmacy,
    },
    {
      'iconColor': Color(0xFFF43F5E),
      'bgColor': Color(0xFFFFF1F2),
      'icon': Icons.handyman,
    },
    {
      'iconColor': Color(0xFF0EA5E9),
      'bgColor': Color(0xFFF0F9FF),
      'icon': Icons.shopping_cart,
    },
    {
      'iconColor': Color(0xFFEC4899),
      'bgColor': Color(0xFFFFF0F7),
      'icon': Icons.electrical_services,
    },
    {
      'iconColor': Color(0xFFD97706),
      'bgColor': Color(0xFFFEF3C7),
      'icon': Icons.shopping_basket,
    },
    {
      'iconColor': Color(0xFF6366F1),
      'bgColor': Color(0xFFEEF2FF),
      'icon': Icons.coffee,
    },
  ];

  // Get configuration based on index (cycles through palette)
  Map<String, dynamic> _getConfigByIndex(int index) {
    final paletteIndex = index % _colorPalette.length;
    return _colorPalette[paletteIndex];
  }

  String industryType = "";
  @override
  void initState() {
    super.initState();
    context.read<IndustriesBloc>().add(GetIndustriesList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, size: 32),
        ),
        title: const Text(
          'Choose your store',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  "Skip Now",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: BlocListener<IndustriesBloc, IndustriesState>(
        listener: (context, state) {
          if (state is IndustriesSeedProductSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsGridPage(industry: industryType),
              ),
            );
          }
        },
        child: BlocBuilder<IndustriesBloc, IndustriesState>(
          builder: (context, state) {
            // Loading state
            if (state is IndustriesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (state is IndustriesFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading industries',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<IndustriesBloc>().add(
                            GetIndustriesList(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Success state
            if (state is IndustriesSuccess) {
              final industries = state.message.message.industries;

              // Filter only active industries
              final activeIndustries = industries
                  .where((industry) => industry.isActive == 1)
                  .toList();

              if (activeIndustries.isEmpty) {
                return const Center(child: Text('No industries available'));
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.padding,
                  vertical: 12,
                ),
                child: GridView.builder(
                  itemCount: activeIndustries.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final industry = activeIndustries[index];
                    final config = _getConfigByIndex(index);

                    final Color bgColor = config['bgColor'];
                    final Color iconColor = config['iconColor'];
                    final IconData icon = config['icon'];

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            industryType = industry.industryCode;
                            context.read<IndustriesBloc>().add(
                              SeedProducts(industry: industry.industryCode),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: iconColor.withAlpha(15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: iconColor, size: 26),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  industry.industryName.isNotEmpty
                                      ? industry.industryName
                                      : industry.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Optional: Show industry code if available
                                if (industry.industryCode.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Code: ${industry.industryCode}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            if (state is IndustriesInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<IndustriesBloc>().add(GetIndustriesList());
              });
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
