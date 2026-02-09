import 'package:flutter/foundation.dart';

class BrandResponse {
  final List<Brand> brands;

  BrandResponse({required this.brands});

  factory BrandResponse.fromJson(dynamic json) {
    debugPrint("BrandResponse.fromJson - raw json type: ${json?.runtimeType}");
    debugPrint("BrandResponse.fromJson - raw json: $json");

    List<Brand> brandList = [];

    // Case 1: API returns a List directly [ "Brand1", "Brand2" ] or [ {"name": "B1"}, ... ]
    if (json is List) {
      for (var item in json) {
        if (item is Map) {
          brandList.add(Brand.fromJson(Map<String, dynamic>.from(item)));
        } else if (item is String) {
          brandList.add(Brand(name: item, brandName: item));
        }
      }
    }
    // Case 2: API returns a Map with "message" wrapper or "brands" key
    else if (json is Map) {
      final jsonMap = Map<String, dynamic>.from(json);
      final message = jsonMap['message'];

      if (message is List) {
        for (var item in message) {
          if (item is Map) {
            brandList.add(Brand.fromJson(Map<String, dynamic>.from(item)));
          } else if (item is String) {
            brandList.add(Brand(name: item, brandName: item));
          }
        }
      } else if (message is Map) {
        final messageMap = Map<String, dynamic>.from(message);
        if (messageMap.containsKey('brands') && messageMap['brands'] is List) {
          for (var item in (messageMap['brands'] as List)) {
            if (item is Map) {
              brandList.add(Brand.fromJson(Map<String, dynamic>.from(item)));
            } else if (item is String) {
              brandList.add(Brand(name: item, brandName: item));
            }
          }
        } else {
          // It's a map of brand names to brand objects
          messageMap.forEach((key, value) {
            if (value is Map) {
              final valueMap = Map<String, dynamic>.from(value);
              brandList.add(
                Brand.fromJson({...valueMap, 'name': valueMap['name'] ?? key}),
              );
            } else {
              brandList.add(Brand(name: key, brandName: key));
            }
          });
        }
      } else if (jsonMap.containsKey('brands') && jsonMap['brands'] is List) {
        // Direct brands key in root
        for (var item in (jsonMap['brands'] as List)) {
          if (item is Map) {
            brandList.add(Brand.fromJson(Map<String, dynamic>.from(item)));
          } else if (item is String) {
            brandList.add(Brand(name: item, brandName: item));
          }
        }
      }
    }

    return BrandResponse(brands: brandList);
  }
}

class Brand {
  final String name;
  final String brandName;

  Brand({required this.name, required this.brandName});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      name: json['name']?.toString() ?? '',
      brandName:
          json['brand']?.toString() ??
          json['brand_name']?.toString() ??
          json['name']?.toString() ??
          '',
    );
  }
}
