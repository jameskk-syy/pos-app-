import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/models/biller_models.dart';
import 'package:pos/widgets/biller/industry_helpers.dart';
import 'package:pos/widgets/biller/biller_selector_sheet.dart';

class BillerSwitcher extends StatefulWidget {
  const BillerSwitcher({super.key});

  @override
  State<BillerSwitcher> createState() => _BillerSwitcherState();
}

class _BillerSwitcherState extends State<BillerSwitcher> {
  BillerProfile? activeBiller;
  List<BillerProfile> allowedBillers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBillerContext();
  }

  Future<void> _loadBillerContext() async {
    final storage = getIt<StorageService>();
    final activeJson = await storage.getString('active_biller');
    final contextJson = await storage.getString('user_context');

    if (mounted) {
      setState(() {
        if (activeJson != null) {
          activeBiller = BillerProfile.fromJson(jsonDecode(activeJson));
        }
        if (contextJson != null) {
          final contextData = UserContextData.fromJson(jsonDecode(contextJson));
          allowedBillers = contextData.allowedBillers;
        }
        isLoading = false;
      });
    }
  }

  void _openSwitcher() {
    if (allowedBillers.length <= 1) return;

    BillerSelectorSheet.show(
      context,
      allowedBillers: allowedBillers,
      currentActiveBiller: activeBiller,
    ).then((_) {
      // Reload in case selection changed
      _loadBillerContext();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || activeBiller == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final canSwitch = allowedBillers.length > 1;

    return Semantics(
      button: canSwitch,
      label: 'Switch Biller',
      child: GestureDetector(
        onTap: canSwitch ? _openSwitcher : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.blue.shade100,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              getIndustryIcon(
                activeBiller!.industry,
                size: isTablet ? 18 : 16,
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 150 : 100),
                child: Text(
                  activeBiller!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.blue.shade900,
                  ),
                ),
              ),
              if (canSwitch) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: isDark ? Colors.white70 : Colors.blue.shade700,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
