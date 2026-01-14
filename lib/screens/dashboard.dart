import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos/screens/crm.dart';
import 'package:pos/screens/inventory_dashboard.dart';
import 'package:pos/screens/loyalty_points_dashboard.dart';
import 'package:pos/screens/pages/home.dart';
import 'package:pos/screens/pages/point_of_sale/product_page.dart';
import 'package:pos/screens/pages/register_staff.dart';
import 'package:pos/screens/products_dashboard.dart';
import 'package:pos/screens/purchase_dashboard.dart';
import 'package:pos/screens/reports/reports_dashboard.dart';
import 'package:pos/screens/role.dart';
import 'package:pos/screens/settings.dart';
import 'package:pos/screens/store_dashboard.dart';
import 'package:pos/screens/suppliers_dashboard.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos/widgets/logout_confirmation_dialog.dart';

enum InventoryPage {
  overview,
  list,
  lowStock,
  ledger,
  details,
  entries,
  receipts,
  issues,
  transfers,
  newEntry,
  reconciliation,
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int selectedIndex = 0;
  int bottomNavIndex = 0;
  InventoryPage selectedInventoryPage = InventoryPage.overview;

  List<String> _userRoles = [];
  bool _isLoadingRoles = true;

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.dashboard,
      'title': 'Dashboard',
      'roles': [],
      'pageIndex': 0,
    },
    {
      'icon': Icons.shopping_bag,
      'title': 'Products',
      'roles': [
        'system manager',
        'inventory manager',
        'stock manager',
        'pos user',
      ],
      'pageIndex': 1,
    },
    {
      'icon': Icons.inventory,
      'title': 'Inventory',
      'roles': [
        'inventory manager',
        'stock user',
        'store manager',
        'pos user',
        'system manager',
      ],
      'pageIndex': 2,
    },
    {
      'icon': Icons.people,
      'title': 'Customers',
      'roles': [
        'pos user',
        'store manager',
        'sales manager',
        'accounts manager',
        'system manager',
      ],
      'pageIndex': 3,
    },
    {
      'icon': Icons.warehouse,
      'title': 'Stores',
      'roles': ['store manager', 'system manager'],
      'pageIndex': 4,
    },
    {
      'icon': Icons.local_shipping,
      'title': 'Suppliers',
      'roles': [
        'purchase manager',
        'stock user',
        'account user',
        'store manager',
        'system manager',
      ],
      'pageIndex': 5,
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Purchases',
      'roles': [
        'purchase manager',
        'stock user',
        'account user',
        'store manager',
        'system manager',
      ],
      'pageIndex': 6,
    },
    {
      'icon': Icons.badge,
      'title': 'Staff',
      'roles': ['branch admin', 'auditor', 'system manager'],
      'pageIndex': 7,
    },
    {
      'icon': Icons.loyalty,
      'title': 'Loyalty Programs',
      'roles': [
        'marketing manager',
        'sales manager',
        'pos user',
        'auditor',
        'system manager',
      ],
      'pageIndex': 8,
    },
    {
      'icon': Icons.perm_identity,
      'title': 'Roles',
      'roles': ['branch admin', 'auditor', 'system manager'],
      'pageIndex': 9,
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Reports',
      'roles': ['auditor', 'system manager'],
      'pageIndex': 10,
    },
    {
      'icon': Icons.settings,
      'title': 'Settings',
      'roles': ['system manager'],
      'pageIndex': 11,
    },

    {
      'icon': Icons.logout,
      'title': 'Logout',
      'roles': [], // Everyone
      'pageIndex': -1, // Custom action
    },
  ];

  final List<String> inventoryChildren = [
    "Overview",
    "Inventory List",
    "Low Stock Alert",
    "Stock Ledger",
    "Inventory Details",
    "Stock Entries",
    "Material Receipts",
    "Material Issues",
    "Material Transfers",
    "New Stock Entry",
    "Stock Reconciliation",
  ];

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    _loadUserRoles();
    pages = [
      _ResponsiveWrapper(child: const HomePage()),
      _ResponsiveWrapper(child: const ProductsDashboard()),
      const SizedBox(),
      _ResponsiveWrapper(child: const CRMHomePage()),
      _ResponsiveWrapper(child: const StoreManagementPage()),
      _ResponsiveWrapper(child: const SupliersDashboards()),
      _ResponsiveWrapper(child: const PurchaseDashboards()),
      _ResponsiveWrapper(child: const RegisterStaff()),
      _ResponsiveWrapper(child: const LoyaltyProgramsListScreen()),
      _ResponsiveWrapper(child: const RoleManagementPage()),
      _ResponsiveWrapper(child: const ReportsDashboardPage()),
      _ResponsiveWrapper(child: const SettingsPage()),
    ];
  }

  InventoryPage getInventoryPage(String title) {
    switch (title) {
      case "Overview":
        return InventoryPage.overview;
      case "Inventory List":
        return InventoryPage.list;
      case "Low Stock Alert":
        return InventoryPage.lowStock;
      case "Stock Ledger":
        return InventoryPage.ledger;
      case "Inventory Details":
        return InventoryPage.details;
      case "Stock Entries":
        return InventoryPage.entries;
      case "Material Receipts":
        return InventoryPage.receipts;
      case "Material Issues":
        return InventoryPage.issues;
      case "Material Transfers":
        return InventoryPage.transfers;
      case "New Stock Entry":
        return InventoryPage.newEntry;
      case "Stock Reconciliation":
        return InventoryPage.reconciliation;
      default:
        return InventoryPage.overview;
    }
  }

  Future<void> _loadUserRoles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        final List<dynamic> rolesList = data['message']['roles'] ?? [];
        setState(() {
          _userRoles = rolesList
              .map((e) => e.toString().toLowerCase())
              .toList();
          _isLoadingRoles = false;
        });
      } else {
        setState(() => _isLoadingRoles = false);
      }
    } catch (e) {
      debugPrint('Error loading user roles: $e');
      setState(() => _isLoadingRoles = false);
    }
  }

  bool _hasPermission(List<String> allowedRoles) {
    if (_userRoles.contains('system manager')) return true;
    if (allowedRoles.isEmpty) return true;
    return allowedRoles.any((role) => _userRoles.contains(role.toLowerCase()));
  }

  List<Map<String, dynamic>> _getFilteredBottomNavItems() {
    final allItems = [
      {'icon': Icons.home, 'label': 'Home', 'roles': [], 'pageIndex': 0},
      {
        'icon': Icons.shopping_bag,
        'label': 'Products',
        'roles': [
          'system manager',
          'inventory manager',
          'stock manager',
          'pos user',
        ],
        'pageIndex': 1,
      },
      {'isSpacer': true},
      {
        'icon': Icons.inventory,
        'label': 'Inventory',
        'roles': [
          'system manager',
          'inventory manager',
          'stock user',
          'store manager',
          'pos user',
        ],
        'pageIndex': 2,
      },
      {'icon': Icons.person, 'label': 'Profile', 'roles': [], 'pageIndex': 11},
    ];

    return allItems.where((item) {
      if (item['isSpacer'] == true) {
        return _hasPermission([
          'system manager',
          'pos user',
          'pos manager',
          'sales manager',
          'account user',
        ]);
      }
      return _hasPermission(
        List<String>.from((item['roles'] as Iterable?) ?? []),
      );
    }).toList();
  }

  Widget get currentPage {
    if (selectedIndex == 2) {
      return _ResponsiveWrapper(child: const InventoryDashboards());
    }
    return pages[selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLogout = await LogoutConfirmationDialog.show(context);
        if (shouldLogout == true) {
          if (context.mounted) await handleLogout(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Icon(Icons.notifications_active)],
          ),
        ),
        drawer: Drawer(
          width: 260,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: SafeArea(
            child: _buildDrawerContent(
              isDark: isDark,
              onItemTap: (index) {
                setState(() => selectedIndex = index);
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: Container(
          color: isDark ? const Color(0xFF121212) : AppColors.gray,
          child: currentPage,
        ),
        bottomNavigationBar: _isLoadingRoles
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : () {
                final items = _getFilteredBottomNavItems();
                // Safety check: BottomNavigationBar requires at least 2 items
                if (items.length < 2) return const SizedBox.shrink();

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    BottomNavigationBar(
                      currentIndex: () {
                        int idx = items.indexWhere(
                          (item) => item['pageIndex'] == selectedIndex,
                        );
                        return idx == -1 ? 0 : idx;
                      }(),
                      onTap: (index) {
                        final item = items[index];
                        if (item['isSpacer'] == true) return;

                        setState(() {
                          selectedIndex = item['pageIndex'] as int;
                          if (selectedIndex == 2) {
                            selectedInventoryPage = InventoryPage.overview;
                          }
                        });
                      },
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: isDark
                          ? Colors.white54
                          : Colors.black54,
                      selectedFontSize: 12,
                      unselectedFontSize: 12,
                      items: items.map((item) {
                        if (item['isSpacer'] == true) {
                          return const BottomNavigationBarItem(
                            icon: SizedBox(height: 24),
                            label: '',
                          );
                        }
                        return BottomNavigationBarItem(
                          icon: Icon(item['icon'] as IconData),
                          label: (item['label'] ?? item['title']) as String,
                        );
                      }).toList(),
                    ),
                    if (_hasPermission([
                      'system manager',
                      'pos user',
                      'pos manager',
                      'sales manager',
                      'account user',
                    ]))
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 32,
                        top: -20,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (contaxt2) => ProductsPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Colors.blue, Colors.blueAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withAlpha(40),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                const Icon(
                                  Icons.point_of_sale,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const Text(
                                  "Sales",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }(),
      ),
    );
  }

  Widget _buildDrawerContent({
    required bool isDark,
    required Function(int) onItemTap,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              SvgPicture.asset("assets/svgs/maiLogo.svg", height: 32),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                color: isDark ? Colors.white : Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];

              // Filter based on roles
              if (!_hasPermission(
                List<String>.from((item['roles'] as Iterable?) ?? []),
              )) {
                return const SizedBox.shrink();
              }

              final selected = selectedIndex == item['pageIndex'];

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  if (item['title'] == 'Logout') {
                    final shouldLogout = await LogoutConfirmationDialog.show(
                      context,
                    );
                    if (shouldLogout == true) {
                      if (context.mounted) await handleLogout(context);
                    }
                    return;
                  }
                  if (item['title'] == 'Reports') {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsDashboardPage(),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    selectedIndex = item['pageIndex'] as int;
                    if (selectedIndex == 2) {
                      selectedInventoryPage = InventoryPage.overview;
                    }
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? (isDark
                              ? Colors.blue.withAlpha(20)
                              : Colors.blue.shade50)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'],
                        color: selected
                            ? Colors.blue
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? Colors.blue
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const _ResponsiveWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 600) {
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth > 1200 ? 1400 : double.infinity,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 900 ? 32 : 24,
            vertical: 16,
          ),
          child: child,
        ),
      );
    }

    // Mobile - no wrapper
    return child;
  }
}
