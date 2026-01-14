import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/seed_products_response.dart';
import 'package:pos/domain/requests/seed_item.dart';
import 'package:pos/presentation/industries/bloc/industries_bloc.dart';
import 'package:pos/screens/bussiness_type.dart';
import 'package:pos/screens/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/utils/themes/app_sizes.dart';

class CartItemData {
  final String itemCode;
  final String itemName;
  final int qty;
  final double itemPrice;
  final double buyingPrice;
  final String itemGroup;
  final String? uom;

  CartItemData({
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.itemPrice,
    required this.buyingPrice,
    required this.itemGroup,
    this.uom,
  });

  CartItemData withCompanyAbbr(String companyAbbr) {
    final combinedItemCode = '$companyAbbr$itemCode';
    return CartItemData(
      itemCode: combinedItemCode,
      itemName: itemName,
      qty: qty,
      itemPrice: itemPrice,
      buyingPrice: buyingPrice,
      itemGroup: itemGroup,
      uom: uom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'item_name': itemName,
      'qty': qty,
      'item_price': itemPrice,
      'buying_price': buyingPrice,
      'item_group': itemGroup,
      if (uom != null) 'uom': uom,
    };
  }

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    return CartItemData(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      qty: json['qty'] ?? 0,
      itemPrice: (json['item_price'] ?? 0.0).toDouble(),
      buyingPrice: (json['buying_price'] ?? 0.0).toDouble(),
      itemGroup: json['item_group'] ?? 'Consumable',
      uom: json['uom'],
    );
  }
}

class ProductsGridPage extends StatefulWidget {
  final String industry;

  const ProductsGridPage({super.key, required this.industry});

  @override
  State<ProductsGridPage> createState() => _ProductsGridPageState();
}

class _ProductsGridPageState extends State<ProductsGridPage> {
  List<PharmacyProduct> selectedProducts = [];
  Map<String, CartItemData> cartItemsMap = {};
  List<PharmacyProduct> products = [];
  List<PharmacyProduct> filteredProducts = [];
  bool isLoading = true;
  bool isSendingToBackend = false;
  CurrentUserResponse? currentUserResponse;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductsAndCart();
    _loadCurrentUser();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      filteredProducts = products
          .where(
            (product) =>
                (product.name?.toLowerCase() ?? '').contains(
                  _searchController.text.toLowerCase(),
                ) ||
                (product.sku?.toLowerCase() ?? '').contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
    debugPrint(userString);
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    debugPrint(savedUser.toString());
    if (!mounted || savedUser == null) return;

    setState(() {
      currentUserResponse = savedUser;
    });
  }

  Future<void> _loadProductsAndCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final productsData = prefs.getString('productsData');
      if (productsData != null) {
        final Map<String, dynamic> data = jsonDecode(productsData);
        if (data['products'] is List) {
          setState(() {
            products = (data['products'] as List)
                .map((product) => PharmacyProduct.fromJson(product))
                .where((product) => product.sku != null && product.name != null)
                .toList();
            filteredProducts = List.from(products);
          });
        }
      }

      final cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final Map<String, dynamic> data = jsonDecode(cartData);
        if (data['items'] is Map) {
          setState(() {
            cartItemsMap = (data['items'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                CartItemData.fromJson(value as Map<String, dynamic>),
              ),
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cartItemsToSave = cartItemsMap.map((key, value) {
        if (currentUserResponse != null &&
            currentUserResponse!.message.company.abbr.isNotEmpty) {
          final currentItemCode = value.itemCode;
          final companyAbbr = currentUserResponse!.message.company.abbr;
          if (!currentItemCode.startsWith(companyAbbr)) {
            final updatedItem = value.withCompanyAbbr(companyAbbr);
            return MapEntry(updatedItem.itemCode, updatedItem);
          }
        }
        return MapEntry(key, value);
      });

      final cartData = {
        'price_list': 'Standard Selling',
        'items': cartItemsToSave.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };

      await prefs.setString('cart_items', jsonEncode(cartData));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  void _showQuantityDialog(PharmacyProduct product) {
    if (product.sku == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product SKU is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final existingItem = cartItemsMap[product.sku!];
    final quantityController = TextEditingController(
      text: existingItem?.qty.toString() ?? '1',
    );
    final priceController = TextEditingController(
      text: existingItem?.itemPrice.toStringAsFixed(2) ?? '0.00',
    );
    final buyingPriceController = TextEditingController(
      text: existingItem?.buyingPrice.toStringAsFixed(2) ?? '0.00',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingItem != null ? 'Update itm' : 'Add itm',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.name ?? 'Product',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${product.sku ?? "N/A"}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 28,
                            ),
                            onPressed: () {
                              int currentQty =
                                  int.tryParse(quantityController.text) ?? 1;
                              if (currentQty > 1) {
                                quantityController.text = (currentQty - 1)
                                    .toString();
                                setModalState(() {});
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 28,
                            ),
                            onPressed: () {
                              int currentQty =
                                  int.tryParse(quantityController.text) ?? 1;
                              quantityController.text = (currentQty + 1)
                                  .toString();
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Selling Price per unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => setModalState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: buyingPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Buying Price per unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => setModalState(() {}),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (existingItem != null)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[50],
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    cartItemsMap.remove(product.sku!);
                                    _saveCartToPrefs();
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Remove'),
                              ),
                            ),
                          if (existingItem != null) const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                final quantity =
                                    int.tryParse(quantityController.text) ?? 1;
                                final price =
                                    double.tryParse(priceController.text) ??
                                    0.0;
                                final buyingPrice =
                                    double.tryParse(
                                      buyingPriceController.text,
                                    ) ??
                                    0.0;

                                if (price <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid selling price',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (product.name == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Product name is missing'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  cartItemsMap[product.sku!] = CartItemData(
                                    itemCode: product.sku!,
                                    itemName: product.name!,
                                    qty: quantity,
                                    itemPrice: price,
                                    buyingPrice: buyingPrice,
                                    itemGroup: "Consumable",
                                    uom: 'Nos',
                                  );
                                });
                                _saveCartToPrefs();
                                Navigator.pop(context);
                              },
                              child: Text(
                                existingItem != null ? 'Update itm' : 'Add itm',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _sendToBackend() {
    if (cartItemsMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if currentUserResponse is null
    if (currentUserResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final items = cartItemsMap.values
        .map(
          (item) => OrderItemRequest(
            itemCode: item.itemCode,
            itemName: item.itemName,
            qty: item.qty,
            itemPrice: item.itemPrice,
            buyingPrice: item.buyingPrice,
            itemGroup: item.itemGroup,
            uom: item.uom ?? 'Nos',
            warehouse: currentUserResponse!.message.defaultWarehouse,
            basicRate: item.itemPrice,
          ),
        )
        .toList();

    final request = CreateOrderRequest(
      priceList: 'Standard Selling',
      items: items,
      buyingPriceList: 'Standard Buying',
      warehouse: currentUserResponse!.message.defaultWarehouse,
      company: currentUserResponse!.message.company.companyName,
      industry: currentUserResponse!.message.posIndustry.name,
    );

    context.read<IndustriesBloc>().add(SeedItems(createOrderRequest: request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IndustriesBloc, IndustriesState>(
      listener: (context, state) {
        if (state is IndustriesLoading) {
          setState(() {
            isSendingToBackend = true;
          });
        } else if (state is IndustriesSeedItemState) {
          setState(() {
            isSendingToBackend = false;
            cartItemsMap.clear();
          });
          _saveCartToPrefs();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Success! Created: ${state.createOrderResponse.message.created}, '
                'Skipped: ${state.createOrderResponse.message.skipped}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to DashboardPage after successful submission
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const DashboardPage()),
                (route) => false,
              );
            }
          });
        } else if (state is IndustriesFailure) {
          setState(() {
            isSendingToBackend = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context2) => BussinessTypePage()),
              );
            },
          ),
          title: Text(
            "Item List",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
            ? const Center(child: Text('No products available'))
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.padding,
                  vertical: 12,
                ),
                child: _buildProductsTable(),
              ),
        floatingActionButton: cartItemsMap.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: isSendingToBackend ? null : _sendToBackend,
                backgroundColor: isSendingToBackend
                    ? Colors.grey
                    : AppColors.blue,
                icon: isSendingToBackend
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload, color: Colors.white),
                label: Text(
                  isSendingToBackend ? 'Sending...' : 'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildProductsTable() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final allSelected =
        filteredProducts.isNotEmpty &&
        filteredProducts.every((p) => cartItemsMap.containsKey(p.sku));

    final double horizontalPadding = AppSizes.padding * 2;
    final double contentWidth = screenWidth - horizontalPadding;

    return Column(
      children: [
        // Beautiful Search Field
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products by name or SKU...',
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.blue,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _onSearchChanged();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
              ),
            ),
          ),
        ),

        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No products match your search',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: isMobile
                        ? const NeverScrollableScrollPhysics()
                        : const ScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: isMobile ? contentWidth : 800,
                        maxWidth: isMobile ? contentWidth : double.infinity,
                      ),
                      child: DataTable(
                        columnSpacing: isMobile ? 8 : 20,
                        horizontalMargin: isMobile ? 8 : 20,
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey[200],
                        ),
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 64,
                        columns: isMobile
                            ? [
                                DataColumn(
                                  label: SizedBox(
                                    width: 24,
                                    child: Checkbox(
                                      value: allSelected,
                                      onChanged: (value) =>
                                          _toggleSelectAll(value),
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Product',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Qty',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Price',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ]
                            : [
                                DataColumn(
                                  label: Row(
                                    children: [
                                      Checkbox(
                                        value: allSelected,
                                        onChanged: (value) =>
                                            _toggleSelectAll(value),
                                      ),
                                      const Text(
                                        'Category',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Product',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Quantity',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Buying Price',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Selling Price',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Actions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                        rows: filteredProducts.map((product) {
                          final isInCart = cartItemsMap.containsKey(
                            product.sku,
                          );
                          final cartItem = cartItemsMap[product.sku];

                          if (isMobile) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 24,
                                    child: Checkbox(
                                      value: isInCart,
                                      onChanged: (value) =>
                                          _showQuantityDialog(product),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  GestureDetector(
                                    onTap: () => _showQuantityDialog(product),
                                    child: SizedBox(
                                      width: contentWidth * 0.45,
                                      child: Text(
                                        product.name ?? 'Unnamed',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    isInCart ? '${cartItem?.qty ?? 0}' : '-',
                                    style: TextStyle(
                                      fontWeight: isInCart
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isInCart
                                          ? AppColors.blue
                                          : Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    isInCart
                                        ? '${cartItem?.itemPrice.toStringAsFixed(0)}'
                                        : '-',
                                    style: TextStyle(
                                      color: isInCart
                                          ? AppColors.blue
                                          : Colors.grey,
                                      fontWeight: isInCart
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    Checkbox(
                                      value: isInCart,
                                      onChanged: (value) =>
                                          _showQuantityDialog(product),
                                    ),
                                    const Text('Consumable'),
                                  ],
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () => _showQuantityDialog(product),
                                  child: SizedBox(
                                    width: 180,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          product.name ?? 'Unnamed',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          product.sku ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  isInCart ? '${cartItem?.qty ?? 0}' : '-',
                                  style: TextStyle(
                                    fontWeight: isInCart
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isInCart
                                        ? AppColors.blue
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  isInCart
                                      ? '${cartItem?.buyingPrice.toStringAsFixed(2)}'
                                      : '-',
                                  style: TextStyle(
                                    color: isInCart
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  isInCart
                                      ? '${cartItem?.itemPrice.toStringAsFixed(2)}'
                                      : '-',
                                  style: TextStyle(
                                    color: isInCart
                                        ? AppColors.blue
                                        : Colors.grey,
                                    fontWeight: isInCart
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_note,
                                        color: AppColors.blue,
                                      ),
                                      onPressed: () =>
                                          _showQuantityDialog(product),
                                      tooltip: 'Edit quantity/price',
                                    ),
                                    if (isInCart)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            cartItemsMap.remove(product.sku);
                                            _saveCartToPrefs();
                                          });
                                        },
                                        tooltip: 'Remove',
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        for (var product in filteredProducts) {
          if (product.sku != null && product.name != null) {
            if (!cartItemsMap.containsKey(product.sku)) {
              cartItemsMap[product.sku!] = CartItemData(
                itemCode: product.sku!,
                itemName: product.name!,
                qty: 1,
                itemPrice: 0.0,
                buyingPrice: 0.0,
                itemGroup: "Consumable",
                uom: 'Nos',
              );
            }
          }
        }
      } else {
        for (var product in filteredProducts) {
          if (product.sku != null) {
            cartItemsMap.remove(product.sku);
          }
        }
      }
      _saveCartToPrefs();
    });
  }
}
