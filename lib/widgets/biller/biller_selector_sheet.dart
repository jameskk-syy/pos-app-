import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/models/biller_models.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/presentation/biller/bloc/biller_bloc.dart';
import 'package:pos/widgets/biller/industry_helpers.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/screens/sales/dashboard.dart';

class BillerSelectorSheet extends StatelessWidget {
  final List<BillerProfile> allowedBillers;
  final BillerProfile? currentActiveBiller;

  const BillerSelectorSheet({
    super.key,
    required this.allowedBillers,
    this.currentActiveBiller,
  });

  static Future<void> show(
    BuildContext context, {
    required List<BillerProfile> allowedBillers,
    BillerProfile? currentActiveBiller,
    bool isDismissible = true,
  }) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Center(
          child: Container(
            constraints: isTablet
                ? const BoxConstraints(maxWidth: 500)
                : const BoxConstraints(maxWidth: double.infinity),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: BillerSelectorSheet(
              allowedBillers: allowedBillers,
              currentActiveBiller: currentActiveBiller,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(isDark ? 50 : 100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Branch',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Choose the business unit to operate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: allowedBillers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final biller = allowedBillers[index];
                final isActive = currentActiveBiller?.name == biller.name;

                return _BillerTile(
                  biller: biller,
                  isActive: isActive,
                  onTap: () => _handleBillerSelection(context, biller),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _handleBillerSelection(
      BuildContext context, BillerProfile biller) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final billerBloc = context.read<BillerBloc>();
      
      // 1. Set active on the backend
      final setEvent = SetActiveBiller(
        SetActiveBillerRequest(billerName: biller.name),
      );
      billerBloc.add(setEvent);
      
      // Wait for it
      await billerBloc.stream.firstWhere(
        (state) => state is SetActiveBillerSuccess || state is SetActiveBillerError
      );

      // 2. Fetch specific details for this biller
      final detailEvent = GetBillerDetails(
        GetBillerDetailsRequest(billerName: biller.name),
      );
      billerBloc.add(detailEvent);

      final detailState = await billerBloc.stream.firstWhere(
        (state) => state is BillerDetailsLoaded || state is BillerDetailsError
      );

      // 3. Save to local storage
      final storage = getIt<StorageService>();
      await storage.setString('active_biller', jsonEncode(biller.toJson()));
      
      if (detailState is BillerDetailsLoaded) {
        await storage.setString('active_biller_details', jsonEncode(detailState.response.data.toJson()));
      }

      if (context.mounted) {
        Navigator.pop(context); // pop loading
        Navigator.pop(context); // pop sheet
        
        // Go back to dashboard (or replace if coming from splash)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching branch: $e')),
        );
      }
    }
  }
}

class _BillerTile extends StatelessWidget {
  final BillerProfile biller;
  final bool isActive;
  final VoidCallback onTap;

  const _BillerTile({
    required this.biller,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withAlpha(20)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.blue
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.blue.withAlpha(40)
                    : (isDark ? Colors.white10 : AppColors.gray),
                shape: BoxShape.circle,
              ),
              child: getIndustryIcon(
                biller.industry,
                color: isActive ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    biller.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  IndustryBadge(industry: biller.industry),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
