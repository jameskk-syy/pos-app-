import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/screens/inventory/create_stock_transfer.dart';
import 'package:pos/screens/inventory/stock_receipt_page.dart';
import 'package:pos/widgets/common/barcode_scanner_screen.dart';
import 'package:pos/widgets/inventory/stock_level_detail_dialog.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
// import 'package:pos/screens/inventory/create_material_transfer.dart';
import 'package:pos/screens/inventory/inventory_discount_rules_screen.dart';
import 'package:pos/screens/inventory/low_stock.dart';
import 'package:pos/screens/inventory/stock_entries.dart';
import 'package:pos/screens/inventory/stock_entry_page.dart';
import 'package:pos/screens/inventory/stock_leder.dart';
import 'package:pos/screens/inventory/stock_material_issue.dart';
// import 'package:pos/screens/inventory/stock_reconciliation.dart';
import 'package:pos/screens/inventory/stock_reconciliation_multi.dart';
import 'package:pos/screens/inventory/stock_summary.dart';
import 'package:pos/screens/inventory/stock_transfer.dart';
import 'package:pos/widgets/inventory/inventory_card.dart';

class InventoryDashboards extends StatefulWidget {
  final String? company;
  const InventoryDashboards({super.key, this.company});

  @override
  State<InventoryDashboards> createState() => _InventoryDashboardsState();
}

class _InventoryDashboardsState extends State<InventoryDashboards> {
  String? _currentCompany;
  String? _posProfile;
  bool _isMonitoringLoading = false;
  ProductItem? _scannedProduct;

  @override
  void initState() {
    super.initState();
    _currentCompany = widget.company;
    _loadCompanyFromPrefs();
  }

  Future<void> _loadCompanyFromPrefs() async {
    try {
      final storage = getIt<StorageService>();
      if (!mounted) return;
      final userJson = await storage.getString('current_user');
      if (userJson != null) {
        final data = jsonDecode(userJson);
        final userResponse = CurrentUserResponse.fromJson(data);
        setState(() {
          _currentCompany = userResponse.message.company.name;
          _posProfile = userResponse.message.posProfile.name;
        });
        // ignore: use_build_context_synchronously
        context.read<ProductsBloc>().add(
          GetAllProducts(company: userResponse.message.company.name),
        );
      }
    } catch (e) {
      debugPrint('Error loading company from prefs: $e');
    }
  }

  Future<void> _handleStockMonitoring() async {
    var barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (barcode == null || barcode.isEmpty) return;
    barcode = barcode.trim();

    if (!mounted) return;
    final productsState = context.read<ProductsBloc>().state;
    if (productsState is ProductsStateSuccess) {
      final product = productsState.productResponse.getProductByCode(barcode);
      if (product != null) {
        setState(() => _isMonitoringLoading = true);
        context.read<ProductsBloc>().add(
          GetAllProducts(
            company: _currentCompany ?? '',
            searchTerm: product.itemName,
          ),
        );
        return;
      }
    }

    if (_posProfile == null || _posProfile!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('POS Profile not found. Please log in again.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isMonitoringLoading = true);
    context.read<ProductsBloc>().add(
      SearchProductByBarcode(barcode: barcode, posProfile: _posProfile ?? ''),
    );
  }

  void _showMonitoringDialog(List<ProductItem> items) {
    showDialog(
      context: context,
      builder: (dialogContext) => StockLevelDetailDialog(
        items: items,
        onAdjust: () {
          Navigator.pop(dialogContext);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StockReceiptPage()),
          );
        },
        onTransfer: () {
          Navigator.pop(dialogContext);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StockTransfer()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (_isMonitoringLoading) {
            if (state is BarcodeSearchSuccess) {
              _scannedProduct = state.product;
              context.read<ProductsBloc>().add(
                GetAllProducts(
                  company: _currentCompany ?? '',
                  searchTerm: state.product.itemName,
                ),
              );
            } else if (state is ProductsStateSuccess) {
              setState(() => _isMonitoringLoading = false);

              final results = List<ProductItem>.from(
                state.productResponse.products,
              );

              if (_scannedProduct != null) {
                final exists = results.any(
                  (p) => p.itemCode == _scannedProduct!.itemCode,
                );
                if (!exists) {
                  results.insert(0, _scannedProduct!);
                }
              }

              _showMonitoringDialog(results);
              _scannedProduct = null;
            } else if (state is ProductsStateFailure) {
              setState(() => _isMonitoringLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Inventory Operations", Colors.blue),
                  const SizedBox(height: 4),
                  _sectionSubtitle(
                    "Manage stock movements, view summaries, and track inventory across warehouses",
                  ),
                  const SizedBox(height: 16),

                  _sectionTitle("Reports & Analysis", Colors.blue),
                  const SizedBox(height: 10),

                  _grid([
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFE3F2FD),
                      iconColor: Colors.blue,
                      icon: Icons.inventory_2_outlined,
                      title: "Stock Summary",
                      subtitle: "View stock levels across",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockSummaryPage(),
                          ),
                        );
                      },
                    ),
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFFFF3E0),
                      iconColor: Colors.orange,
                      icon: Icons.warning_amber_outlined,
                      title: "Low Stock Alert",
                      subtitle: "Items below threshold",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) => LowStockAlertPage(),
                          ),
                        );
                      },
                    ),
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFE8F5E9),
                      iconColor: Colors.green,
                      icon: Icons.receipt_long_outlined,
                      title: "Stock Ledger",
                      subtitle: "Transaction history",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) => StockLedgerDetailsPage(),
                          ),
                        );
                      },
                    ),
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFFFEBEE),
                      iconColor: Colors.red,
                      icon: Icons.list_alt_outlined,
                      title: "Stock Level Monitoring",
                      subtitle: "View and track details",
                      onTap: () => _handleStockMonitoring(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _sectionTitle("Stock Movements", Colors.blue),
                  const SizedBox(height: 10),
                  _grid([
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFE3F2FD),
                      iconColor: Colors.blue,
                      icon: Icons.input_outlined,
                      title: "Stock Entries",
                      subtitle: "View all stock entries",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockEntriesPage(),
                          ),
                        );
                      },
                    ),
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFFFF3E0),
                      iconColor: Colors.orange,
                      icon: Icons.download_outlined,
                      title: "Material Receipt",
                      subtitle: "Log incoming receipts",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) => StockReceiptPage(),
                          ),
                        );
                      },
                    ),
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFE8F5E9),
                      iconColor: Colors.green,
                      icon: Icons.upload_outlined,
                      title: "Material Issues",
                      subtitle: "View and create issues",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) => MaterialIssuePage(),
                          ),
                        );
                      },
                    ),
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFFFEBEE),
                      iconColor: Colors.red,
                      icon: Icons.sync_alt_outlined,
                      title: "Stock  Transfers",
                      subtitle: "View and create transfers",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) => StockTransferPage(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  _sectionTitle("Stock Management", Colors.blue),
                  const SizedBox(height: 10),
                  _grid([
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFE3F2FD),
                      iconColor: Colors.blue,
                      icon: Icons.add_box_outlined,
                      title: "Stock Entry",
                      subtitle: "Create stock entry",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) => StockEntryPage(),
                          ),
                        );
                      },
                    ),
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFFFF3E0),
                      iconColor: Colors.orange,
                      icon: Icons.checklist_outlined,
                      title: "Stock Multi Reconciliation",
                      subtitle: "Reconcile stock counts",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) =>
                                StockReconciliationMultiPage(),
                          ),
                        );
                      },
                    ),
                    InventoryCard(
                      backgroundColor: Colors.white,
                      iconBackgroundColor: const Color(0xFFFFF3E0),
                      iconColor: Colors.orange,
                      icon: Icons.checklist_outlined,
                      title: "Inventory Discounts",
                      subtitle: "apply discount rules",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context2) =>
                                InventoryDiscountRulesScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                ],
              ),
            ),
            if (_isMonitoringLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _grid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = MediaQuery.of(context).size.width;
        int crossAxisCount = w < 600 ? 2 : (w < 1100 ? 3 : 4);
        double childAspectRatio = w < 600 ? 1.4 : (w < 1100 ? 1.6 : 1.8);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}
