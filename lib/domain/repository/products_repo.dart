import 'package:pos/domain/requests/products/create_product.dart';
import 'package:pos/domain/requests/inventory/stock_request.dart';
import 'package:pos/domain/responses/products/create_product_response.dart';
import 'package:pos/domain/responses/products/item_brand.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:pos/domain/responses/products/item_group.dart';
import 'package:pos/domain/responses/products/item_list.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/inventory/stock_reco.dart';
import 'package:pos/domain/responses/uom_response.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/models/pos_opening_entry_model.dart';
import 'package:pos/domain/responses/products/product_price_response.dart';

abstract class ProductsRepo {
  Future<ProductResponseSimple> getAllProducts(
    String company, {
    String? searchTerm,
    String? itemGroup,
    String? brand,
    String? warehouse,
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
  Future<String> disableProduct(String itemCode);
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
  Future<ProductPriceResponse> getProductPrice({
    required String itemCode,
    required String company,
    String? priceList,
  });
  Future<ProductItem> searchProductByBarcode({
    required String barcode,
    required String posProfile,
  });

  Future<InvoiceListResponse> listSalesInvoices({
    required String company,
    int limit = 20,
    int offset = 0,
    String? customer,
    String? fromDate,
    String? toDate,
    String? status,
  });

  Future<InvoiceListResponse> listPosInvoices({
    required String company,
    int limit = 20,
    int offset = 0,
    String? customer,
    String? fromDate,
    String? toDate,
    String? status,
  });

  Future<PosOpeningEntryResponse> listPosOpeningEntries({
    required String company,
    int limit = 20,
    int offset = 0,
  });

  Future<ClosePosOpeningEntryResponse> closePosOpeningEntry({
    required String posOpeningEntry,
    bool doNotSubmit = false,
  });
}
