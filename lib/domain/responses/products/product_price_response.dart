class ProductPriceResponse {
  final ProductPriceMessage message;

  ProductPriceResponse({required this.message});

  factory ProductPriceResponse.fromJson(Map<String, dynamic> json) {
    return ProductPriceResponse(
      message: ProductPriceMessage.fromJson(json['message']),
    );
  }
}

class ProductPriceMessage {
  final String itemCode;
  final String priceList;
  final double price;
  final String currency;
  final String source;

  ProductPriceMessage({
    required this.itemCode,
    required this.priceList,
    required this.price,
    required this.currency,
    required this.source,
  });

  factory ProductPriceMessage.fromJson(Map<String, dynamic> json) {
    return ProductPriceMessage(
      itemCode: json['item_code'] ?? '',
      priceList: json['price_list'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      source: json['source'] ?? '',
    );
  }
}
