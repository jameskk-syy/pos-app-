import 'package:equatable/equatable.dart';
import 'dart:convert';

class ProductResponse {
  final List<ProductItem> products;
  final PaginationInfo pagination;
  final String priceList;
  final String warehouse;

  ProductResponse({
    required this.products,
    required this.pagination,
    required this.priceList,
    required this.warehouse,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    // Check if there's a nested "message" object
    final messageData = (json['message'] ?? json) as Map<String, dynamic>;

    final productsData = messageData['products'] as List? ?? [];
    final productsList = productsData
        .map((item) => ProductItem.fromJson(item as Map<String, dynamic>))
        .toList();

    // Handle pagination - cast to Map<String, dynamic>
    final dynamic paginationRaw = messageData['pagination'];
    Map<String, dynamic> paginationJson = {};

    if (paginationRaw is Map) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      paginationJson = Map<String, dynamic>.from(paginationRaw);
    }

    final pagination = PaginationInfo.fromJson(paginationJson);

    return ProductResponse(
      products: productsList,
      pagination: pagination,
      priceList:
          (messageData['price_list'] ?? json['price_list'] ?? '') as String,
      warehouse: (messageData['warehouse'] ?? '') as String,
    );
  }

  factory ProductResponse.parse(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return ProductResponse.fromJson(jsonMap);
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'products': products.map((product) => product.toJson()).toList(),
        'pagination': pagination.toJson(),
        'price_list': priceList,
        'warehouse': warehouse,
      },
      'price_list': priceList,
      'warehouse': warehouse,
    };
  }

  // Helper methods...
  List<ProductItem> get availableProducts =>
      products.where((p) => p.isActive && p.stockQty > 0).toList();

  List<ProductItem> get salesProducts =>
      products.where((p) => p.isActive && p.isSalesItem == 1).toList();

  List<ProductItem> search(String query) {
    final lowerQuery = query.toLowerCase();
    return products
        .where(
          (product) =>
              product.itemName.toLowerCase().contains(lowerQuery) ||
              product.itemCode.toLowerCase().contains(lowerQuery) ||
              product.name.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  ProductItem? getProductByCode(String itemCode) {
    try {
      return products.firstWhere((product) => product.itemCode == itemCode);
    } catch (e) {
      return null;
    }
  }
}

class ProductItem extends Equatable {
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
  final double price;
  final String priceCurrency;
  final String priceList;
  final String priceSource;
  final double stockQty;
  final int? warrantyPeriod;
  final String? warrantyPeriodUnit;
  final double? buyingPrice;
  final double? sellingPrice;

  const ProductItem({
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
    required this.price,
    required this.priceCurrency,
    required this.priceList,
    required this.priceSource,
    required this.stockQty,
    this.warrantyPeriod,
    this.warrantyPeriodUnit,
    this.buyingPrice,
    this.sellingPrice,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      name: json['name']?.toString() ?? '',
      itemCode:
          (json['item_code'] ?? json['itemCode'] ?? json['item_name'] ?? '')
              .toString(),
      itemName:
          (json['item_name'] ?? json['itemName'] ?? json['item_code'] ?? '')
              .toString(),
      itemGroup: (json['item_group'] ?? json['itemGroup'] ?? 'Consumable')
          .toString(),
      stockUom: (json['stock_uom'] ?? json['stockUom'] ?? 'NOS').toString(),
      standardRate: (json['standard_rate'] ?? json['standardRate'] ?? 0.0)
          .toDouble(),
      isStockItem: (json['is_stock_item'] ?? json['isStockItem'] ?? 0).toInt(),
      isSalesItem: (json['is_sales_item'] ?? json['isSalesItem'] ?? 0).toInt(),
      isPurchaseItem: (json['is_purchase_item'] ?? json['isPurchaseItem'] ?? 0)
          .toInt(),
      disabled: (json['disabled'] ?? 0).toInt(),
      brand: json['brand']?.toString(),
      image: json['image']?.toString(),
      price:
          (json['price'] ??
                  json['selling_price'] ??
                  json['price_list_rate'] ??
                  0.0)
              .toDouble(),
      priceCurrency: (json['price_currency'] ?? json['priceCurrency'] ?? 'KES')
          .toString(),
      priceList: (json['price_list'] ?? json['priceList'] ?? '').toString(),
      priceSource: (json['price_source'] ?? json['priceSource'] ?? '')
          .toString(),
      stockQty: (json['stock_qty'] ?? json['stockQty'] ?? 0.0).toDouble(),
      warrantyPeriod: (json['warranty_period'] ?? 0).toInt(),
      warrantyPeriodUnit:
          (json['warranty_period_unit'] ?? json['warrantyPeriodUnit'])
              ?.toString(),
      buyingPrice: (json['buying_price'] ?? json['buyingPrice'])?.toDouble(),
      sellingPrice: (json['selling_price'] ?? json['sellingPrice'])?.toDouble(),
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
      'price': price,
      'price_currency': priceCurrency,
      'price_list': priceList,
      'price_source': priceSource,
      'stock_qty': stockQty,
      'warranty_period': warrantyPeriod,
      'warranty_period_unit': warrantyPeriodUnit,
      'buying_price': buyingPrice,
      'selling_price': sellingPrice,
    };
  }

  // Helper properties
  bool get isActive => disabled == 0;
  bool get canBeSold => isActive && isSalesItem == 1;
  bool get canBePurchased => isActive && isPurchaseItem == 1;
  bool get isInStock => stockQty > 0;
  bool get hasImage => image != null && image!.isNotEmpty;

  String get displayName => itemName.isNotEmpty ? itemName : name;

  String get status {
    if (!isActive) return 'Disabled';
    if (stockQty <= 0) return 'Out of Stock';
    return 'Available';
  }

  String get formattedPrice => '$price $priceCurrency';
  String get formattedStandardRate =>
      '${standardRate.toStringAsFixed(2)} $priceCurrency';

  double get effectivePrice {
    if (price > 0) return price;
    if (sellingPrice != null && sellingPrice! > 0) return sellingPrice!;
    return standardRate;
  }

  double get basicRate => buyingPrice ?? standardRate;

  ProductItem copyWith({
    String? name,
    String? itemCode,
    String? itemName,
    String? itemGroup,
    String? stockUom,
    double? standardRate,
    int? isStockItem,
    int? isSalesItem,
    int? isPurchaseItem,
    int? disabled,
    String? brand,
    String? image,
    double? price,
    String? priceCurrency,
    String? priceList,
    String? priceSource,
    double? stockQty,
    int? warrantyPeriod,
    String? warrantyPeriodUnit,
    double? buyingPrice,
    double? sellingPrice,
  }) {
    return ProductItem(
      name: name ?? this.name,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      itemGroup: itemGroup ?? this.itemGroup,
      stockUom: stockUom ?? this.stockUom,
      standardRate: standardRate ?? this.standardRate,
      isStockItem: isStockItem ?? this.isStockItem,
      isSalesItem: isSalesItem ?? this.isSalesItem,
      isPurchaseItem: isPurchaseItem ?? this.isPurchaseItem,
      disabled: disabled ?? this.disabled,
      brand: brand ?? this.brand,
      image: image ?? this.image,
      price: price ?? this.price,
      priceCurrency: priceCurrency ?? this.priceCurrency,
      priceList: priceList ?? this.priceList,
      priceSource: priceSource ?? this.priceSource,
      stockQty: stockQty ?? this.stockQty,
      warrantyPeriod: warrantyPeriod ?? this.warrantyPeriod,
      warrantyPeriodUnit: warrantyPeriodUnit ?? this.warrantyPeriodUnit,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }

  @override
  List<Object?> get props => [itemCode];
}

class PaginationInfo {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
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

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  int get fromItem => ((page - 1) * pageSize) + 1;
  int get toItem => page * pageSize > total ? total : page * pageSize;
  String get pageInfo => 'Showing $fromItem to $toItem of $total items';
}

class ProductResponseSimple {
  final List<ProductItem> products;
  final PaginationInfo pagination;
  final String priceList;
  final String warehouse;

  ProductResponseSimple({
    required this.products,
    required this.pagination,
    required this.priceList,
    required this.warehouse,
  });

  factory ProductResponseSimple.fromJson(dynamic json) {
    // Handle both String and Map input
    Map<String, dynamic> jsonMap;

    if (json is String) {
      jsonMap = jsonDecode(json);
    } else if (json is Map) {
      jsonMap = Map<String, dynamic>.from(json);
    } else {
      throw FormatException('Invalid JSON format');
    }

    final messageData = (jsonMap['message'] ?? jsonMap) as Map;
    final messageMap = Map<String, dynamic>.from(messageData);

    final productsData = messageMap['products'] as List? ?? [];
    final productsList = productsData
        .map((item) => ProductItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final paginationData = messageMap['pagination'] ?? {};
    final paginationMap = Map<String, dynamic>.from(paginationData);
    final pagination = PaginationInfo.fromJson(paginationMap);

    return ProductResponseSimple(
      products: productsList,
      pagination: pagination,
      priceList:
          (messageMap['price_list'] ??
                  jsonMap['price_list'] ??
                  messageMap['priceList'] ??
                  jsonMap['priceList'] ??
                  '')
              .toString(),
      warehouse:
          (messageMap['warehouse'] ??
                  jsonMap['warehouse'] ??
                  messageMap['warehouse_name'] ??
                  '')
              .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'products': products.map((product) => product.toJson()).toList(),
        'pagination': pagination.toJson(),
        'price_list': priceList,
        'warehouse': warehouse,
      },
      'price_list': priceList,
      'warehouse': warehouse,
    };
  }

  ProductItem? getProductByCode(String itemCode) {
    try {
      return products.firstWhere((product) => product.itemCode == itemCode);
    } catch (e) {
      return null;
    }
  }
}
