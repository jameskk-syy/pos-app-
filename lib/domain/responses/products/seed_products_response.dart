class PharmacyProductsResponse {
  final PharmacyMessage? message;

  PharmacyProductsResponse({this.message});

  factory PharmacyProductsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PharmacyProductsResponse();
    }

    return PharmacyProductsResponse(
      message: json['message'] != null
          ? PharmacyMessage.fromJson(json['message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (message != null) 'message': message!.toJson()};
  }
}

class PharmacyMessage {
  final String? status;
  final String? industry;
  final int? totalProducts;
  final List<PharmacyProduct>? products;

  PharmacyMessage({
    this.status,
    this.industry,
    this.totalProducts,
    this.products,
  });

  factory PharmacyMessage.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PharmacyMessage();
    }

    return PharmacyMessage(
      status: json['status']?.toString(),
      industry: json['industry']?.toString(),
      totalProducts: _parseToInt(json['total_products']),
      products: json['products'] != null
          ? List<PharmacyProduct>.from(
              (json['products'] as List).map(
                (x) => PharmacyProduct.fromJson(x as Map<String, dynamic>?),
              ),
            )
          : null,
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      final doubleParsed = double.tryParse(value);
      if (doubleParsed != null) return doubleParsed.toInt();
    }
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (status != null) 'status': status,
      if (industry != null) 'industry': industry,
      if (totalProducts != null) 'total_products': totalProducts,
      if (products != null)
        'products': products!.map((x) => x.toJson()).toList(),
    };
  }
}

class PharmacyProduct {
  final String? sku;
  final String? name;
  final String? status;
  final double? itemPrice;
  final double? buyingPrice;
  final int? qty;
  final String? itemGroup;
  final String? uom;

  PharmacyProduct({
    this.sku,
    this.name,
    this.status,
    this.itemPrice,
    this.buyingPrice,
    this.qty,
    this.itemGroup,
    this.uom,
  });

  factory PharmacyProduct.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PharmacyProduct();
    }

    return PharmacyProduct(
      sku: json['sku']?.toString(),
      name: json['name']?.toString(),
      status: json['status']?.toString(),
      itemPrice: PharmacyMessage._parseToDouble(json['item_price']),
      buyingPrice: PharmacyMessage._parseToDouble(json['buying_price']),
      qty: PharmacyMessage._parseToInt(json['qty']),
      itemGroup: json['item_group']?.toString(),
      uom: json['uom']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (itemPrice != null) 'item_price': itemPrice,
      if (buyingPrice != null) 'buying_price': buyingPrice,
      if (qty != null) 'qty': qty,
      if (itemGroup != null) 'item_group': itemGroup,
      if (uom != null) 'uom': uom,
    };
  }

  @override
  String toString() {
    return 'PharmacyProduct(sku: $sku, name: $name, status: $status, itemPrice: $itemPrice, buyingPrice: $buyingPrice, qty: $qty, itemGroup: $itemGroup, uom: $uom)';
  }
}
