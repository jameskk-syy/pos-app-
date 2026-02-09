import 'dart:convert';
import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/requests/products/create_product.dart';
import 'package:pos/domain/responses/industries_list_response.dart';
import 'package:pos/domain/responses/products/create_product_response.dart';
import 'package:pos/domain/responses/products/item_brand.dart';
import 'package:pos/domain/responses/products/item_group.dart';
import 'package:pos/domain/responses/products/item_list.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:pos/domain/responses/products/product_price_response.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/products/seed_products_response.dart';
import 'package:pos/domain/responses/uom_response.dart';
import 'package:pos/domain/requests/products/seed_item.dart';
import 'package:pos/domain/responses/products/seed_items_response.dart';
import 'package:pos/domain/responses/bulk_upload.dart';
import 'package:pos/core/services/storage_service.dart';

class ProductsRemoteDataSource extends BaseRemoteDataSource {
  final StorageService storageService;
  ProductsRemoteDataSource(super.dio, this.storageService);
  String _getErrorMessage(DioException e) {
    //debugPrint("Parsing error response: ${e.response?.data}");
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      var serverMessages = data['_server_messages'];
      if (serverMessages is String) {
        try {
          serverMessages = jsonDecode(serverMessages);
        } catch (_) {}
      }

      if (serverMessages is List && serverMessages.isNotEmpty) {
        String? bestMessage;

        for (var msgEntry in serverMessages) {
          try {
            Map<String, dynamic>? msgMap;
            if (msgEntry is String) {
              final decoded = jsonDecode(msgEntry);
              if (decoded is Map<String, dynamic>) msgMap = decoded;
            } else if (msgEntry is Map<String, dynamic>) {
              msgMap = msgEntry;
            }

            if (msgMap != null && msgMap.containsKey('message')) {
              String msg = msgMap['message'].toString();
              msg = msg.replaceAll(RegExp(r'<[^>]*>'), '');

              bool isStockError =
                  msg.toLowerCase().contains('units of') ||
                  msg.toLowerCase().contains('needed in');

              if (isStockError) {
                if (msg.contains('units of')) {
                  msg = msg.split('units of').last;
                }
                if (msg.contains(':')) {
                  msg = msg.split(':').last;
                }
                return msg.trim();
              }

              if (!msg.contains('CharacterLengthExceededError') &&
                  !msg.contains('Error Log') &&
                  !msg.contains('will get truncated')) {
                bestMessage ??= msg;
              }
            }
          } catch (_) {}
        }
        if (bestMessage != null) return bestMessage.trim();
      }

      final messageObj = data['message'];
      if (messageObj is Map<String, dynamic>) {
        if (messageObj['message'] != null) {
          return _cleanTechnicalError(messageObj['message'].toString());
        }
        if (messageObj['error'] != null) {
          return _cleanTechnicalError(messageObj['error'].toString());
        }
      }

      String fallback =
          (data['exception']?.toString() ??
          data['message']?.toString() ??
          data['error']?.toString() ??
          e.message ??
          'Unknown error occurred');

      return _cleanTechnicalError(fallback);
    }
    return e.message ?? 'Unknown error occurred';
  }

  String _cleanTechnicalError(String error) {
    return error
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'frappe\.exceptions\.\w+:'), '')
        .replaceAll(RegExp(r'Error Log \w+:'), '')
        .replaceAll("'Title'", '')
        .trim();
  }

  Future<void> createUom(String company, String uomName) async {
    //debugPrint(company + uomName);
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.create_uom',
        data: {'company': company, 'uom_name': uomName},
      );

      if (response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      //debugPrint("creating uom  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> updateUom(
    String name,
    String uomName,
    bool mustBeWholeNumber,
  ) async {
    try {
      final response = await dio.put(
        'techsavanna_pos.api.product_api.update_uom',
        data: {
          'name': name,
          'new_uom_name': uomName,
          'must_be_whole_number': mustBeWholeNumber,
        },
      );
      // debugPrint(
      //   "updating uom  ${name + uomName + mustBeWholeNumber.toString()}",
      // );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("updating uom  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      //debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> deleteUom(String company, String uomName) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.delete_uom',
        queryParameters: {'company': company},
        data: {'uom_name': uomName},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("deleting uom  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<UOMResponse> getUom() async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_uoms',
        queryParameters: {
          'company': 'Mainas Web Developmessnt',
        }, // Replicating behavior
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("API Response: ${response.statusCode}");
      // debugPrint("Response Data: ${jsonEncode(data)}");

      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

      await storageService.setString('uomsData', jsonEncode(data));

      return UOMResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint('Unexpected error: $e');
      // debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // --- Brand Methods ---

  Future<void> createBrand(String company, String brandName) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.create_brand',
        data: {'company': company, 'brand_name': brandName},
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("creating brand  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> updateBrand(String oldBrandName, String newBrandName) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.update_brand',
        data: {'brand_name': oldBrandName, 'new_brand_name': newBrandName},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("updating brand  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<BrandResponse> getItemBrands() async {
    // debugPrint('Fetching item brands...');
    try {
      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_brands',
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("Brand API Response: ${response.statusCode}");

      if (data == null) {
        throw Exception('Empty response from server');
      }

      return BrandResponse.fromJson(data);
    } on DioException catch (e) {
      // debugPrint('Dio Error: ${e.type} - ${e.message}');
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  // --- Item Group Methods ---

  Future<void> createItemGroup(
    String company,
    String itemGroupName,
    String? parentItemGroup,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.create_item_group',
        data: {
          'company': company,
          'item_group_name': itemGroupName,
          if (parentItemGroup != null && parentItemGroup.isNotEmpty)
            'parent_item_group': parentItemGroup,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("creating item group  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> updateItemGroup(
    String company,
    String name,
    String itemGroupName,
    String? parentItemGroup,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.update_item_group',
        data: {
          'company': company,
          'name': name,
          'item_group_name': itemGroupName,
          if (parentItemGroup != null && parentItemGroup.isNotEmpty)
            'parent_item_group': parentItemGroup,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("updating item group  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<ItemGroupResponse> getItemGroups() async {
    // debugPrint('Fetching item groups...');
    try {
      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_item_groups',
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'].toString());
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];

      if (message == null) {
        throw Exception('Message field is null');
      }

      if (message is! Map<String, dynamic>) {
        throw Exception(
          'Message field is not a valid object. Type: ${message.runtimeType}',
        );
      }

      if (!message.containsKey('item_groups')) {
        throw Exception('Response missing item_groups field');
      }

      final itemGroups = message['item_groups'];
      if (itemGroups == null) {
        final fixedMessage = {...message, 'item_groups': [], 'count': 0};
        final fixedData = {'message': fixedMessage};
        return ItemGroupResponse.fromJson(fixedData);
      }

      if (itemGroups is! List) {
        throw Exception(
          'Item groups field is not an array. Type: ${itemGroups.runtimeType}',
        );
      }

      if (!message.containsKey('count')) {
        final fixedMessage = {...message, 'count': itemGroups.length};
        final fixedData = {'message': fixedMessage};
        return ItemGroupResponse.fromJson(fixedData);
      }

      return ItemGroupResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint('Unexpected error: $e');
      // debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // --- Price List Methods ---

  Future<PriceListResponse> getPriceLists(String company) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.get_price_lists',
        data: {
          'company': company,
          'filters': {'selling': null, 'buying': null, 'enabled': 'all'},
          'limit': 100,
          'offset': 0,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("getting price lists  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
      return PriceListResponse.fromJson(data['message']);
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> createPriceList({
    required String company,
    required String priceListName,
    required String currency,
    required bool enabled,
    required bool buying,
    required bool selling,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.create_price_list',
        data: {
          'company': company,
          'price_list_name': priceListName,
          'currency': currency,
          'enabled': enabled,
          'buying': buying,
          'selling': selling,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("creating price list  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> updatePriceList({
    required String name,
    required String newPriceListName,
    required String currency,
    required bool enabled,
    required bool buying,
    required bool selling,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.update_price_list',
        data: {
          'name': name,
          'new_price_list_name': newPriceListName,
          'currency': currency,
          'enabled': enabled,
          'buying': buying,
          'selling': selling,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("updating price list  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  // --- Product Management Methods ---

  Future<CreateProductResponse> createProduct(
    CreateProductRequest createProduct,
  ) async {
    // debugPrint("james ${createProduct.itemGroup}");
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.create_product',
        data: createProduct.toJson(),
      );

      // debugPrint(response.data.toString());
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return CreateProductResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> updateProduct(CreateProductRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.update_product',
        data: request.toJson(),
      );
      // debugPrint('Update Product Response Data: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> disableProduct(String itemCode) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.delete_product',
        data: {'item_code': itemCode},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data == null || data['message'] == null) {
        throw Exception('Failed to disable product');
      }

      if (data['message'] is Map<String, dynamic> &&
          data['message']['message'] != null) {
        return data['message']['message'].toString();
      }

      if (data['message'] is String) {
        return data['message'];
      }

      return 'Product disabled successfully';
    } on DioException catch (e) {
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> enableProduct(String itemCode) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.enable_product',
        data: {'item_code': itemCode},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ProductItem> searchProductByBarcode(
    String barcode,
    String posProfile,
  ) async {
    // debugPrint("searching product by barcode: $barcode");
    try {
      final queryParams = {'barcode': barcode, 'pos_profile': posProfile};
      final response = await dio.get(
        'techsavanna_pos.api.items.search_by_barcode',
        queryParameters: queryParams,
      );

      final data = response.data;
      // debugPrint("Barcode search response: $data");

      if (data == null || data['message'] == null) {
        throw Exception('Product not found for barcode: $barcode');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Invalid response format from barcode search');
      }

      return ProductItem.fromJson(message);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found for barcode: $barcode');
      }
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<StockItemResponse> getItemsList(
    String company, {
    int page = 1,
    int pageSize = 20,
  }) async {
    // debugPrint("getting items");
    try {
      final queryParams = {
        'company': company,
        'limit': pageSize.toString(),
        'page': page.toString(),
      };
      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_products',
        queryParameters: queryParams,
      );

      final data = response.data;

      // debugPrint("xbshaxs $data");

      if (data == null || data['message'] == null) {
        // debugPrint("me");
        throw Exception('Invalid response from server');
      }

      // debugPrint(" hwjdfghsacdgwe $data");

      return StockItemResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ProductResponseSimple> getProducts(
    String companyName, {
    String? searchTerm,
    String? itemGroup,
    String? brand,
    String? warehouse,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'search_term': searchTerm,
        'item_group': itemGroup ?? '',
        'brand': brand ?? '',
        'disabled': true,
        "warehouse": warehouse ?? "",
        "is_stock_item": true,
        "is_sales_item": true,
        'company': companyName,
        "price_list": "Standard Selling",
        'page': page,
        'page_size': pageSize,
      };

      final response = await dio.post(
        'techsavanna_pos.api.product_api.get_products',
        data: queryParams,
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("API Responsesss: $data");

      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

      if (!data.containsKey('message')) {
        if (data.containsKey('products')) {
          final wrappedData = {
            'message': {
              ...data,
              'pagination':
                  data['pagination'] ??
                  {
                    'page': 1,
                    'page_size': 20,
                    'total': (data['products'] as List).length,
                    'total_pages': 1,
                  },
            },
          };
          // debugPrint('Wrapped response without message field');

          await storageService.setString(
            'productsData',
            jsonEncode(wrappedData['message']),
          );

          return ProductResponseSimple.fromJson(wrappedData);
        }
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];

      await storageService.setString('productsData', jsonEncode(message));

      if (message == null) {
        throw Exception('Message field is null');
      }

      if (message is! Map<String, dynamic>) {
        if (message is String) {
          try {
            final parsedMessage = jsonDecode(message);
            if (parsedMessage is Map<String, dynamic>) {
              final fixedData = {...data, 'message': parsedMessage};
              return ProductResponseSimple.fromJson(fixedData);
            }
          } catch (e) {
            // debugPrint('Failed to parse message string: $e');
          }
        }
        throw Exception(
          'Message field is not a valid object. Type: ${message.runtimeType}',
        );
      }

      if (!message.containsKey('products')) {
        throw Exception('Response missing products field');
      }

      final products = message['products'];
      if (products == null) {
        final fixedMessage = {...message, 'products': []};
        final fixedData = {...data, 'message': fixedMessage};
        return ProductResponseSimple.fromJson(fixedData);
      }

      if (products is! List) {
        throw Exception(
          'Products field is not an array. Type: ${products.runtimeType}',
        );
      }

      if (!message.containsKey('pagination')) {
        final fixedMessage = {
          ...message,
          'pagination': {
            'page': 1,
            'page_size': 20,
            'total': products.length,
            'total_pages': 1,
          },
        };
        final fixedData = {...data, 'message': fixedMessage};
        return ProductResponseSimple.fromJson(fixedData);
      }

      return ProductResponseSimple.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint('Unexpected error: $e');
      // debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> addBarcode(String itemCode, String barcode) async {
    // debugPrint('Adding barcode for item $itemCode: $barcode');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.add_barcode',
        data: {'item_code': itemCode, 'barcode': barcode},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> setProductPrice({
    required String itemCode,
    required double price,
    required String priceList,
    required String currency,
  }) async {
    // debugPrint(
    //   'Setting price for item $itemCode: $price, $priceList, $currency',
    // );
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.set_product_price',
        data: {
          'item_code': itemCode,
          'price': price,
          'price_list': priceList,
          'currency': currency,
        },
      );

      // debugPrint('Set Product Price Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> setProductWarranty({
    required String company,
    required String itemCode,
    required int warrantyPeriod,
    required String warrantyPeriodUnit,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.set_product_warranty',
        data: {
          'company': company,
          'item_code': itemCode,
          'warranty_period': warrantyPeriod,
          'warranty_period_unit': warrantyPeriodUnit,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("setting product warranty  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<ProductPriceResponse> getProductPrice({
    required String itemCode,
    required String company,
    String? priceList,
  }) async {
    try {
      final queryParams = {'item_code': itemCode, 'company': company};
      if (priceList != null) {
        queryParams['price_list'] = priceList;
      }
      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_product_price',
        queryParameters: queryParams,
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("getting product price ${response.data}");

      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      return ProductPriceResponse.fromJson(data);
    } on DioException catch (e) {
      // debugPrint(e.response?.data?.toString());
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      // debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  // --- Seeding Methods ---

  Future<PharmacyProductsResponse> getSeedProducts(String industry) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_seeding.seed_products',
        data: {'industry': industry},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint(" james ${response.toString()}");

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      await storageService.setString('productsData', jsonEncode(message));
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      if (message['products'] is! List) {
        throw Exception('Products field is not an array');
      }

      return PharmacyProductsResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        throw Exception(_getErrorMessage(e));
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<IndustriesResponse> getIndustriesList() async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_seeding.get_pos_industries?is_active=true',
      );

      final data = response.data;

      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      if (data['message'] is! Map<String, dynamic>) {
        throw Exception('Unexpected response structure');
      }

      return IndustriesResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ProcessResponse> seedProducts(String industry) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_seeding.bulk_upload_products',
        data: {'industry': industry},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint(" james ${response.toString()}");

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      await storageService.setString('productsData', jsonEncode(message));
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      await getSeedProducts(industry);

      return ProcessResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        throw Exception(_getErrorMessage(e));
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateOrderResponse> seedItems(CreateOrderRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_seeding.create_seed_item',
        data: request.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }
      return CreateOrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }
}
