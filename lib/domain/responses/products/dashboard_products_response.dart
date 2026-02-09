
class DashboardProductsResponse {
  final DashboardProductsMessage message;

  DashboardProductsResponse({required this.message});

  factory DashboardProductsResponse.fromJson(Map<String, dynamic> json) {
    return DashboardProductsResponse(
      message: DashboardProductsMessage.fromJson(json['message'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class DashboardProductsMessage {
  final List<DashboardProductItem> products;
  final DashboardPagination pagination;
  final String? priceList;
  final String? warehouse;

  DashboardProductsMessage({
    required this.products,
    required this.pagination,
    this.priceList,
    this.warehouse,
  });

  factory DashboardProductsMessage.fromJson(Map<String, dynamic> json) {
    var list = json['products'] as List? ?? [];
    List<DashboardProductItem> productsList = list
        .map((i) => DashboardProductItem.fromJson(i))
        .toList();

    return DashboardProductsMessage(
      products: productsList,
      pagination: DashboardPagination.fromJson(json['pagination'] ?? {}),
      priceList: json['price_list']?.toString(),
      warehouse: json['warehouse']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
      'price_list': priceList,
      'warehouse': warehouse,
    };
  }
}

class DashboardProductItem {
  final String name;
  final String itemCode;
  final String itemName;
  final String itemGroup;
  final String stockUom;
  final double standardRate;
  final int isStockItem;
  final int isSalesItem;
  final int isPurchaseItem;
  final int disabled;
  final String? brand;
  final String? image;
  final int? warrantyPeriod;
  final double price;
  final String priceCurrency;
  final String priceList;
  final String priceSource;
  final double stockQty;
  final double? buyingPrice;
  final double? sellingPrice;
  final String? warrantyPeriodUnit;

  DashboardProductItem({
    required this.name,
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.stockUom,
    required this.standardRate,
    required this.isStockItem,
    required this.isSalesItem,
    required this.isPurchaseItem,
    required this.disabled,
    this.brand,
    this.image,
    this.warrantyPeriod,
    required this.price,
    required this.priceCurrency,
    required this.priceList,
    required this.priceSource,
    required this.stockQty,
    this.buyingPrice,
    this.sellingPrice,
    this.warrantyPeriodUnit,
  });

  factory DashboardProductItem.fromJson(Map<String, dynamic> json) {
    return DashboardProductItem(
      name: json['name']?.toString() ?? '',
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      itemGroup: json['item_group']?.toString() ?? '',
      stockUom: json['stock_uom']?.toString() ?? '',
      standardRate: (json['standard_rate'] ?? 0.0).toDouble(),
      isStockItem: (json['is_stock_item'] ?? 0).toInt(),
      isSalesItem: (json['is_sales_item'] ?? 0).toInt(),
      isPurchaseItem: (json['is_purchase_item'] ?? 0).toInt(),
      disabled: (json['disabled'] ?? 0).toInt(),
      brand: json['brand']?.toString(),
      image: json['image']?.toString(),
      warrantyPeriod: (json['warranty_period'] ?? 0).toInt(),
      price: (json['price'] ?? 0.0).toDouble(),
      priceCurrency: json['price_currency']?.toString() ?? 'KES',
      priceList: json['price_list']?.toString() ?? '',
      priceSource: json['price_source']?.toString() ?? '',
      stockQty: (json['stock_qty'] ?? 0.0).toDouble(),
      buyingPrice: json['buying_price']?.toDouble(),
      sellingPrice: json['selling_price']?.toDouble(),
      warrantyPeriodUnit: json['warranty_period_unit']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'item_code': itemCode,
      'item_name': itemName,
      'item_group': itemGroup,
      'stock_uom': stockUom,
      'standard_rate': standardRate,
      'is_stock_item': isStockItem,
      'is_sales_item': isSalesItem,
      'is_purchase_item': isPurchaseItem,
      'disabled': disabled,
      'brand': brand,
      'image': image,
      'warranty_period': warrantyPeriod,
      'price': price,
      'price_currency': priceCurrency,
      'price_list': priceList,
      'price_source': priceSource,
      'stock_qty': stockQty,
      'buying_price': buyingPrice,
      'selling_price': sellingPrice,
      'warranty_period_unit': warrantyPeriodUnit,
    };
  }

  bool get isActive => disabled == 0;
}

class DashboardPagination {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  DashboardPagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory DashboardPagination.fromJson(Map<String, dynamic> json) {
    return DashboardPagination(
      page: (json['page'] ?? 1).toInt(),
      pageSize: (json['page_size'] ?? 20).toInt(),
      total: (json['total'] ?? 0).toInt(),
      totalPages: (json['total_pages'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'total': total,
      'total_pages': totalPages,
    };
  }
}
