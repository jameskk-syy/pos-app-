class CreateProductRequest {
  final String itemCode;
  final String itemName;
  final String itemGroup;
  final String stockUom;
  final double standardRate;
  final String description;
  final bool isStockItem;
  final bool isSalesItem;
  final bool isPurchaseItem;
  final String brand;
  final String barcode;
  final String etimsCountryOfOriginCode;
  final String productType;
  final String packagingUnitCode;
  final String unitOfQuantityCode;
  final String itemClassification;
  final String taxationType;
  final String company;

  CreateProductRequest({
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.stockUom,
    required this.standardRate,
    required this.description,
    required this.isStockItem,
    required this.isSalesItem,
    required this.isPurchaseItem,
    required this.brand,
    required this.barcode,
    required this.etimsCountryOfOriginCode,
    required this.productType,
    required this.packagingUnitCode,
    required this.unitOfQuantityCode,
    required this.itemClassification,
    required this.taxationType,
    required this.company,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'item_name': itemName,
      'item_group': itemGroup,
      'stock_uom': stockUom,
      'standard_rate': standardRate,
      'description': description,
      'is_stock_item': isStockItem,
      'is_sales_item': isSalesItem,
      'is_purchase_item': isPurchaseItem,
      'brand': brand,
      'barcode': barcode,
      'etims_country_of_origin_code': etimsCountryOfOriginCode,
      'product_type': productType,
      'packaging_unit_code': packagingUnitCode,
      'unit_of_quantity_code': unitOfQuantityCode,
      'item_classification': itemClassification,
      'taxation_type': taxationType,
      'company': company,
    };
  }
}