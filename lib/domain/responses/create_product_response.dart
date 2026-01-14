import 'dart:convert';

// Main response class
class CreateProductResponse {
  final MessageWrapper message;

  CreateProductResponse({
    required this.message,
  });

  factory CreateProductResponse.fromJson(Map<String, dynamic> json) {
    return CreateProductResponse(
      message: MessageWrapper.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

// Wrapper for the message field
class MessageWrapper {
  final Product product;
  final String message;

  MessageWrapper({
    required this.product,
    required this.message,
  });

  factory MessageWrapper.fromJson(Map<String, dynamic> json) {
    return MessageWrapper(
      product: Product.fromJson(json['product']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'message': message,
    };
  }
}

// Product model
class Product {
  final String itemCode;
  final String itemName;
  final String itemGroup;
  final String stockUom;
  final double standardRate;
  final int isStockItem;
  final int isSalesItem;
  final int isPurchaseItem;
  final int disabled;

  Product({
    required this.itemCode,
    required this.itemName,
    required this.itemGroup,
    required this.stockUom,
    required this.standardRate,
    required this.isStockItem,
    required this.isSalesItem,
    required this.isPurchaseItem,
    required this.disabled,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      itemCode: json['item_code'] ?? '',
      itemName: json['item_name'] ?? '',
      itemGroup: json['item_group'] ?? '',
      stockUom: json['stock_uom'] ?? '',
      standardRate: (json['standard_rate'] as num?)?.toDouble() ?? 0.0,
      isStockItem: json['is_stock_item'] ?? 0,
      isSalesItem: json['is_sales_item'] ?? 0,
      isPurchaseItem: json['is_purchase_item'] ?? 0,
      disabled: json['disabled'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'item_name': itemName,
      'item_group': itemGroup,
      'stock_uom': stockUom,
      'standard_rate': standardRate,
      'is_stock_item': isStockItem,
      'is_sales_item': isSalesItem,
      'is_purchase_item': isPurchaseItem,
      'disabled': disabled,
    };
  }
}