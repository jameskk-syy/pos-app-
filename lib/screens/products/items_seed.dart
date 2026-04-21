import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/seed_products_response.dart';
import 'package:pos/domain/requests/products/seed_item.dart';
import 'package:pos/presentation/industries/bloc/industries_bloc.dart';
import 'package:pos/screens/users/bussiness_type.dart';
import 'package:pos/screens/sales/dashboard.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/utils/themes/app_sizes.dart';
import 'package:pos/screens/products/widgets/item_seed_widgets.dart';

class CartItemData {
  final String itemCode, itemName, itemGroup;
  final int qty;
  final double itemPrice, buyingPrice;
  final String? uom;
  CartItemData({required this.itemCode, required this.itemName, required this.qty, required this.itemPrice, required this.buyingPrice, required this.itemGroup, this.uom});
  CartItemData withCompanyAbbr(String companyAbbr) => CartItemData(itemCode: '$companyAbbr$itemCode', itemName: itemName, qty: qty, itemPrice: itemPrice, buyingPrice: buyingPrice, itemGroup: itemGroup, uom: uom);
  Map<String, dynamic> toJson() => {'item_code': itemCode, 'item_name': itemName, 'qty': qty, 'item_price': itemPrice, 'buying_price': buyingPrice, 'item_group': itemGroup, if (uom != null) 'uom': uom};
  factory CartItemData.fromJson(Map<String, dynamic> json) => CartItemData(itemCode: json['item_code'] ?? '', itemName: json['item_name'] ?? '', qty: json['qty'] ?? 0, itemPrice: (json['item_price'] ?? 0.0).toDouble(), buyingPrice: (json['buying_price'] ?? 0.0).toDouble(), itemGroup: json['item_group'] ?? 'Consumable', uom: json['uom']);
}

class ProductsGridPage extends StatefulWidget {
  final String industry;
  const ProductsGridPage({super.key, required this.industry});
  @override
  State<ProductsGridPage> createState() => _ProductsGridPageState();
}

class _ProductsGridPageState extends State<ProductsGridPage> {
  Map<String, CartItemData> cartItemsMap = {};
  List<PharmacyProduct> products = [], filteredProducts = [];
  bool isLoading = true, isSendingToBackend = false;
  CurrentUserResponse? currentUserResponse;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductsAndCart(); _loadCurrentUser();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() => filteredProducts = products.where((p) => (p.name?.toLowerCase() ?? '').contains(query) || (p.sku?.toLowerCase() ?? '').contains(query)).toList());
  }

  Future<void> _loadCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (!mounted || userString == null) return;
    setState(() => currentUserResponse = CurrentUserResponse.fromJson(jsonDecode(userString)));
  }

  Future<void> _loadProductsAndCart() async {
    try {
      final storage = getIt<StorageService>();
      final pData = await storage.getString('productsData');
      if (pData != null) {
        final data = jsonDecode(pData);
        if (data['products'] is List) {
          setState(() {
            products = (data['products'] as List).map((p) => PharmacyProduct.fromJson(p)).where((p) => p.sku != null && p.name != null).toList();
            filteredProducts = List.from(products);
          });
        }
      }
      final cData = await storage.getString('cart_items');
      if (cData != null) {
        final data = jsonDecode(cData);
        if (data['items'] is Map) setState(() => cartItemsMap = (data['items'] as Map<String, dynamic>).map((k, v) => MapEntry(k, CartItemData.fromJson(v))));
      }
    } finally { setState(() => isLoading = false); }
  }

  Future<void> _saveCartToPrefs() async {
    final storage = getIt<StorageService>();
    final savedItems = cartItemsMap.map((k, v) {
      if (currentUserResponse != null && currentUserResponse!.message.company.abbr.isNotEmpty) {
        if (!v.itemCode.startsWith(currentUserResponse!.message.company.abbr)) {
          final updated = v.withCompanyAbbr(currentUserResponse!.message.company.abbr);
          return MapEntry(updated.itemCode, updated);
        }
      }
      return MapEntry(k, v);
    });
    await storage.setString('cart_items', jsonEncode({'price_list': 'Standard Selling', 'items': savedItems.map((k, v) => MapEntry(k, v.toJson()))}));
  }

  void _showQuantityDialog(PharmacyProduct product) {
    if (product.sku == null || product.name == null) return;
    showDialog(
      context: context,
      builder: (_) => ProductQuantityDialog(
        product: product,
        existingItem: cartItemsMap[product.sku!],
        onSave: (qty, price, bPrice) {
          setState(() => cartItemsMap[product.sku!] = CartItemData(itemCode: product.sku!, itemName: product.name!, qty: qty, itemPrice: price, buyingPrice: bPrice, itemGroup: "Consumable", uom: 'Nos'));
          _saveCartToPrefs();
        },
        onRemove: () { setState(() => cartItemsMap.remove(product.sku!)); _saveCartToPrefs(); },
      ),
    );
  }

  void _sendToBackend() {
    if (cartItemsMap.isEmpty || currentUserResponse == null) return;
    final items = cartItemsMap.values.map((i) => OrderItemRequest(itemCode: i.itemCode, itemName: i.itemName, qty: i.qty, itemPrice: i.itemPrice, buyingPrice: i.buyingPrice, itemGroup: i.itemGroup, uom: i.uom ?? 'Nos', warehouse: currentUserResponse!.message.defaultWarehouse, basicRate: i.buyingPrice)).toList();
    context.read<IndustriesBloc>().add(SeedItems(createOrderRequest: CreateOrderRequest(priceList: 'Standard Selling', items: items, buyingPriceList: 'Standard Buying', warehouse: currentUserResponse!.message.defaultWarehouse, company: currentUserResponse!.message.company.companyName, industry: currentUserResponse!.message.posIndustry.name)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IndustriesBloc, IndustriesState>(
      listener: (context, state) {
        if (state is IndustriesLoading) {
          setState(() => isSendingToBackend = true);
        } else if (state is IndustriesSeedItemState) {
          setState(() { isSendingToBackend = false; cartItemsMap.clear(); }); _saveCartToPrefs();
          getIt<StorageService>().setBool('is_seeded', true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Success! Created: ${state.createOrderResponse.message.created}, Skipped: ${state.createOrderResponse.message.skipped}'), backgroundColor: Colors.green));
          final navigator = Navigator.of(context);
          Future.delayed(const Duration(milliseconds: 500), () { if (mounted) navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const DashboardPage()), (r) => false); });
        } else if (state is IndustriesFailure) { setState(() => isSendingToBackend = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red)); }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.chevron_left, size: 32), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BussinessTypePage()))),
          title: const Text("Item List", style: TextStyle(fontWeight: FontWeight.w600)), centerTitle: true,
        ),
        body: isLoading ? const Center(child: CircularProgressIndicator()) : products.isEmpty ? const Center(child: Text('No products available')) : _buildBody(),
        floatingActionButton: cartItemsMap.isNotEmpty ? _buildFab() : null,
      ),
    );
  }

  Widget _buildBody() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth < 600 ? double.infinity : 1000),
          child: Column(
            children: [
              ProductSeedSearchField(controller: _searchController, onClear: () { _searchController.clear(); _onSearchChanged(); }, onChanged: _onSearchChanged),
              Expanded(child: ProductSeedTable(products: filteredProducts, cartItemsMap: cartItemsMap, onSelect: _showQuantityDialog, onRemove: (sku) { setState(() => cartItemsMap.remove(sku)); _saveCartToPrefs(); }, isMobile: screenWidth < 600, contentWidth: screenWidth - (AppSizes.padding * 2))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: isSendingToBackend ? null : _sendToBackend,
      backgroundColor: isSendingToBackend ? Colors.grey : AppColors.blue,
      icon: isSendingToBackend ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.cloud_upload, color: Colors.white),
      label: Text(isSendingToBackend ? 'Sending...' : 'Submit', style: const TextStyle(color: Colors.white)),
    );
  }
}
