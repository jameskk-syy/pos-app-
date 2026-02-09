import 'dart:convert';

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
import 'package:pos/domain/models/pos_session_model.dart';
import 'package:pos/screens/pages/point_of_sale/add_cart.dart';
import 'package:pos/screens/pages/point_of_sale/app_bar.dart';
import 'package:pos/screens/pages/point_of_sale/buttons_widget.dart';
import 'package:pos/screens/pages/point_of_sale/summary.dart';
import 'package:pos/screens/sales/invoices_page.dart';
import 'package:pos/utils/cart_manager.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'dart:async';

import 'package:pos/widgets/sales/customer_dropdown.dart';
import 'package:pos/widgets/sales/open_session_dialog.dart';
import 'package:pos/widgets/inventory/warehouse_dropdown.dart';
import 'package:pos/widgets/common/barcode_scanner_screen.dart';
import 'package:pos/core/services/storage_service.dart';

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
  List<ProductItem> _displayedProducts = [];
  bool _isLoadingProducts = true;
  String? _productsError;

  List<ItemGroup> _categories = [];
  String? _selectedCategory;
  final List<InventoryDiscountRule> _discountRules = [];

  // Infinite Scroll variables
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
            _currentPage = 1; // Reset to first page
            _hasMore = true;
            _allProducts.clear();
            _fetchProducts(
              currentUserResponse?.message.company.name,
              _searchQuery,
              _selectedCategory,
              selectedWarehouse?.name,
            );
          });
        }
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoadingProducts) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    if (currentUserResponse != null) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      _fetchProducts(
        currentUserResponse!.message.company.name,
        _searchQuery,
        _selectedCategory,
        selectedWarehouse?.name,
      );
    }
  }

  void _filterProducts() {
    _displayedProducts = List.from(_allProducts);
  }

  void _initializeWalkInCustomer() {
    final walkInCustomer = Customer(
      name: "Walk-in Customer",
      customerName: "Walk-in Customer",
      customerType: "Individual",
      disabled: 0,
      creditLimit: 0.0,
      outstandingAmount: 0.0,
      availableCredit: 0.0,
      creditUtilizationPercent: 0.0,
      isOverLimit: false,
    );

    setState(() {
      selectedCustomer = walkInCustomer;
      customers.add(walkInCustomer);
    });
  }

  Future<void> _loadCart() async {
    final loadedCart = await CartManager.getCart();
    final count = await CartManager.getCartCount();
    setState(() {
      cart = loadedCart;
      cartCount = count;
    });
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;

    setState(() {
      currentUserResponse = savedUser;
    });
    _fetchWarehouses(currentUserResponse!.message.company.name);
    _fetchProducts(
      currentUserResponse!.message.company.name,
      _searchQuery,
      _selectedCategory,
      selectedWarehouse?.name,
    );
    _fetchDiscountRules();
  }

  void _fetchDiscountRules() {
    if (currentUserResponse != null) {
      context.read<InventoryBloc>().add(
        GetInventoryDiscountRules(
          request: GetInventoryDiscountRulesRequest(
            ruleType: 'Item',
            company: currentUserResponse!.message.company.name,
            pageSize: 1000, // Fetch all for lookup
          ),
        ),
      );
      // Also fetch Item Group rules
      context.read<InventoryBloc>().add(
        GetInventoryDiscountRules(
          request: GetInventoryDiscountRulesRequest(
            ruleType: 'Item Group',
            company: currentUserResponse!.message.company.name,
            pageSize: 1000,
          ),
        ),
      );
    }
  }

  Future<void> _fetchCategories() async {
    context.read<ProductsBloc>().add(GetItemGroup());
  }

  Future<void> _fetchWarehouses([String? name]) async {
    context.read<StoreBloc>().add(GetAllStores(company: name ?? ''));
  }

  Future<void> _fetchProducts([
    String? name,
    String? searchTerm,
    String? category,
    String? warehouse,
  ]) async {
    if (name != null && name.isNotEmpty) {
      context.read<ProductsBloc>().add(
        GetAllProducts(
          company: name,
          searchTerm: searchTerm ?? '',
          itemGroup: category,
          warehouse: warehouse,
          page: _currentPage,
          pageSize: _pageSize,
        ),
      );
    }
  }

  void _showAddToCartDialog(ProductItem product) {
    showDialog(
      context: context,
      builder: (context) => AddToCartDialog(
        product: Products(
          id: product.itemCode,
          name: product.itemName,
          price: product.price,
          image: product.image ?? "📦",
          category: product.itemGroup,
          stockQty: product.stockQty,
          uom: product.stockUom,
        ),
        onAdd: (quantity, amount) async {
          await CartManager.addToCart(
            Products(
              id: product.itemCode,
              name: product.itemName,
              price: product.price,
              image: product.image ?? "📦",
              category: product.itemGroup,
              stockQty: product.stockQty,
              uom: product.stockUom,
            ),
            quantity: quantity,
            discountRules: _discountRules,
          );
          await _loadCart();

          if (mounted) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$quantity x ${product.itemName} added to cart'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _openBarcodeScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result != null && result.isNotEmpty) {
      if (mounted) {
        context.read<ProductsBloc>().add(
          SearchProductByBarcode(
            barcode: result,
            posProfile: currentUserResponse?.message.posProfile.name ?? '',
          ),
        );
      }
    }
  }

  void _showCustomerSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (context) => getIt<CrmBloc>(),
          child: CustomerSelectionBottomSheet(
            selectedCustomer: selectedCustomer,
            company: currentUserResponse?.message.company.name,
            onCustomerSelected: (customer) {
              setState(() {
                selectedCustomer = customer;
              });
            },
          ),
        );
      },
    );
  }

  void _showOpenSessionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return OpenSessionBottomSheet(
          company: currentUserResponse!.message.company.name,
          currentUser: currentUserResponse!.message.user.name,
          profilePos: currentUserResponse!.message.posProfile.name,
          onSessionOpened: (session) {
            setState(() {});
          },
        );
      },
    );
  }

  void _showWarehouseSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (context) => getIt<StoreBloc>(),
          child: WarehouseSelectionBottomSheet(
            selectedWarehouse: selectedWarehouse,
            warehouses: warehouses,
            onWarehouseSelected: (warehouse) {
              setState(() {
                selectedWarehouse = warehouse;
                _currentPage = 1;
                _allProducts.clear();
              });
              _fetchProducts(
                currentUserResponse?.message.company.name,
                _searchQuery,
                _selectedCategory,
                warehouse?.name,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateSuccess) {
              setState(() {
                warehouses = state.storeGetResponse.message.data;
                isLoadingWarehouses = false;
                if (selectedWarehouse == null) {
                  final defaultWarehouse = warehouses.firstWhere(
                    (w) => w.isDefault,
                    orElse: () => warehouses.isNotEmpty
                        ? warehouses[0]
                        : Warehouse(
                            name: '',
                            warehouseName: 'No Warehouse',
                            company: '',
                            isGroup: 0,
                            disabled: 0,
                            isMainDepot: false,
                            isDefault: false,
                          ),
                  );
                  selectedWarehouse = defaultWarehouse;
                  // Fetch products for the default warehouse
                  _currentPage = 1;
                  _allProducts.clear();
                  _fetchProducts(
                    currentUserResponse?.message.company.name,
                    _searchQuery,
                    _selectedCategory,
                    selectedWarehouse?.name,
                  );
                }
              });
            } else if (state is StoreStateFailure) {
              setState(() {
                isLoadingWarehouses = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load warehouses: ${state.error}'),
                ),
              );
            }
          },
        ),
        BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductsStateSuccess) {
              setState(() {
                if (_currentPage == 1) {
                  _allProducts = state.productResponse.products;
                } else {
                  _allProducts.addAll(state.productResponse.products);
                }
                _hasMore = state.productResponse.pagination.hasNextPage;
                _isLoadingProducts = false;
                _isLoadingMore = false;
                _filterProducts();

                if (_isAutoAddingFromBarcode) {
                  _isAutoAddingFromBarcode = false;
                  if (_allProducts.isNotEmpty) {
                    _showAddToCartDialog(_allProducts.first);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No product matches found for the scanned item.',
                        ),
                      ),
                    );
                  }
                }
              });
            } else if (state is ProductsStateLoading) {
              if (_currentPage == 1) {
                setState(() {
                  _isLoadingProducts = true;
                  _productsError = null;
                });
              }
            } else if (state is ProductsStateFailure) {
              setState(() {
                _isLoadingProducts = false;
                _isLoadingMore = false;
                _productsError = state.error;
                if (_currentPage == 1) {
                  _displayedProducts = [];
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load products: Retry please'),
                ),
              );
            } else if (state is ProductsItemGroupsStateSuccess) {
              setState(() {
                _categories = state.itemGroupResponse.message.itemGroups;
              });
            } else if (state is BarcodeSearchSuccess) {
              setState(() {
                _isAutoAddingFromBarcode = true;
                _searchController.text = state.product.itemName;
                _searchQuery = state.product.itemName;
                _currentPage = 1;
                _allProducts.clear();
              });
              _fetchProducts(
                currentUserResponse?.message.company.name,
                state.product.itemName,
                _selectedCategory,
                selectedWarehouse?.name,
              );
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is GetInventoryDiscountRulesLoaded) {
              setState(() {
                final newRules = state.response.message.data.rules
                    .map((e) => InventoryDiscountRule.fromApiModel(e))
                    .toList();

                // Merge with existing rules, avoiding duplicates
                for (var rule in newRules) {
                  if (!_discountRules.any((r) => r.name == rule.name)) {
                    _discountRules.add(rule);
                  }
                }
              });
            }
          },
        ),
        BlocListener<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is POSSessionClosed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              getIt<StorageService>().remove('current_pos_session');

              _showOpenSessionBottomSheet();
            } else if (state is POSSessionCloseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is POSSessionCloseLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Closing session...'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: POSAppBar(
          statusText: 'Open session',
          statusColor: Colors.green,
          onBackPressed: () => Navigator.pop(context),
          onStatusPressed: _showOpenSessionBottomSheet,
        ),
        body: Column(
          children: [
            // Fixed height for the header section
            Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height *
                    0.45, // 45% of screen height
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    POSActionButtons(
                      onInvoicesPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvoicesPage(),
                          ),
                        );
                      },
                      onCloseSession: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final isTablet = constraints.maxWidth >= 600;
                                return AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  insetPadding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 100.0 : 20.0,
                                    vertical: 24.0,
                                  ),
                                  title: const Text('Close Session'),
                                  content: SizedBox(
                                    width: isTablet ? 500 : double.maxFinite,
                                    child: const Text(
                                      'Are you sure you want to close this session?',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        // Capture bloc before popping
                                        final salesBloc = context
                                            .read<SalesBloc>();
                                        Navigator.pop(context);

                                        try {
                                          final storage =
                                              getIt<StorageService>();
                                          final sessionString = await storage
                                              .getString('current_pos_session');
                                          if (sessionString != null) {
                                            final sessionJson = jsonDecode(
                                              sessionString,
                                            );

                                            String posOpeningEntry;
                                            if (sessionJson['name'] is String) {
                                              posOpeningEntry =
                                                  sessionJson['name'];
                                            } else {
                                              // Fallback: use toString() or handle if it's a map
                                              posOpeningEntry =
                                                  sessionJson['name']
                                                      .toString();
                                            }

                                            salesBloc.add(
                                              ClosePOSSession(
                                                request: ClosePOSSessionRequest(
                                                  posOpeningEntry:
                                                      posOpeningEntry,
                                                ),
                                              ),
                                            );
                                          } else {
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'No active session found',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error closing session: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      onSaveDraft: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Draft saved successfully'),
                          ),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(10, 16, 16, 12),
                      child: Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText:
                                    'Search products using any of the above filters...',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.qr_code_scanner,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: _openBarcodeScanner,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.white,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.filter_list,
                                color: Colors.grey.shade700,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Customer:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: _showCustomerSelectionBottomSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _getFirstName(
                                              selectedCustomer?.customerName ??
                                                  'Walk-in Customer',
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          size: 20,
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Warehouse*',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: _showWarehouseSelectionBottomSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedWarehouse?.warehouseName ??
                                                'Select Warehouse',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (isLoadingWarehouses)
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.grey.shade600,
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons.arrow_drop_down,
                                            size: 20,
                                            color: Colors.grey.shade600,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = null;
                                _currentPage = 1;
                                _hasMore = true;
                                _allProducts.clear();
                                _fetchProducts(
                                  currentUserResponse?.message.company.name,
                                  _searchQuery,
                                  _selectedCategory,
                                );
                              });
                            },
                            child: _buildChip(
                              'All Items',
                              _selectedCategory == null,
                            ),
                          ),
                          ..._categories.map((category) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category.name;
                                  _currentPage = 1;
                                  _hasMore = true;
                                  _allProducts.clear();
                                  _fetchProducts(
                                    currentUserResponse?.message.company.name,
                                    _searchQuery,
                                    _selectedCategory,
                                  );
                                });
                              },
                              child: _buildChip(
                                category.name,
                                _selectedCategory == category.name,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Product',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 60,
                            child: Text(
                              'Stock Qty',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                            child: Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 60,
                            child: Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                            child: Text(
                              'Actions',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Products list that takes remaining space
            Expanded(child: _buildProductsList()),
            // Fixed bottom button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _loadCart();
                    if (mounted) {
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaleSummaryPage(
                            selectedCustomer: selectedCustomer!,
                            selectedWarehouse: selectedWarehouse!.name,
                            company: currentUserResponse!.message.company.name,
                            posName:
                                currentUserResponse!.message.posProfile.name,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'View Cart',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoadingProducts && _currentPage == 1) {
      return Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (_productsError != null) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Failed to load products',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Retry please, to fetch  new products",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (currentUserResponse != null) {
                    setState(() {
                      _currentPage = 1;
                      _allProducts.clear();
                    });
                    _fetchProducts(currentUserResponse!.message.company.name);
                  }
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_displayedProducts.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, color: Colors.grey.shade400, size: 48),
              SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No products available'
                    : 'No products found',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Try a different search term',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _displayedProducts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _displayedProducts.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
          );
        }
        final product = _displayedProducts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    product.image ?? "📦",
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.itemName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.itemCode,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  product.stockQty.toStringAsFixed(2),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  product.price.toStringAsFixed(2),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  product.itemGroup,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 50,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.blue,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showAddToCartDialog(product),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        backgroundColor: selected ? Colors.blue : Colors.white,
        side: BorderSide(color: selected ? Colors.blue : Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  String _getFirstName(String fullName) {
    List<String> nameParts = fullName.split(' ');

    if (nameParts.length <= 2) {
      return fullName;
    }
    return nameParts.take(2).join(' ');
  }
}
