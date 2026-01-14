import 'package:pos/domain/requests/create_product.dart';
import 'package:pos/domain/requests/stock_request.dart';
import 'package:pos/domain/responses/create_product_response.dart';
import 'package:pos/domain/responses/item_brand.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:pos/domain/responses/item_group.dart';
import 'package:pos/domain/responses/item_list.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/domain/responses/stock_reco.dart';
import 'package:pos/domain/responses/uom_response.dart';

abstract class ProductsRepo {
  Future<ProductResponseSimple> getAllProducts(
    String company, {
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  });
  // Future<ProductResponseSimple> getItemType();
  // Future<ProductResponseSimple> getItemBrand();
  Future<UOMResponse> getUnitOfmeasure();
  Future<ItemGroupResponse> getItemGroup();
  Future<void> createItemGroup(
    String company,
    String itemGroupName,
    String? parentItemGroup,
  );
  Future<void> updateItemGroup(
    String company,
    String name,
    String itemGroupName,
    String? parentItemGroup,
  );
  Future<BrandResponse> getBrand();
  Future<PriceListResponse> getPriceLists(String company);
  Future<void> createPriceList({
    required String company,
    required String priceListName,
    required String currency,
    required bool enabled,
    required bool buying,
    required bool selling,
  });
  Future<void> updatePriceList({
    required String name,
    required String newPriceListName,
    required String currency,
    required bool enabled,
    required bool buying,
    required bool selling,
  });
  Future<void> createBrand(String company, String brandName);
  Future<void> updateBrand(String oldBrandName, String newBrandName);
  Future<void> createUom(String company, String uomName);
  Future<void> updateUom(String name, String uomName, bool mustBeWholeNumber);
  Future<void> deleteUom(String company, String uomName);
  Future<CreateProductResponse> createProduct(
    CreateProductRequest createProductRequest,
  );

  Future<StockItemResponse> getProductItems(
    String company, {
    int page = 1,
    int pageSize = 20,
  });
  Future<StockResponse> addItemToStock(StockRequest stockRequest);
  Future<void> addBarcode(String itemCode, String barcode);
  Future<void> updateProduct(CreateProductRequest request);
  Future<void> disableProduct(String itemCode);
  Future<void> enableProduct(String itemCode);
  Future<void> setProductPrice({
    required String itemCode,
    required double price,
    required String priceList,
    required String currency,
  });
  Future<void> setProductWarranty({
    required String company,
    required String itemCode,
    required int warrantyPeriod,
    required String warrantyPeriodUnit,
  });
}
