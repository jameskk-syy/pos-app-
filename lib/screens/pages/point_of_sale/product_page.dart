import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/product.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/item_group.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/domain/models/inventory_discount_rule.dart';
import 'package:pos/domain/requests/get_inventory_discount_rules_request.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/screens/pages/point_of_sale/add_cart.dart';
import 'package:pos/screens/pages/point_of_sale/app_bar.dart';
import 'package:pos/screens/pages/point_of_sale/buttons_widget.dart';
import 'package:pos/screens/pages/point_of_sale/summary.dart';
import 'package:pos/screens/sales/invoices_page.dart';
import 'package:pos/screens/sales/pos_opening_entries_page.dart';
import 'package:pos/utils/cart_manager.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/widgets/sales/customer_dropdown.dart';
import 'package:pos/widgets/sales/open_session_dialog.dart';
import 'package:pos/widgets/inventory/warehouse_dropdown.dart';
import 'package:pos/widgets/common/barcode_scanner_screen.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/screens/pages/point_of_sale/widgets/product_selection_widgets.dart';
import 'package:pos/screens/pages/point_of_sale/widgets/product_category_widgets.dart';
import 'package:pos/screens/pages/point_of_sale/widgets/product_list_widgets.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<CartItem> cart = [];
  int cartCount = 0;
  Customer? selectedCustomer;
  List<Customer> customers = [];
  bool isLoading = true;
  Warehouse? selectedWarehouse;
  List<Warehouse> warehouses = [];
  bool isLoadingWarehouses = true;
  CurrentUserResponse? currentUserResponse;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';

  List<ProductItem> _allProducts = [];
  bool _isLoadingProducts = true;
  String? _productsError;

  List<ItemGroup> _categories = [];
  String? _selectedCategory;
  final List<InventoryDiscountRule> _discountRules = [];

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isAutoAddingFromBarcode = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadCurrentUser();
    _initializeWalkInCustomer();
    _setupSearchListener();
    _fetchCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      if (_searchDebounce?.isActive ?? false) {
        _searchDebounce!.cancel();
      }
      _searchDebounce = Timer(const Duration(milliseconds: 800), () {
        if (_searchController.text.trim() != _searchQuery) {
          setState(() {
            _searchQuery = _searchController.text.trim();
            _currentPage = 1;
            _hasMore = true;
            _allProducts.clear();
          });
          _fetchProducts();
        }
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 && !_isLoadingMore && _hasMore && !_isLoadingProducts) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    if (currentUserResponse != null) {
      setState(() { _isLoadingMore = true; _currentPage++; });
      _fetchProducts();
    }
  }

  void _initializeWalkInCustomer() {
    final walkInCustomer = Customer(name: "Walk-in Customer", customerName: "Walk-in Customer", customerType: "Individual", disabled: 0, creditLimit: 0.0, outstandingAmount: 0.0, availableCredit: 0.0, creditUtilizationPercent: 0.0, isOverLimit: false);
    setState(() { selectedCustomer = walkInCustomer; customers.add(walkInCustomer); });
  }

  Future<void> _loadCart() async {
    final loadedCart = await CartManager.getCart();
    final count = await CartManager.getCartCount();
    setState(() { cart = loadedCart; cartCount = count; });
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) {
      return;
    }
    setState(() { currentUserResponse = savedUser; });
    _fetchWarehouses();
    _fetchProducts();
    _fetchDiscountRules();
  }

  void _fetchDiscountRules() {
    if (currentUserResponse != null) {
      context.read<InventoryBloc>().add(GetInventoryDiscountRules(request: GetInventoryDiscountRulesRequest(ruleType: 'Item', company: currentUserResponse!.message.company.name, pageSize: 1000)));
      context.read<InventoryBloc>().add(GetInventoryDiscountRules(request: GetInventoryDiscountRulesRequest(ruleType: 'Item Group', company: currentUserResponse!.message.company.name, pageSize: 1000)));
    }
  }

  void _fetchCategories() => context.read<ProductsBloc>().add(GetItemGroup());
  void _fetchWarehouses() => context.read<StoreBloc>().add(GetAllStores(company: currentUserResponse?.message.company.name ?? ''));
  void _fetchProducts() {
    if (currentUserResponse != null) {
      context.read<ProductsBloc>().add(GetAllProducts(company: currentUserResponse!.message.company.name, searchTerm: _searchQuery, itemGroup: _selectedCategory, warehouse: selectedWarehouse?.name, page: _currentPage, pageSize: _pageSize));
    }
  }

  void _showAddToCartDialog(ProductItem product) {
    showDialog(context: context, builder: (dialogContext) => AddToCartDialog(
      product: Products(id: product.itemCode, name: product.itemName, price: product.price, image: product.image ?? "📦", category: product.itemGroup, stockQty: product.stockQty, uom: product.stockUom),
      onAdd: (quantity, amount) async {
        await CartManager.addToCart(Products(id: product.itemCode, name: product.itemName, price: product.price, image: product.image ?? "📦", category: product.itemGroup, stockQty: product.stockQty, uom: product.stockUom), quantity: quantity, discountRules: _discountRules);
        await _loadCart();
        if (mounted && dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('$quantity x ${product.itemName} added to cart'), duration: const Duration(seconds: 2)));
        }
      },
    ));
  }

  Future<void> _openBarcodeScanner() async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()));
    if (result != null && result.isNotEmpty && mounted) {
      if (!context.mounted) {
        return;
      }
      context.read<ProductsBloc>().add(SearchProductByBarcode(barcode: result, posProfile: currentUserResponse?.message.posProfile.name ?? ''));
    }
  }

  void _showCustomerSelectionBottomSheet() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => BlocProvider(create: (context) => getIt<CrmBloc>(), child: CustomerSelectionBottomSheet(selectedCustomer: selectedCustomer, company: currentUserResponse?.message.company.name, onCustomerSelected: (customer) => setState(() => selectedCustomer = customer))));
  }

  void _showOpenSessionBottomSheet() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => OpenSessionBottomSheet(company: currentUserResponse!.message.company.name, currentUser: currentUserResponse!.message.user.name, profilePos: currentUserResponse!.message.posProfile.name, onSessionOpened: (session) => setState(() {})));
  }

  void _showWarehouseSelectionBottomSheet() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => BlocProvider(create: (context) => getIt<StoreBloc>(), child: WarehouseSelectionBottomSheet(
      selectedWarehouse: selectedWarehouse, warehouses: warehouses,
      onWarehouseSelected: (warehouse) {
        setState(() { selectedWarehouse = warehouse; _currentPage = 1; _allProducts.clear(); });
        _fetchProducts();
      },
    )));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(listener: (context, state) {
          if (state is StoreStateSuccess) {
            setState(() {
              warehouses = state.storeGetResponse.message.data;
              isLoadingWarehouses = false;
              if (selectedWarehouse == null) {
                selectedWarehouse = warehouses.firstWhere((w) => w.isDefault, orElse: () => warehouses.isNotEmpty ? warehouses[0] : Warehouse(name: '', warehouseName: 'No Warehouse', company: '', isGroup: 0, disabled: 0, isMainDepot: false, isDefault: false));
                _currentPage = 1; _allProducts.clear(); _fetchProducts();
              }
            });
          } else if (state is StoreStateFailure) {
            setState(() => isLoadingWarehouses = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load warehouses: ${state.error}')));
          }
        }),
        BlocListener<ProductsBloc, ProductsState>(listener: (context, state) {
          if (state is ProductsStateSuccess) {
            setState(() {
              if (_currentPage == 1) { _allProducts = state.productResponse.products; } else { _allProducts.addAll(state.productResponse.products); }
              _hasMore = state.productResponse.pagination.hasNextPage;
              _isLoadingProducts = false; _isLoadingMore = false;
              if (_isAutoAddingFromBarcode) {
                _isAutoAddingFromBarcode = false;
                if (_allProducts.isNotEmpty) {
                  _showAddToCartDialog(_allProducts.first);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No product matches found for the scanned item.')));
                }
              }
            });
          } else if (state is ProductsStateLoading) { if (_currentPage == 1) { setState(() { _isLoadingProducts = true; _productsError = null; }); } }
          else if (state is ProductsStateFailure) { setState(() { _isLoadingProducts = false; _isLoadingMore = false; _productsError = state.error; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load products: Retry please'))); }
          else if (state is ProductsItemGroupsStateSuccess) { setState(() => _categories = state.itemGroupResponse.message.itemGroups); }
          else if (state is BarcodeSearchSuccess) { setState(() { _isAutoAddingFromBarcode = true; _searchController.text = state.product.itemName; _searchQuery = state.product.itemName; _currentPage = 1; _allProducts.clear(); }); _fetchProducts(); }
        }),
        BlocListener<InventoryBloc, InventoryState>(listener: (context, state) {
          if (state is GetInventoryDiscountRulesLoaded) {
            setState(() {
              for (var rule in state.response.message.data.rules.map((e) => InventoryDiscountRule.fromApiModel(e))) {
                if (!_discountRules.any((r) => r.name == rule.name)) _discountRules.add(rule);
              }
            });
          }
        }),
        BlocListener<SalesBloc, SalesState>(listener: (context, state) {
          if (state is POSSessionClosed) {
            getIt<StorageService>().remove('current_pos_session');
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const PosOpeningEntriesPage()), (route) => route.isFirst);
          } else if (state is POSSessionCloseError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          } else if (state is POSSessionCloseLoading) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Closing session...'), duration: Duration(seconds: 1)));
          }
        }),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: POSAppBar(statusText: 'Open session', statusColor: Colors.green, onBackPressed: () => Navigator.pop(context), onStatusPressed: _showOpenSessionBottomSheet),
        body: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    POSActionButtons(
                      onInvoicesPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoicesPage())),
                      onCloseSession: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PosOpeningEntriesPage())),
                      onSaveDraft: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved successfully'))),
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(10, 16, 16, 12), child: Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))),
                    ProductSearchBar(controller: _searchController, onBarcodeScannerPressed: _openBarcodeScanner, onFilterPressed: () {}),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(children: [
                        Expanded(child: CustomerSelectionCard(selectedCustomer: selectedCustomer, onTap: _showCustomerSelectionBottomSheet)),
                        const SizedBox(width: 12),
                        Expanded(child: WarehouseSelectionCard(selectedWarehouse: selectedWarehouse, isLoading: isLoadingWarehouses, onTap: _showWarehouseSelectionBottomSheet)),
                      ]),
                    ),
                    CategoryFilterList(
                      categories: _categories, selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() { _selectedCategory = category; _currentPage = 1; _allProducts.clear(); });
                        _fetchProducts();
                      },
                    ),
                    const SizedBox(height: 12),
                    const ProductListHeader(),
                  ],
                ),
              ),
            ),
            Expanded(child: ProductListView(
              products: _allProducts, scrollController: _scrollController, hasMore: _hasMore, isLoadingProducts: _isLoadingProducts, isLoadingMore: _isLoadingMore,
              productsError: _productsError, searchQuery: _searchQuery, onRetry: _fetchProducts, onAddToCart: _showAddToCartDialog,
            )),
            Container(
              padding: const EdgeInsets.all(16.0), color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _loadCart();
                    if (mounted && context.mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SaleSummaryPage(selectedCustomer: selectedCustomer!, selectedWarehouse: selectedWarehouse!.name, company: currentUserResponse!.message.company.name, posName: currentUserResponse!.message.posProfile.name)));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('View Cart', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18, color: Colors.white)]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
