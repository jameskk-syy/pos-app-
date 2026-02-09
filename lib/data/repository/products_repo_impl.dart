import 'package:pos/data/datasource/sales_remote_datasource.dart';
import 'package:pos/data/datasource/products_remote_datasource.dart';
import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/data/datasource/inventory_datasource.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/domain/requests/products/create_product.dart';
import 'package:pos/domain/requests/inventory/stock_request.dart';
import 'package:pos/domain/responses/products/create_product_response.dart';
import 'package:pos/domain/responses/products/item_brand.dart';
import 'package:pos/domain/responses/products/item_group.dart';
import 'package:pos/domain/responses/products/item_list.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/inventory/stock_reco.dart';
import 'package:pos/domain/responses/uom_response.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/models/pos_opening_entry_model.dart';
import 'package:pos/domain/responses/products/product_price_response.dart';
import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';

class ProductsRepoImpl implements ProductsRepo {
  final ProductsRemoteDataSource productsRemoteDataSource;
  final RemoteDataSource remoteDataSource;
  final InventoryRemoteDataSource inventoryRemoteDataSource;
  final SalesRemoteDataSource salesRemoteDataSource;

  final ConnectivityService connectivityService;
  final LocalDataSource localDataSource;

  ProductsRepoImpl({
    required this.productsRemoteDataSource,
    required this.remoteDataSource,
    required this.inventoryRemoteDataSource,
    required this.salesRemoteDataSource,
    required this.connectivityService,
    required this.localDataSource,
  });

  @override
  Future<ProductResponseSimple> getAllProducts(
    String company, {
    String? searchTerm,
    String? itemGroup,
    String? brand,
    String? warehouse,
    int page = 1,
    int pageSize = 20,
  }) async {
    // Check internet connectivity first
    final isConnected = await connectivityService.checkNow();

    if (!isConnected) {
      // No internet - go directly to cache
      // debugPrint('No internet connection - loading from cache...');
      final cachedResult = _getCachedProducts(searchTerm);
      // debugPrint(
      //   'Loaded ${cachedResult.products.length} products from cache',
      // );
      return cachedResult;
    }

    // Internet is available - try remote first
    bool remoteSuccess = false;
    ProductResponseSimple? remoteResult;

    try {
      remoteResult = await productsRemoteDataSource.getProducts(
        company,
        searchTerm: searchTerm,
        itemGroup: itemGroup,
        brand: brand,
        warehouse: warehouse,
        page: page,
        pageSize: pageSize,
      );
      remoteSuccess = true;

      // Cache successful results
      if (remoteResult.products.isNotEmpty) {
        try {
          final productsData = remoteResult.products
              .map((p) => p.toJson())
              .toList();
          localDataSource.cacheProducts(productsData, clear: page == 1);
          // debugPrint('Cached ${productsData.length} products');
        } catch (e) {
          // debugPrint("Failed to cache products: $e");
        }
      }
    } catch (e) {
      // Catch all network errors including DNS failures, timeouts, connection errors
      // debugPrint('Remote fetch failed (will try cache): $e');
      remoteSuccess = false;
    }

    // Return remote result if successful
    if (remoteSuccess && remoteResult != null) {
      return remoteResult;
    }

    // Try to return cached products as fallback
    // debugPrint('Attempting to load products from cache...');
    final cachedResult = _getCachedProducts(searchTerm);
    // debugPrint(
    //   'Loaded ${cachedResult.products.length} products from cache',
    // );
    return cachedResult;
  }

  ProductResponseSimple _getCachedProducts(String? searchTerm) {
    final cachedProducts = localDataSource.getCachedProducts();

    List<ProductItem> productList = [];
    if (cachedProducts.isNotEmpty) {
      productList = cachedProducts.map((e) => ProductItem.fromJson(e)).toList();

      // Filter based on search term if present (local search)
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final term = searchTerm.toLowerCase();
        productList = productList.where((p) {
          return p.itemName.toLowerCase().contains(term) ||
              p.itemCode.toLowerCase().contains(term);
        }).toList();
      }
    }

    return ProductResponseSimple(
      products: productList,
      // Mock pagination for offline
      pagination: PaginationInfo(
        page: 1,
        pageSize: productList.length,
        total: productList.length,
        totalPages: productList.isEmpty ? 0 : 1,
      ),
      priceList: '',
      warehouse: '',
    );
  }

  @override
  Future<BrandResponse> getBrand() async {
    return await productsRemoteDataSource.getItemBrands();
  }

  @override
  Future<PriceListResponse> getPriceLists(String company) async {
    return await productsRemoteDataSource.getPriceLists(company);
  }

  @override
  Future<void> createPriceList({
    required String company,
    required String priceListName,
    required String currency,
    required bool enabled,
    required bool buying,
    required bool selling,
  }) async {
    await productsRemoteDataSource.createPriceList(
      company: company,
      priceListName: priceListName,
      currency: currency,
      enabled: enabled,
      buying: buying,
      selling: selling,
    );
  }

  @override
  Future<void> updatePriceList({
    required String name,
    required String newPriceListName,
    required String currency,
    required bool enabled,
    required bool buying,
    required bool selling,
  }) async {
    await productsRemoteDataSource.updatePriceList(
      name: name,
      newPriceListName: newPriceListName,
      currency: currency,
      enabled: enabled,
      buying: buying,
      selling: selling,
    );
  }

  @override
  Future<void> createBrand(String company, String brandName) async {
    await productsRemoteDataSource.createBrand(company, brandName);
  }

  @override
  Future<void> updateBrand(String oldBrandName, String newBrandName) async {
    await productsRemoteDataSource.updateBrand(oldBrandName, newBrandName);
  }

  @override
  Future<ItemGroupResponse> getItemGroup() async {
    return await productsRemoteDataSource.getItemGroups();
  }

  @override
  Future<void> createItemGroup(
    String company,
    String itemGroupName,
    String? parentItemGroup,
  ) async {
    await productsRemoteDataSource.createItemGroup(
      company,
      itemGroupName,
      parentItemGroup,
    );
  }

  @override
  Future<void> updateItemGroup(
    String company,
    String name,
    String itemGroupName,
    String? parentItemGroup,
  ) async {
    await productsRemoteDataSource.updateItemGroup(
      company,
      name,
      itemGroupName,
      parentItemGroup,
    );
  }

  @override
  Future<UOMResponse> getUnitOfmeasure() async {
    return await productsRemoteDataSource.getUom();
  }

  @override
  Future<void> createUom(String company, String uomName) async {
    await productsRemoteDataSource.createUom(company, uomName);
  }

  @override
  Future<void> deleteUom(String company, String uomName) async {
    await productsRemoteDataSource.deleteUom(company, uomName);
  }

  @override
  Future<void> updateUom(
    String name,
    String uomName,
    bool mustBeWholeNumber,
  ) async {
    await productsRemoteDataSource.updateUom(name, uomName, mustBeWholeNumber);
  }

  @override
  Future<CreateProductResponse> createProduct(
    CreateProductRequest createProductRequest,
  ) async {
    return await productsRemoteDataSource.createProduct(createProductRequest);
  }

  @override
  Future<StockItemResponse> getProductItems(
    String company, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await productsRemoteDataSource.getItemsList(
      company,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<StockResponse> addItemToStock(StockRequest stockRequest) async {
    return await inventoryRemoteDataSource.addItemToStock(stockRequest);
  }

  @override
  Future<void> addBarcode(String itemCode, String barcode) async {
    await productsRemoteDataSource.addBarcode(itemCode, barcode);
  }

  @override
  Future<void> updateProduct(CreateProductRequest request) async {
    await productsRemoteDataSource.updateProduct(request);
  }

  @override
  Future<String> disableProduct(String itemCode) async {
    return await productsRemoteDataSource.disableProduct(itemCode);
  }

  @override
  Future<void> enableProduct(String itemCode) async {
    await productsRemoteDataSource.enableProduct(itemCode);
  }

  @override
  Future<void> setProductPrice({
    required String itemCode,
    required double price,
    required String priceList,
    required String currency,
  }) async {
    await productsRemoteDataSource.setProductPrice(
      itemCode: itemCode,
      price: price,
      priceList: priceList,
      currency: currency,
    );
  }

  @override
  Future<void> setProductWarranty({
    required String company,
    required String itemCode,
    required int warrantyPeriod,
    required String warrantyPeriodUnit,
  }) async {
    await productsRemoteDataSource.setProductWarranty(
      company: company,
      itemCode: itemCode,
      warrantyPeriod: warrantyPeriod,
      warrantyPeriodUnit: warrantyPeriodUnit,
    );
  }

  @override
  Future<ProductPriceResponse> getProductPrice({
    required String itemCode,
    required String company,
    String? priceList,
  }) async {
    return await productsRemoteDataSource.getProductPrice(
      itemCode: itemCode,
      company: company,
      priceList: priceList,
    );
  }

  @override
  Future<ProductItem> searchProductByBarcode({
    required String barcode,
    required String posProfile,
  }) async {
    final isConnected = await connectivityService.checkNow();

    if (isConnected) {
      try {
        return await productsRemoteDataSource
            .searchProductByBarcode(barcode, posProfile)
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        // If API fails, try searching in cache
        final cachedProducts = localDataSource.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          try {
            final product = cachedProducts.firstWhere((p) {
              // Check if product has barcodes array
              if (p['barcodes'] == null) return false;
              final barcodes = p['barcodes'] as List;
              // Check if any barcode matches
              return barcodes.any((b) => b['barcode']?.toString() == barcode);
            });
            return ProductItem.fromJson(product);
          } catch (_) {
            // Product not found in cache, rethrow original error
            rethrow;
          }
        }
        rethrow;
      }
    } else {
      // Offline: Search in cached products
      final cachedProducts = localDataSource.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        try {
          final product = cachedProducts.firstWhere((p) {
            // Check if product has barcodes array
            if (p['barcodes'] == null) return false;
            final barcodes = p['barcodes'] as List;
            // Check if any barcode matches
            return barcodes.any((b) => b['barcode']?.toString() == barcode);
          });
          return ProductItem.fromJson(product);
        } catch (e) {
          throw Exception(
            'Product with barcode $barcode not found in cached products. '
            'Please connect to the internet to search for new products.',
          );
        }
      } else {
        throw Exception(
          'No internet connection and no cached products available. '
          'Please connect to the internet to load products.',
        );
      }
    }
  }

  @override
  Future<InvoiceListResponse> listSalesInvoices({
    required String company,
    int limit = 20,
    int offset = 0,
    String? customer,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    return await salesRemoteDataSource.listSalesInvoices(
      company: company,
      limit: limit,
      offset: offset,
      customer: customer,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
    );
  }

  @override
  Future<InvoiceListResponse> listPosInvoices({
    required String company,
    int limit = 20,
    int offset = 0,
    String? customer,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    return await salesRemoteDataSource.listPosInvoices(
      company: company,
      limit: limit,
      offset: offset,
      customer: customer,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
    );
  }

  @override
  Future<PosOpeningEntryResponse> listPosOpeningEntries({
    required String company,
    int limit = 20,
    int offset = 0,
  }) async {
    return await salesRemoteDataSource.listPosOpeningEntries(
      company: company,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<ClosePosOpeningEntryResponse> closePosOpeningEntry({
    required String posOpeningEntry,
    bool doNotSubmit = false,
  }) async {
    return await salesRemoteDataSource.closePosOpeningEntry(
      posOpeningEntry: posOpeningEntry,
      doNotSubmit: doNotSubmit,
    );
  }
}
