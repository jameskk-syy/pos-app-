class StockItemResponse {
  final bool success;
  final List<StockItem> data;
  final int count;
  final String priceList; // Added based on JSON

  StockItemResponse({
    required this.success,
    required this.data,
    required this.count,
    required this.priceList,
  });

  factory StockItemResponse.fromJson(Map<String, dynamic> json) {
    // Check if we have the message wrapper
    Map<String, dynamic> messageData;
    if (json.containsKey('message')) {
      messageData = json['message'];
    } else {
      messageData = json;
    }

    // Get products list - note it's called 'products' in JSON, not 'data'
    List<dynamic> productsList = messageData['products'] ?? [];
    
    return StockItemResponse(
      success: json['success'] ?? true, // Assuming success if not present
      data: productsList
          .map((item) => StockItem.fromJson(item))
          .toList(),
      count: messageData['pagination']?['total'] ?? 0,
      priceList: messageData['price_list'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': {
        'products': data.map((item) => item.toJson()).toList(),
        'pagination': {
          'total': count,
        },
        'price_list': priceList,
      }
    };
  }
}

class StockItem {
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

  StockItem({
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
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      name: json['name'] ?? '',
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      itemGroup: json['item_group'] ?? '',
      stockUom: json['stock_uom'] ?? '',
      standardRate: (json['standard_rate'] ?? 0).toDouble(),
      isStockItem: json['is_stock_item'] ?? 0,
      isSalesItem: json['is_sales_item'] ?? 0,
      isPurchaseItem: json['is_purchase_item'] ?? 0,
      disabled: json['disabled'] ?? 0,
      brand: json['brand'],
      image: json['image'],
      price: (json['price'] ?? 0).toDouble(),
      priceCurrency: json['price_currency'] ?? '',
      priceList: json['price_list'] ?? '',
      priceSource: json['price_source'] ?? '',
      stockQty: (json['stock_qty'] ?? 0).toDouble(),
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
    };
  }
}