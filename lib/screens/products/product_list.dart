import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/screens/products/create_products.dart';
import 'package:pos/widgets/products/edit_product_sheet.dart';
import 'package:pos/widgets/products/manage_barcode_sheet.dart';
import 'package:pos/widgets/products/manage_price_sheet.dart';
import 'package:pos/widgets/products/product_details_dialog.dart';
import 'package:pos/widgets/products/products_list.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  CurrentUserResponse? currentUserResponse;
  late ProductsBloc productsBloc;
  bool _initialized = false;
  final TextEditingController _searchController = TextEditingController();
  List<ProductItem> _allProducts = [];
  List<ProductItem> _filteredProducts = [];
  String _searchQuery = '';

  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    productsBloc = getIt<ProductsBloc>();
    _loadCurrentUser();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoading && _hasMore) {
        _loadProducts();
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim();
          // No client-side filtering needed anymore as we fetch from server
          _loadProducts(reset: true);
        });
      }
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
      _initialized = true;
    });

    _loadProducts(reset: true);
  }

  void _loadProducts({bool reset = false}) {
    if (currentUserResponse == null) return;
    if (_isLoading) return;

    if (reset) {
      setState(() {
        _page = 1;
        _allProducts.clear();
        _filteredProducts.clear();
        _hasMore = true;
      });
    }

    setState(() {
      _isLoading = true;
    });

    productsBloc.add(
      GetAllProducts(
        company: currentUserResponse!.message.company.name,
        searchTerm: _searchQuery,
        page: _page,
        pageSize: _pageSize,
      ),
    );
  }

  void _refreshProducts() {
    _loadProducts(reset: true);
  }

  void _showProductDetails(ProductItem product) {
    showDialog(
      context: context,
      builder: (_) => ProductDetailsDialog(product: product),
    );
  }

  Future<void> _navigateToEditProduct(ProductItem product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(
          product: product,
          onSave: (updatedProduct) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          },
        ),
      ),
    );

    if (result == true) {
      _refreshProducts();
    }
  }

  Future<void> _navigateToManageBarcode(ProductItem product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageBarcodePage(product: product),
      ),
    );

    if (result == true) {
      _refreshProducts();
    }
  }

  Future<void> _navigateToManagePrice(ProductItem product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagePricePage(
          product: product,
          company: currentUserResponse!.message.company.name,
        ),
      ),
    );

    if (result == true) {
      _refreshProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: productsBloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text("Products List"),
          backgroundColor: const Color(0xffF6F8FB),
          actions: const [],
        ),
        body: BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductsCreateStateSuccess ||
                state is ProductsUpdateStateSuccess) {
              _isLoading = false;
              if (state is ProductsUpdateStateSuccess &&
                  state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              _refreshProducts();
            } else if (state is ProductsStateSuccess) {
              setState(() {
                _isLoading = false;
                final newProducts = state.productResponse.products;

                if (newProducts.isEmpty) {
                  _hasMore = false;
                } else {
                  if (_page == 1) {
                    _allProducts = List.from(newProducts);
                  } else {
                    // Check if we already have these products to prevent duplicates
                    // simple check based on itemCode if possible, or just add
                    _allProducts.addAll(newProducts);
                  }

                  if (newProducts.length < _pageSize) {
                    _hasMore = false;
                  } else {
                    _page++;
                  }
                  _filteredProducts = _allProducts;
                }
              });
            } else if (state is ProductsStateFailure) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search products...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              icon: Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Icon(Icons.search, color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddProductPage(),
                              ),
                            );

                            if (result == true) {
                              _refreshProducts();
                            }
                          },
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text(
                            "Add Product",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ProductsBloc, ProductsState>(
                    buildWhen: (previous, current) =>
                        current is ProductsStateSuccess ||
                        (current is ProductsStateLoading && _page == 1) ||
                        current is ProductsStateFailure,
                    builder: (context, state) {
                      if (state is ProductsStateLoading && _page == 1) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ProductsStateFailure) {
                        return Center(child: Text(state.error));
                      }

                      // Whether success or not, we display what we have in _allProducts
                      // If it's the first load and empty context, it might be effectively empty.
                      return ProductsList(
                        scrollController: _scrollController,
                        searchQuery: _searchQuery,
                        filteredProducts: _filteredProducts,
                        allProducts: _allProducts,
                        onRefresh: _refreshProducts,
                        onViewDetails: _showProductDetails,
                        onEditProduct: _navigateToEditProduct,
                        onManageBarcode: _navigateToManageBarcode,
                        onManagePrice: _navigateToManagePrice,
                        onDisable: _disableProduct,
                        onEnable: _enableProduct,
                        isLoading: _isLoading,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          splashColor: Colors.white,
          backgroundColor: Colors.blue,
          onPressed: _refreshProducts,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  void _disableProduct(ProductItem product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Product'),
        content: Text('Are you sure you want to disable ${product.itemName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              productsBloc.add(DisableProductEvent(itemCode: product.itemCode));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _enableProduct(ProductItem product) {
    productsBloc.add(EnableProductEvent(itemCode: product.itemCode));
  }
}

class EditProductPage extends StatelessWidget {
  final ProductItem product;
  final Function(ProductItem) onSave;

  const EditProductPage({
    super.key,
    required this.product,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: const Color(0xffF6F8FB),
      ),
      body: EditProductSheet(product: product, onSave: onSave),
    );
  }
}

class ManageBarcodePage extends StatelessWidget {
  final ProductItem product;

  const ManageBarcodePage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      body: SafeArea(child: ManageBarcodeSheet(product: product)),
    );
  }
}

class ManagePricePage extends StatelessWidget {
  final ProductItem product;
  final String company;

  const ManagePricePage({
    super.key,
    required this.product,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Price'),
        backgroundColor: const Color(0xffF6F8FB),
      ),
      body: ManagePriceSheet(product: product, company: company),
    );
  }
}
