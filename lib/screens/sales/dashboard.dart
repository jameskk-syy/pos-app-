import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/core/enums/user_role.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/warehouse_cubit/warehouse_cubit.dart';
import 'package:pos/screens/crm/crm.dart';
import 'package:pos/screens/inventory/inventory_dashboard.dart';
import 'package:pos/screens/crm/loyalty_points_dashboard.dart';
import 'package:pos/screens/pages/home.dart';
import 'package:pos/screens/pages/point_of_sale/product_page.dart';
import 'package:pos/screens/pages/register_staff.dart';
import 'package:pos/screens/sales/invoices_page.dart';
import 'package:pos/screens/sales/pos_opening_entries_page.dart';
import 'package:pos/screens/products/products_dashboard.dart';
import 'package:pos/screens/purchase/purchase_dashboard.dart';
import 'package:pos/screens/reports/reports_dashboard.dart';
import 'package:pos/screens/users/role.dart';
import 'package:pos/screens/sales/settings.dart';
import 'package:pos/screens/sales/store_dashboard.dart';
import 'package:pos/screens/suppliers/suppliers_dashboard.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/widgets/users/logout_confirmation_dialog.dart';
import 'package:pos/widgets/inventory/warehouse_selector.dart';

import 'package:pos/screens/sales/sales_dashboard.dart';

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
  String? _defaultWarehouse;
  String? _companyName;

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.dashboard,
      'title': 'Dashboard',
      'roles': <UserRole>[],
      'pageIndex': 0,
    },
    {
      'icon': Icons.point_of_sale,
      'title': 'Sales Dashboard',
      'roles': [
        UserRole.posUser,
        UserRole.salesManager,
        UserRole.systemManager,
      ],
      'pageIndex': 14,
    },
    {
      'icon': Icons.shopping_bag,
      'title': 'Products',
      'roles': [
        UserRole.systemManager,
        UserRole.inventoryManager,
        UserRole.stockManager,
        UserRole.posUser,
      ],
      'pageIndex': 1,
    },
    {
      'icon': Icons.inventory,
      'title': 'Inventory',
      'roles': [
        UserRole.inventoryManager,
        UserRole.stockUser,
        UserRole.storeManager,
        UserRole.posUser,
        UserRole.systemManager,
      ],
      'pageIndex': 2,
    },
    {
      'icon': Icons.people,
      'title': 'Customers',
      'roles': [
        UserRole.posUser,
        UserRole.storeManager,
        UserRole.salesManager,
        UserRole.accountsManager,
        UserRole.systemManager,
      ],
      'pageIndex': 3,
    },
    {
      'icon': Icons.warehouse,
      'title': 'Stores',
      'roles': [UserRole.storeManager, UserRole.systemManager],
      'pageIndex': 4,
    },
    {
      'icon': Icons.local_shipping,
      'title': 'Suppliers',
      'roles': [
        UserRole.purchaseManager,
        UserRole.stockUser,
        UserRole.accountUser,
        UserRole.storeManager,
        UserRole.systemManager,
      ],
      'pageIndex': 5,
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Purchases',
      'roles': [
        UserRole.purchaseManager,
        UserRole.stockUser,
        UserRole.accountUser,
        UserRole.storeManager,
        UserRole.systemManager,
      ],
      'pageIndex': 6,
    },
    {
      'icon': Icons.badge,
      'title': 'Staff',
      'roles': [UserRole.branchAdmin, UserRole.auditor, UserRole.systemManager],
      'pageIndex': 7,
    },
    {
      'icon': Icons.loyalty,
      'title': 'Loyalty Programs',
      'roles': [
        UserRole.marketingManager,
        UserRole.salesManager,
        UserRole.posUser,
        UserRole.auditor,
        UserRole.systemManager,
      ],
      'pageIndex': 8,
    },
    {
      'icon': Icons.perm_identity,
      'title': 'Roles',
      'roles': [UserRole.branchAdmin, UserRole.auditor, UserRole.systemManager],
      'pageIndex': 9,
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Reports',
      'roles': [UserRole.auditor, UserRole.systemManager],
      'pageIndex': 10,
    },
    {
      'icon': Icons.settings,
      'title': 'Settings',
      'roles': [UserRole.systemManager],
      'pageIndex': 11,
    },

    {
      'icon': Icons.logout,
      'title': 'Logout',
      'roles': <UserRole>[], // Everyone
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
      _ResponsiveWrapper(child: const InvoicesPage()),
      _ResponsiveWrapper(child: const PosOpeningEntriesPage()),
      _ResponsiveWrapper(child: const SalesDashboard()),
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
      final storage = getIt<StorageService>();
      final userJson = await storage.getString('current_user');
      if (userJson != null) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        final List<dynamic> rolesList = data['message']['roles'] ?? [];
        setState(() {
          _userRoles = rolesList
              .map((e) => e.toString().toLowerCase())
              .toList();
          _defaultWarehouse = data['message']['default_warehouse']?.toString();
          _companyName = data['message']['company']?['name']?.toString();
          _isLoadingRoles = false;
        });

        if (_companyName != null && mounted) {
          context.read<StoreBloc>().add(GetAllStores(company: _companyName!));
        }
      } else {
        setState(() => _isLoadingRoles = false);
      }
    } catch (e) {
      debugPrint('Error loading user roles: $e');
      setState(() => _isLoadingRoles = false);
    }
  }

  bool _hasPermission(List<UserRole> allowedRoles) {
    if (_userRoles.contains(UserRole.systemManager.name.toLowerCase())) {
      return true;
    }
    if (allowedRoles.isEmpty) return true;
    return allowedRoles.any(
      (role) => _userRoles.contains(role.name.toLowerCase()),
    );
  }

  List<Map<String, dynamic>> _getFilteredBottomNavItems() {
    final allItems = [
      {
        'icon': Icons.home,
        'label': 'Home',
        'roles': <UserRole>[],
        'pageIndex': 0,
      },
      {
        'icon': Icons.shopping_bag,
        'label': 'Products',
        'roles': [
          UserRole.systemManager,
          UserRole.inventoryManager,
          UserRole.stockManager,
          UserRole.posUser,
        ],
        'pageIndex': 1,
      },
      {'isSpacer': true},
      {
        'icon': Icons.inventory,
        'label': 'Inventory',
        'roles': [
          UserRole.systemManager,
          UserRole.inventoryManager,
          UserRole.stockUser,
          UserRole.storeManager,
          UserRole.posUser,
        ],
        'pageIndex': 2,
      },
      {
        'icon': Icons.person,
        'label': 'Profile',
        'roles': <UserRole>[],
        'pageIndex': 11,
      },
    ];

    return allItems.where((item) {
      if (item['isSpacer'] == true) {
        return _hasPermission([
          UserRole.systemManager,
          UserRole.posUser,
          UserRole.posManager,
          UserRole.salesManager,
          UserRole.accountUser,
        ]);
      }
      return _hasPermission(
        List<UserRole>.from((item['roles'] as Iterable?) ?? []),
      );
    }).toList();
  }

  Widget get currentPage {
    if (selectedIndex == 2) {
      return _ResponsiveWrapper(
        child: InventoryDashboards(company: _companyName),
      );
    }
    return pages[selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLogout = await LogoutConfirmationDialog.show(context);
        if (shouldLogout == true) {
          if (context.mounted) await handleLogout(context);
        }
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<StoreBloc, StoreState>(
            listener: (context, state) {
              if (state is StoreStateSuccess) {
                final warehouses = state.storeGetResponse.message.data;
                if (warehouses.isEmpty) return;

                final warehouseCubit = context.read<WarehouseCubit>();

                // Only auto-select if we haven't successfully loaded a specific warehouse yet
                // OR if we are currently on "All Warehouses" (null)
                final currentState = warehouseCubit.state;
                if (currentState is WarehouseInitial ||
                    (currentState is WarehouseLoaded &&
                        currentState.warehouse == null)) {
                  if (_defaultWarehouse != null &&
                      _defaultWarehouse!.isNotEmpty) {
                    warehouseCubit.selectWarehouseByName(
                      _defaultWarehouse!,
                      warehouses,
                    );
                  } else {
                    // Fallback to system default (isDefault = true)
                    try {
                      final defaultStore = warehouses.firstWhere(
                        (w) => w.isDefault,
                      );
                      warehouseCubit.selectWarehouse(defaultStore);
                    } catch (e) {
                      // If no default is found, optional: select first one
                      // warehouseCubit.selectWarehouse(warehouses.first);
                    }
                  }
                }
              }
            },
          ),
        ],
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: isDesktop
                ? null
                : IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const WarehouseSelector(),
                const SizedBox(width: 12),
                Icon(Icons.notifications_active),
              ],
            ),
          ),
          drawer: isDesktop
              ? null
              : Drawer(
                  width: 260,
                  backgroundColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  child: SafeArea(
                    child: _buildDrawerContent(
                      isDark: isDark,
                      isModal: true,
                      onItemTap: (index) {
                        setState(() => selectedIndex = index);
                        // Navigator.pop handled inside _buildDrawerContent for modal
                      },
                    ),
                  ),
                ),
          body: isDesktop
              ? Row(
                  children: [
                    Container(
                      width: 260,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      child: _buildDrawerContent(
                        isDark: isDark,
                        isModal: false,
                        onItemTap: (index) {
                          setState(() => selectedIndex = index);
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: isDark
                            ? const Color(0xFF121212)
                            : AppColors.gray,
                        child: currentPage,
                      ),
                    ),
                  ],
                )
              : Container(
                  color: isDark ? const Color(0xFF121212) : AppColors.gray,
                  child: currentPage,
                ),
          bottomNavigationBar: isDesktop || _isLoadingRoles
              ? const SizedBox.shrink()
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
                        UserRole.systemManager,
                        UserRole.posUser,
                        UserRole.posManager,
                        UserRole.salesManager,
                        UserRole.accountUser,
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
      ),
    );
  }

  Widget _buildDrawerContent({
    required bool isDark,
    required Function(int) onItemTap,
    bool isModal = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              SvgPicture.asset("assets/svgs/maiLogo.svg", height: 32),
              const Spacer(),
              if (isModal)
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
                List<UserRole>.from((item['roles'] as Iterable?) ?? []),
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
                    if (isModal) Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsDashboardPage(),
                      ),
                    );
                    return;
                  }

                  onItemTap(item['pageIndex'] as int);

                  if (isModal) {
                    Navigator.pop(context);
                  }
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
