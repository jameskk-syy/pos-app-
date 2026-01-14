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
    return {
      if (message != null) 'message': message!.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      if (status != null) 'status': status,
      if (industry != null) 'industry': industry,
      if (totalProducts != null) 'total_products': totalProducts,
      if (products != null) 'products': products!.map((x) => x.toJson()).toList(),
    };
  }
}

class PharmacyProduct {
  final String? sku;
  final String? name;
  final String? status;

  PharmacyProduct({
    this.sku,
    this.name,
    this.status,
  });

  factory PharmacyProduct.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PharmacyProduct();
    }
    
    return PharmacyProduct(
      sku: json['sku']?.toString(),
      name: json['name']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
    };
  }

  @override
  String toString() {
    return 'PharmacyProduct(sku: $sku, name: $name, status: $status)';
  }
}