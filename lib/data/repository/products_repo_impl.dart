import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/domain/requests/create_product.dart';
import 'package:pos/domain/requests/stock_request.dart';
import 'package:pos/domain/responses/create_product_response.dart';
import 'package:pos/domain/responses/item_brand.dart';
import 'package:pos/domain/responses/item_group.dart';
import 'package:pos/domain/responses/item_list.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:pos/domain/responses/stock_reco.dart';
import 'package:pos/domain/responses/uom_response.dart';

class ProductsRepoImpl implements ProductsRepo {
  final RemoteDataSource remoteDataSource;

  ProductsRepoImpl({required this.remoteDataSource});

  @override
  Future<ProductResponseSimple> getAllProducts(
    String company, {
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await remoteDataSource.getProducts(
        company,
        searchTerm: searchTerm,
        page: page,
        pageSize: pageSize,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BrandResponse> getBrand() async {
    return await remoteDataSource.getItemBrands();
  }

  @override
  Future<PriceListResponse> getPriceLists(String company) async {
    return await remoteDataSource.getPriceLists(company);
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
    await remoteDataSource.createPriceList(
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
    await remoteDataSource.updatePriceList(
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
    await remoteDataSource.createBrand(company, brandName);
  }

  @override
  Future<void> updateBrand(String oldBrandName, String newBrandName) async {
    await remoteDataSource.updateBrand(oldBrandName, newBrandName);
  }

  @override
  Future<ItemGroupResponse> getItemGroup() async {
    return await remoteDataSource.getItemGroups();
  }

  @override
  Future<void> createItemGroup(
    String company,
    String itemGroupName,
    String? parentItemGroup,
  ) async {
    await remoteDataSource.createItemGroup(
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
    await remoteDataSource.updateItemGroup(
      company,
      name,
      itemGroupName,
      parentItemGroup,
    );
  }

  @override
  Future<UOMResponse> getUnitOfmeasure() async {
    return await remoteDataSource.getUom();
  }

  @override
  Future<void> createUom(String company, String uomName) async {
    await remoteDataSource.createUom(company, uomName);
  }

  @override
  Future<void> deleteUom(String company, String uomName) async {
    await remoteDataSource.deleteUom(company, uomName);
  }

  @override
  Future<void> updateUom(
    String name,
    String uomName,
    bool mustBeWholeNumber,
  ) async {
    await remoteDataSource.updateUom(name, uomName, mustBeWholeNumber);
  }

  @override
  Future<CreateProductResponse> createProduct(
    CreateProductRequest createProductRequest,
  ) async {
    return await remoteDataSource.createProduct(createProductRequest);
  }

  @override
  Future<StockItemResponse> getProductItems(
    String company, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await remoteDataSource.getItemsList(
      company,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<StockResponse> addItemToStock(StockRequest stockRequest) async {
    return await remoteDataSource.addItemToStock(stockRequest);
  }

  @override
  Future<void> addBarcode(String itemCode, String barcode) async {
    await remoteDataSource.addBarcode(itemCode, barcode);
  }

  @override
  Future<void> updateProduct(CreateProductRequest request) async {
    await remoteDataSource.updateProduct(request);
  }

  @override
  Future<void> disableProduct(String itemCode) async {
    await remoteDataSource.disableProduct(itemCode);
  }

  @override
  Future<void> enableProduct(String itemCode) async {
    await remoteDataSource.enableProduct(itemCode);
  }

  @override
  Future<void> setProductPrice({
    required String itemCode,
    required double price,
    required String priceList,
    required String currency,
  }) async {
    await remoteDataSource.setProductPrice(
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
    await remoteDataSource.setProductWarranty(
      company: company,
      itemCode: itemCode,
      warrantyPeriod: warrantyPeriod,
      warrantyPeriodUnit: warrantyPeriodUnit,
    );
  }
}
