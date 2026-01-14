import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/invoice_model_get.dart';
import 'package:pos/domain/models/message.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/models/pos_session_model.dart';
import 'package:pos/domain/models/stock_ledger_entry.dart';
import 'package:pos/domain/requests/add_stock_take_request.dart';
import 'package:pos/domain/requests/approve_stock_transfer_request.dart';
import 'package:pos/domain/requests/assign_loyalty_program_request.dart';
import 'package:pos/domain/requests/assign_staff_to_store.dart';
import 'package:pos/domain/requests/create_customer.dart';
import 'package:pos/domain/requests/create_discount_rule_request.dart';
import 'package:pos/domain/requests/create_grn_request.dart';
import 'package:pos/domain/requests/create_loyalty_program_request.dart';
import 'package:pos/domain/requests/create_material_issue_request.dart';
import 'package:pos/domain/requests/create_material_receipt_request.dart';
import 'package:pos/domain/requests/create_pos_request.dart';
import 'package:pos/domain/requests/create_product.dart';
import 'package:pos/domain/requests/create_provisioning_account.dart';
import 'package:pos/domain/requests/create_purchase_order_request.dart';
import 'package:pos/domain/requests/create_role_request.dart';
import 'package:pos/domain/requests/role_permissions_request.dart';
import 'package:pos/domain/requests/assign_permissions_request.dart';
import 'package:pos/domain/requests/create_staff.dart';
import 'package:pos/domain/requests/create_stock_reconciliation_request.dart';
import 'package:pos/domain/requests/create_stock_transfer_request.dart';
import 'package:pos/domain/requests/create_supplier_group_request.dart';
import 'package:pos/domain/requests/create_supplier_request.dart';
import 'package:pos/domain/requests/update_supplier_request.dart';
import 'package:pos/domain/requests/create_transfer_request.dart';
import 'package:pos/domain/requests/create_warehouse.dart';
import 'package:pos/domain/requests/customer_credit.dart';
import 'package:pos/domain/requests/dashboard_request.dart';
import 'package:pos/domain/requests/dispatch_stock_transfer_request.dart';
import 'package:pos/domain/requests/get_customer_request.dart';
import 'package:pos/domain/requests/get_inventory_discount_rules_request.dart';
import 'package:pos/domain/requests/get_loyalty_programs_request.dart';
import 'package:pos/domain/requests/get_material_requests_request.dart';
import 'package:pos/domain/requests/get_stock_reconciliation_request.dart';
import 'package:pos/domain/requests/get_stock_reconciliations_request.dart';
import 'package:pos/domain/requests/login.dart';
import 'package:pos/domain/requests/loyalty_history_models.dart';
import 'package:pos/domain/requests/receive_stock_request.dart';
import 'package:pos/domain/requests/register_company.dart';
import 'package:pos/domain/requests/register_user.dart';
import 'package:pos/domain/requests/seed_item.dart';
import 'package:pos/domain/requests/stock_entries_request.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:pos/domain/responses/system_responses.dart';
import 'package:pos/domain/requests/stock_entry.dart';
import 'package:pos/domain/requests/stock_request.dart';
import 'package:pos/domain/requests/submit_purchase_order_request.dart';
import 'package:pos/domain/requests/submit_stock_transfer_request.dart';
import 'package:pos/domain/requests/update_customer_request.dart';
import 'package:pos/domain/requests/update_staff_roles.dart';
import 'package:pos/domain/requests/update_staff_user_request.dart';
import 'package:pos/domain/requests/update_warehouse.dart';
import 'package:pos/domain/responses/add_stock_take_response.dart';
import 'package:pos/domain/responses/approve_stock_transfer_response.dart';
import 'package:pos/domain/responses/assign_loyalty_program_response.dart';
import 'package:pos/domain/responses/assign_roles_response.dart';
import 'package:pos/domain/responses/assign_staff_to_store_response.dart';
import 'package:pos/domain/responses/bulk_upload.dart';
import 'package:pos/domain/responses/create_customer.dart';
import 'package:pos/domain/responses/create_discount_rule_response.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/aging_stock_model.dart';
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/domain/responses/create_grn_response.dart';
import 'package:pos/domain/responses/create_loyalty_program_response.dart';
import 'package:pos/domain/responses/create_material_issue_response.dart';
import 'package:pos/domain/responses/create_material_receipt_response.dart';
import 'package:pos/domain/responses/create_product_response.dart';
import 'package:pos/domain/responses/create_provisioning_account.dart';
import 'package:pos/domain/responses/create_purchase_order_response.dart';
import 'package:pos/domain/responses/create_role_response.dart';
import 'package:pos/domain/responses/create_stock_reconciliation_response.dart';
import 'package:pos/domain/responses/create_stock_transfer_response.dart';
import 'package:pos/domain/responses/create_supplier_group_response.dart';
import 'package:pos/domain/responses/create_supplier_response.dart';
import 'package:pos/domain/responses/create_transfer_response.dart';
import 'package:pos/domain/responses/create_warehouse.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/domain/responses/customer_credit.dart';
import 'package:pos/domain/responses/dashboard_response.dart';
import 'package:pos/domain/responses/dispatch_stock_transfer_response.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/get_inventory_discount_rules_response.dart';
import 'package:pos/domain/responses/get_loyalty_programs_response.dart';
import 'package:pos/domain/responses/get_stock_reconciliation_response.dart';
import 'package:pos/domain/responses/get_stock_transfer_response.dart';
import 'package:pos/domain/responses/industries_list_response.dart';
import 'package:pos/domain/responses/item_brand.dart';
import 'package:pos/domain/responses/item_group.dart';
import 'package:pos/domain/responses/item_list.dart';
import 'package:pos/domain/responses/login_response.dart';
import 'package:pos/domain/responses/low_alert_response.dart';
import 'package:pos/domain/responses/loyalty_response.dart';
import 'package:pos/domain/responses/material_requests_response.dart';
import 'package:pos/domain/responses/pos_create_response.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/domain/responses/purchase_order_detail_response.dart';
import 'package:pos/domain/responses/purchase_order_response.dart';
import 'package:pos/domain/responses/receive_stock_response.dart';
import 'package:pos/domain/responses/register_company_response.dart';
import 'package:pos/domain/responses/role_permissions_response.dart';
import 'package:pos/domain/responses/assign_permissions_response.dart';
import 'package:pos/domain/responses/get_role_details_response.dart';
import 'package:pos/domain/responses/role_response.dart';
import 'package:pos/domain/responses/roles.dart';
import 'package:pos/domain/responses/seed_items_response.dart';
import 'package:pos/domain/responses/seed_products_response.dart';
import 'package:pos/domain/responses/stock_entries_response.dart';
import 'package:pos/domain/responses/stock_entry_response.dart';
import 'package:pos/domain/responses/stock_reco.dart';
import 'package:pos/domain/responses/stock_reconciliations_response.dart';
import 'package:pos/domain/responses/stock_summary_response.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/domain/responses/submit_purchase_order_response.dart';
import 'package:pos/domain/responses/submit_stock_transfer_response.dart';
import 'package:pos/domain/responses/supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers_response.dart';
import 'package:pos/domain/responses/uom_response.dart';
import 'package:pos/domain/responses/update_customer_response.dart';
import 'package:pos/domain/responses/update_staff_user_response.dart';
import 'package:pos/domain/responses/update_warehouse_response.dart';
import 'package:pos/domain/responses/users_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteDataSource {
  final Dio dio;
  RemoteDataSource(this.dio);

  Future<void> createUom(String company, String uomName) async {
    debugPrint(company + uomName);

    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.create_uom',
        data: {'company': company, 'uom_name': uomName},
      );

      if (response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("creating uom  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> updateUom(
    String name,
    String uomName,
    bool mustBeWholeNumber,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.update_uom',
        data: {
          'name': name,
          'uom_name': uomName,
          'must_be_whole_number': mustBeWholeNumber,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("updating uom  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint("deleting uom  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

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
      debugPrint("creating brand  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint("updating brand  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

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
      debugPrint("creating item group  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint("updating item group  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

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
      debugPrint("getting price lists  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
      return PriceListResponse.fromJson(data['message']);
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint("creating price list  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint("updating price list  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint("setting product warranty  ${response.data}");
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      debugPrint(e.response?.data?.toString());
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> saveMessageToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    String messageJson = jsonEncode(data['message']);
    await prefs.setString('saved_message', messageJson);
  }

  Future<Message?> getMessageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? messageJson = prefs.getString('saved_message');

    if (messageJson != null) {
      Map<String, dynamic> messageMap = jsonDecode(messageJson);
      return Message.fromJson(messageMap);
    }
    return null;
  }

  Future<void> deleteMessageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_message');
  }

  Future<Message> registerUser(RegisterRequest registerRequest) async {
    try {
      debugPrint('REGISTER PAYLOAD => ${registerRequest.toJson()}');

      final response = await dio.post(
        'techsavanna_pos.api.auth_api.register_user',
        data: registerRequest.toJson(),
      );

      final data = response.data;

      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      debugPrint('REGISTER RESPONSE => $data');

      final prefs = await SharedPreferences.getInstance();

      // message object
      final message = data['message'];

      // Save full message (user + metadata) if you want
      String userDataJson = jsonEncode(message);
      await prefs.setString('userData', userDataJson);

      // Save ONLY the access token
      await prefs.setString('access_token', message['access_token']);
      await prefs.setString('refresh_token', message['refresh_token']);
      // CompanyRequest companyRequest = CompanyRequest(
      //   companyName: registerRequest.businessName,
      //   abbr: _generateAbbr(registerRequest.businessName),
      //   country: "Kenya",
      //   defaultCurrency: "KES",
      //   companyAddress: CompanyAddress(
      //     addressLine1: "Nairobi",
      //     addressLine2: "",
      //     city: "Nairobi",
      //     state: "",
      //     country: "",
      //     pincode: "",
      //     phone: "",
      //     emailId: registerRequest.email,
      //   ),
      //   companyContact: CompanyContact(
      //     firstName: registerRequest.firstName,
      //     lastName: registerRequest.lastName,
      //     email: registerRequest.email,
      //   ),
      // );
      // await registerCompany(companyRequest);

      debugPrint('USER DATA SAVED TO PREFERENCES $userDataJson');
      debugPrint('ACCESS TOKEN SAVED: ${message['access_token']}');

      return Message.fromJson(message);
    } on DioException catch (e) {
      debugPrint('DIO ERROR');
      debugPrint('STATUS CODE => ${e.response?.statusCode}');
      debugPrint('ERROR DATA => ${e.response?.data}');

      if (e.response?.data != null) {
        final data = e.response!.data;

        if (data['message'] != null && data['message']['error'] != null) {
          throw Exception(data['message']['error']);
        }
      }

      throw Exception(e.message);
    } catch (e) {
      debugPrint('GENERAL ERROR => $e');
      throw Exception(e.toString());
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    debugPrint("DEBUG: Login attempt for ${request.email}");
    final requestBody = {
      'identifier': request.email,
      'password': request.password,
    };
    try {
      debugPrint("DEBUG: Posting to loginuser endpoint...");
      final response = await dio.post(
        'techsavanna_pos.api.auth_api.loginuser',
        data: requestBody,
      );

      final data = response.data;
      debugPrint("DEBUG: Login status code: ${response.data}");

      if (data == null || data['message'] == null) {
        debugPrint("DEBUG: Login failed - Invalid response structure");
        throw Exception('Invalid response from server');
      }

      final messageMap = data['message'];
      if (messageMap is! Map<String, dynamic>) {
        debugPrint("DEBUG: Login failed - message is not a Map");
        throw Exception('Unexpected response structure: message is not a Map');
      }

      final loginResponse = LoginResponse.fromJson({'message': messageMap});

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'userData',
        jsonEncode(loginResponse.message.user.toJson()),
      );
      await prefs.setString('access_token', loginResponse.message.accessToken);

      debugPrint("DEBUG: Login successful, calling getCurrentUser...");
      await getCurrentUser();
      debugPrint(
        'DEBUG: USER DATA SAVED: ${loginResponse.message.user.toJson()}',
      );
      debugPrint(
        'DEBUG: ACCESS TOKEN SAVED: ${loginResponse.message.accessToken}',
      );

      return loginResponse;
    } on DioException catch (e) {
      debugPrint("DEBUG: DioException during login: ${e.message}");
      debugPrint("DEBUG: Response data: ${e.response?.data}");
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final exception = data['exception'] ?? data['message'];
        throw Exception(exception?.toString() ?? e.message);
      }
      throw Exception(e.message ?? 'Server error: ${e.response?.statusCode}');
    } catch (e) {
      debugPrint("DEBUG: General error during login: $e");
      throw Exception(e.toString());
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
      debugPrint(" james ${response.toString()}");

      // Validate response structure
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('productsData', jsonEncode(message));
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      await getSeedProducts(industry);
      await getCurrentUser();
      // Validate required fields in message
      return ProcessResponse.fromJson(data);
    } on DioException catch (e) {
      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        // Try to parse error response
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow; // Or handle as needed
    }
  }

  Future<CreateRoleResponse> createRole(CreateRoleRequest request) async {
    debugPrint("maina");
    try {
      final formData = FormData.fromMap(request.toJson());
      final response = await dio.post(
        'techsavanna_pos.api.role_api.create_role',
        data: formData,
      );
      debugPrint(response.toString());
      if (response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      return CreateRoleResponse.fromJson(data);
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
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          debugPrint(e.response.toString());
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateRoleResponse> updateRole(CreateRoleRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());
      final response = await dio.post(
        'techsavanna_pos.api.role_api.update_role',
        data: formData,
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      return CreateRoleResponse.fromJson(data);
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
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RolePermissionsResponse> getRolePermissions(
    RolePermissionsRequest request,
  ) async {
    try {
      final formData = FormData.fromMap(request.toJson());
      final response = await dio.post(
        'techsavanna_pos.api.role_api.get_role_permissions',
        data: formData,
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      return RolePermissionsResponse.fromJson(data);
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
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CompanyProfileResponse> createPosProfile(
    CompanyProfileRequest request,
  ) async {
    debugPrint("Creating POS Profile...");
    try {
      final response = await dio.post(
        'techsavanna_pos.api.onboarding_api.create_pos_profile',
        data: request,
      );

      debugPrint("Response: ${response.toString()}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      await getCurrentUser();
      return CompanyProfileResponse.fromJson(data);
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
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          debugPrint(e.response.toString());
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignWarehousesResponse> assignStaffToWarehouse(
    AssignWarehousesRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.warehouse_api.assign_warehouses_to_staff',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      debugPrint("Assign Staff Response: $data");

      // Validate response structure
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }
      return AssignWarehousesResponse.fromJson(data);
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
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

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
      debugPrint(" james ${response.toString()}");

      // Validate response structure
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('productsData', jsonEncode(message));
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }
      // Validate products array
      if (message['products'] is! List) {
        throw Exception('Products field is not an array');
      }

      return PharmacyProductsResponse.fromJson(data);
    } on DioException catch (e) {
      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        // Try to parse error response
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow; // Or handle as needed
    }
  }

  Future<StockResponses> getLowStockAlert(
    String? warehouse,
    double? threshold,
    String? company,
  ) async {
    debugPrint("calling  me");
    try {
      final response = await dio.get(
        'techsavanna_pos.api.inventory_api.get_low_stock_items',
        queryParameters: {
          'warehouse': warehouse,
          "threshold": threshold,
          "limit": 1000,
          "company": company,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint(" james ${response.toString()}");

      // Validate response structure
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }
      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return StockResponses.fromJson(message);
    } on DioException catch (e) {
      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        // Try to parse error response
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          debugPrint(e.toString());
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow; // Or handle as needed
    }
  }

  Future<POSSessionResponse> createPOSSession(POSSessionRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.sales_api.create_pos_opening_entry',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Create POS Session API Response: ${response.statusCode}");
      debugPrint("Response Data: ${jsonEncode(data)}");

      // Validate response structure
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Response type: ${data.runtimeType}');
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      // Check if there's an error in response
      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

      // Check the response structure
      if (!data.containsKey('message') || data['message'] is! Map) {
        throw Exception('Invalid response structure: missing "message" field');
      }

      final message = data['message'];

      if (message['success'] != true) {
        throw Exception(
          message['message']?.toString() ?? 'Failed to create POS session',
        );
      }

      final Map<String, dynamic>? sessionData = message['data'];
      if (sessionData == null) {
        throw Exception('No session data found');
      }

      // Parse the session response
      final session = POSSessionResponse.fromJson(sessionData);

      // Save to shared preferences if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_session', jsonEncode(sessionData));

      return session;
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.type} - ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status Code: ${e.response?.statusCode}');

      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your connection and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled.');
      } else if (e.type == DioExceptionType.badResponse) {
        // Server responded with error status
        if (e.response != null) {
          debugPrint('Error Response: ${e.response?.data}');
          debugPrint('Status Code: ${e.response?.statusCode}');

          // Try to parse error response
          try {
            final errorData = e.response!.data;
            String errorMessage = 'Server error ${e.response!.statusCode}';

            if (errorData is Map) {
              errorMessage =
                  errorData['error']?.toString() ??
                  errorData['message']?.toString() ??
                  errorData['exception']?.toString() ??
                  errorData['detail']?.toString() ??
                  errorMessage;
            } else if (errorData is String) {
              errorMessage = errorData;
            }

            throw Exception(errorMessage);
          } catch (_) {
            throw Exception('Server error: ${e.response!.statusCode}');
          }
        } else {
          throw Exception('Server error: No response received');
        }
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException ||
            e.message?.contains('SocketException') == true ||
            e.message?.contains('Failed host lookup') == true) {
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        }
        throw Exception('Unknown error: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> disableProduct(String itemCode) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.delete_product',
        data: {'item_code': itemCode},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data == null ||
          data['message'] == null ||
          data['message']['message'] != 'Product disabled successfully') {
        throw Exception('Failed to disable product');
      }
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

  Future<GetSalesInvoiceResponse> getSalesInvoice({
    required String invoiceName,
  }) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.sales_api.get_sales_invoice',
        queryParameters: {'name': invoiceName},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Get Sales Invoice API Response: ${response.statusCode}");
      debugPrint("Response Data: ${jsonEncode(data)}");

      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      // Check if there's an error in response
      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

      return GetSalesInvoiceResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.type} - ${e.message}');
      debugPrint('Response: ${e.response?.data}');

      if (e.response != null) {
        throw Exception('Server error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<CreateInvoiceResponse> createInvoice(InvoiceRequest request) async {
    try {
      debugPrint('Creating invoice with data: ${jsonEncode(request.toJson())}');

      final response = await dio.post(
        'techsavanna_pos.api.sales_api.create_pos_invoice',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Create Invoice API Response: ${response.statusCode}");
      debugPrint("Response Data: ${jsonEncode(data)}");

      // Validate response structure
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Response type: ${data.runtimeType}');
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }
      final invoiceResponse = CreateInvoiceResponse.fromJson(data);

      if (!invoiceResponse.success) {
        throw Exception(invoiceResponse.message);
      }

      return invoiceResponse;
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.type} - ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status Code: ${e.response?.statusCode}');

      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your connection and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled.');
      } else if (e.type == DioExceptionType.badResponse) {
        // Server responded with error status
        if (e.response != null) {
          debugPrint('Error Response: ${e.response?.data}');
          debugPrint('Status Code: ${e.response?.statusCode}');

          // Try to parse error response
          try {
            final errorData = e.response!.data;
            String errorMessage = 'Server error ${e.response!.statusCode}';

            if (errorData is Map) {
              errorMessage =
                  errorData['error']?.toString() ??
                  errorData['message']?.toString() ??
                  errorData['exception']?.toString() ??
                  errorData['detail']?.toString() ??
                  errorMessage;
            } else if (errorData is String) {
              errorMessage = errorData;
            }

            throw Exception(errorMessage);
          } catch (_) {
            throw Exception('Server error: ${e.response!.statusCode}');
          }
        } else {
          throw Exception('Server error: No response received');
        }
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException ||
            e.message?.contains('SocketException') == true ||
            e.message?.contains('Failed host lookup') == true) {
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        }
        throw Exception('Unknown error: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods({
    required String company,
    bool onlyEnabled = true,
  }) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.sales_api.list_payment_methods',
        queryParameters: {'only_enabled': onlyEnabled, 'company': company},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Payment Methods API Response: ${response.statusCode}");
      debugPrint("Response Data: ${jsonEncode(data)}");

      // Validate response structure
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Response type: ${data.runtimeType}');
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      // Check if there's an error in response
      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

      // Check the response structure
      if (!data.containsKey('message') || data['message'] is! Map) {
        throw Exception('Invalid response structure: missing "message" field');
      }

      final message = data['message'];

      if (message['success'] != true) {
        throw Exception(message['message']?.toString() ?? 'API call failed');
      }

      final List<dynamic>? methodsData = message['data'];
      if (methodsData == null) {
        throw Exception('No payment methods data found');
      }

      // Parse payment methods
      final paymentMethods = methodsData.map((item) {
        if (item is! Map<String, dynamic>) {
          throw Exception('Invalid payment method data structure');
        }
        return PaymentMethod.fromJson(item);
      }).toList();

      // Save to shared preferences if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('payment_methods_data', jsonEncode(data));

      return paymentMethods;
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.type} - ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status Code: ${e.response?.statusCode}');

      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your connection and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled.');
      } else if (e.type == DioExceptionType.badResponse) {
        // Server responded with error status
        if (e.response != null) {
          debugPrint('Error Response: ${e.response?.data}');
          debugPrint('Status Code: ${e.response?.statusCode}');

          // Try to parse error response
          try {
            final errorData = e.response!.data;
            String errorMessage = 'Server error ${e.response!.statusCode}';

            if (errorData is Map) {
              errorMessage =
                  errorData['error']?.toString() ??
                  errorData['message']?.toString() ??
                  errorData['exception']?.toString() ??
                  errorData['detail']?.toString() ??
                  errorMessage;
            } else if (errorData is String) {
              errorMessage = errorData;
            }

            throw Exception(errorMessage);
          } catch (_) {
            throw Exception('Server error: ${e.response!.statusCode}');
          }
        } else {
          throw Exception('Server error: No response received');
        }
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException ||
            e.message?.contains('SocketException') == true ||
            e.message?.contains('Failed host lookup') == true) {
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        }
        throw Exception('Unknown error: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<GetLoyaltyProgramsResponse> getLoyaltyPrograms(
    GetLoyaltyProgramsRequest request,
  ) async {
    debugPrint('Fetching loyalty programs...');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.loyalty.list_loyalty_programs',
        queryParameters: request.toQueryParams(),
      );

      debugPrint(response.toString());

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return GetLoyaltyProgramsResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to fetch loyalty programs: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch loyalty programs: $e');
    }
  }

  Future<CreateLoyaltyProgramResponse> createLoyaltyProgram(
    CreateLoyaltyProgramRequest request,
  ) async {
    debugPrint('Creating loyalty program...');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.loyalty.create_loyalty_program',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return CreateLoyaltyProgramResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to create loyalty program: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to create loyalty program: $e');
    }
  }

  Future<CreateDiscountRuleResponse> createDiscountRule(
    CreateDiscountRuleRequest request,
  ) async {
    debugPrint('Creating inventory discount rule...');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_inventory_discount_rule',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return CreateDiscountRuleResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to create discount rule: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to create discount rule: $e');
    }
  }

  Future<ItemGroupResponse> getItemGroups() async {
    debugPrint('Fetching item groups...');
    try {
      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_item_groups',
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("API Response: ${response.statusCode}");
      debugPrint("Response Data: ${jsonEncode(data)}");

      // Validate response structure
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Response type: ${data.runtimeType}');
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      // Check if there's an error in response
      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];

      // Validate message structure
      if (message == null) {
        throw Exception('Message field is null');
      }

      if (message is! Map<String, dynamic>) {
        debugPrint('Message type: ${message.runtimeType}');
        throw Exception(
          'Message field is not a valid object. Type: ${message.runtimeType}',
        );
      }

      // Validate item_groups array
      if (!message.containsKey('item_groups')) {
        throw Exception('Response missing item_groups field');
      }

      final itemGroups = message['item_groups'];
      if (itemGroups == null) {
        // Item groups field exists but is null - treat as empty array
        final fixedMessage = {...message, 'item_groups': [], 'count': 0};
        final fixedData = {'message': fixedMessage};
        return ItemGroupResponse.fromJson(fixedData);
      }

      if (itemGroups is! List) {
        throw Exception(
          'Item groups field is not an array. Type: ${itemGroups.runtimeType}',
        );
      }

      // Ensure count exists
      if (!message.containsKey('count')) {
        final fixedMessage = {...message, 'count': itemGroups.length};
        final fixedData = {'message': fixedMessage};
        return ItemGroupResponse.fromJson(fixedData);
      }

      return ItemGroupResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.type} - ${e.message}');

      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your connection and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled.');
      } else if (e.type == DioExceptionType.badResponse) {
        // Server responded with error status
        if (e.response != null) {
          debugPrint('Error Response: ${e.response?.data}');
          debugPrint('Status Code: ${e.response?.statusCode}');

          // Try to parse error response
          try {
            final errorData = e.response!.data;
            String errorMessage = 'Server error ${e.response!.statusCode}';

            if (errorData is Map) {
              errorMessage =
                  errorData['error']?.toString() ??
                  errorData['message']?.toString() ??
                  errorData['exception']?.toString() ??
                  errorData['detail']?.toString() ??
                  errorMessage;
            } else if (errorData is String) {
              errorMessage = errorData;
            }

            throw Exception(errorMessage);
          } catch (_) {
            throw Exception('Server error: ${e.response!.statusCode}');
          }
        } else {
          throw Exception('Server error: No response received');
        }
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException ||
            e.message?.contains('SocketException') == true) {
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        }
        throw Exception('Unknown error: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<StockSummaryResponse> getStockSummary({
    required String company,
    int? limit,
    int? offset,
    String? warehouse,
    String? itemGroup,
    String? search,
  }) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.inventory_api.get_stock_summary',
        queryParameters: {
          'company': company,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
          if (warehouse != null && warehouse.isNotEmpty) 'warehouse': warehouse,
          if (itemGroup != null && itemGroup.isNotEmpty)
            'item_group': itemGroup,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Stock Summary Response: ${response.toString()}");

      // Validate response structure
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      return StockSummaryResponse.fromJson(data);
    } on DioException catch (e) {
      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        // Try to parse error response
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          debugPrint(e.toString());
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<SalesAnalyticsResponse> getSalesAnalyticsReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching sales analytics report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.sales_analytics_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Sales Analytics Response: ${response.toString()}");

      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') &&
            data['message'] is Map<String, dynamic>) {
          return SalesAnalyticsResponse.fromJson(data['message']);
        }
        return SalesAnalyticsResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch sales report: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryValueByCategoryResponse> getInventoryValueByCategoryReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching inventory value report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.inventory_value_by_category_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') &&
            data['message'] is Map<String, dynamic>) {
          return InventoryValueByCategoryResponse.fromJson(data['message']);
        }
        return InventoryValueByCategoryResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch inventory report: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryTurnoverResponse> getInventoryTurnoverReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching inventory turnover report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.inventory_turnover_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') &&
            data['message'] is Map<String, dynamic>) {
          return InventoryTurnoverResponse.fromJson(data['message']);
        }
        return InventoryTurnoverResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch turnover report: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryDaysOnHandResponse> getInventoryDaysOnHandReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching days on hand report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.inventory_days_on_hand_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return InventoryDaysOnHandResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch days on hand report: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryAccuracyResponse> getInventoryAccuracyReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching inventory accuracy report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.inventory_accuracy_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Inventory Accuracy Response: ${response.toString()}");
      if (data is Map<String, dynamic>) {
        return InventoryAccuracyResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch accuracy report: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryVarianceResponse> getInventoryVarianceReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching variance report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.inventory_variance_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Inventory Variance Response: ${response.toString()}");
      if (data is Map<String, dynamic>) {
        return InventoryVarianceResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch variance report: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryAdjustmentTrendsResponse> getInventoryAdjustmentTrendsReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching adjustment trends report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.inventory_adjustment_trends_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return InventoryAdjustmentTrendsResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch trends report: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<AgingStockSummaryResponse> getAgingStockSummaryReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching aging summary report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.aging_stock_summary_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AgingStockSummaryResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch aging summary: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<AgingStockDetailsResponse> getAgingStockDetailsReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching aging details report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.aging_stock_details_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AgingStockDetailsResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch aging details: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryExpiryResponse> getInventoryExpiryReport(
    ReportRequest request,
  ) async {
    debugPrint('Fetching expiry report...');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.reports.inventory_expiry_report',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return InventoryExpiryResponse.fromJson(data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Report Fetch Error: $e');
      throw Exception('Failed to fetch expiry report: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductResponseSimple> getProducts(
    String companyName, {
    String? searchTerm,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'search_term': searchTerm,
        'item_group': '',
        'brand': '',
        'disabled': false,
        'company': companyName,
        'page': page,
        'page_size': pageSize,
      };

      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_products',
        queryParameters: queryParams,
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("API Response: ${response.statusCode}");

      // Validate response structure
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Response type: ${data.runtimeType}');
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
          debugPrint('Wrapped response without message field');

          // Save to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'productsData',
            jsonEncode(wrappedData['message']),
          );

          return ProductResponseSimple.fromJson(wrappedData);
        }
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('productsData', jsonEncode(message));

      // Validate message structure
      if (message == null) {
        throw Exception('Message field is null');
      }

      if (message is! Map<String, dynamic>) {
        debugPrint('Message type: ${message.runtimeType}');

        // Try to handle if message is a string
        if (message is String) {
          try {
            final parsedMessage = jsonDecode(message);
            if (parsedMessage is Map<String, dynamic>) {
              final fixedData = {
                'message': parsedMessage,
                'price_list': data['price_list'] ?? 'Standard Selling',
              };
              return ProductResponseSimple.fromJson(fixedData);
            }
          } catch (e) {
            debugPrint('Failed to parse message string: $e');
          }
        }
        throw Exception(
          'Message field is not a valid object. Type: ${message.runtimeType}',
        );
      }

      // Validate products array
      if (!message.containsKey('products')) {
        throw Exception('Response missing products field');
      }

      final products = message['products'];
      if (products == null) {
        // Products field exists but is null - treat as empty array
        final fixedMessage = {...message, 'products': []};
        final fixedData = {...data, 'message': fixedMessage};
        return ProductResponseSimple.fromJson(fixedData);
      }

      if (products is! List) {
        throw Exception(
          'Products field is not an array. Type: ${products.runtimeType}',
        );
      }

      // Ensure pagination exists
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
      debugPrint('Dio Error: ${e.type} - ${e.message}');

      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your connection and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled.');
      } else if (e.type == DioExceptionType.badResponse) {
        // Server responded with error status
        if (e.response != null) {
          debugPrint('Error Response: ${e.response?.data}');
          debugPrint('Status Code: ${e.response?.statusCode}');

          // Try to parse error response
          try {
            final errorData = e.response!.data;
            String errorMessage = 'Server error ${e.response!.statusCode}';

            if (errorData is Map) {
              errorMessage =
                  errorData['error']?.toString() ??
                  errorData['message']?.toString() ??
                  errorData['exception']?.toString() ??
                  errorData['detail']?.toString() ??
                  errorMessage;
            } else if (errorData is String) {
              errorMessage = errorData;
            }

            throw Exception(errorMessage);
          } catch (_) {
            throw Exception('Server error: ${e.response!.statusCode}');
          }
        } else {
          throw Exception('Server error: No response received');
        }
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException ||
            e.message?.contains('SocketException') == true) {
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        }
        throw Exception('Unknown error: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<DashboardResponse> getDashboardData(DashboardRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.dashboard_api.get_dashboard_metrics',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("API Response: ${response.statusCode}");
      debugPrint("Response Data: ${jsonEncode(data)}");

      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Response type: ${data.runtimeType}');
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      // FIX: Check if response is wrapped in "message" key
      Map<String, dynamic> actualData = data;
      if (data.containsKey('message') &&
          data['message'] is Map<String, dynamic>) {
        debugPrint('Response wrapped in "message" key, unwrapping...');
        actualData = data['message'] as Map<String, dynamic>;
      }

      // Now check for errors in the actual data
      if (actualData.containsKey('error')) {
        final error = actualData['error'];
        throw Exception(error.toString());
      }

      if (!actualData.containsKey('success')) {
        throw Exception('Response missing required field: success');
      }

      if (actualData['success'] != true) {
        final errorMsg =
            actualData['message'] ?? actualData['error'] ?? 'Request failed';
        throw Exception(errorMsg.toString());
      }

      if (!actualData.containsKey('data')) {
        throw Exception('Response missing required field: data');
      }

      final dashboardData = actualData['data'];
      if (dashboardData == null) {
        throw Exception('Dashboard data field is null');
      }

      if (dashboardData is! Map<String, dynamic>) {
        debugPrint('Data type: ${dashboardData.runtimeType}');
        throw Exception(
          'Data field is not a valid object. Type: ${dashboardData.runtimeType}',
        );
      }

      // Save the actual data (not the wrapper)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dashboardData', jsonEncode(actualData));
      debugPrint('Dashboard data saved to local storage');
      await getCurrentUser();

      // Parse the actual data
      return DashboardResponse.fromJson(actualData);
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.type} - ${e.message}');

      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your connection and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled.');
      } else if (e.type == DioExceptionType.badResponse) {
        // Server responded with error status
        if (e.response != null) {
          debugPrint('Error Response: ${e.response?.data}');
          debugPrint('Status Code: ${e.response?.statusCode}');

          // Try to parse error response
          try {
            final errorData = e.response!.data;
            String errorMessage = 'Server error ${e.response!.statusCode}';

            if (errorData is Map) {
              errorMessage =
                  errorData['error']?.toString() ??
                  errorData['message']?.toString() ??
                  errorData['exception']?.toString() ??
                  errorData['detail']?.toString() ??
                  errorMessage;
            } else if (errorData is String) {
              errorMessage = errorData;
            }

            throw Exception(errorMessage);
          } catch (_) {
            throw Exception('Server error: ${e.response!.statusCode}');
          }
        } else {
          throw Exception('Server error: No response received');
        }
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException ||
            e.message?.contains('SocketException') == true) {
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        }
        throw Exception('Unknown error: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<UOMResponse> getUom() async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_uoms?company=Mainas+Web+Developmessnt',
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("API Response: ${response.statusCode}");
      debugPrint("Response Data: ${jsonEncode(data)}");

      // Validate response structure
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('Response type: ${data.runtimeType}');
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      // Check if there's an error in response
      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

      // Save to shared preferences if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uomsData', jsonEncode(data));

      // Parse the response using UOMResponse.fromJson
      return UOMResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.type} - ${e.message}');

      // Handle different Dio error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your connection and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled.');
      } else if (e.type == DioExceptionType.badResponse) {
        // Server responded with error status
        if (e.response != null) {
          debugPrint('Error Response: ${e.response?.data}');
          debugPrint('Status Code: ${e.response?.statusCode}');

          // Try to parse error response
          try {
            final errorData = e.response!.data;
            String errorMessage = 'Server error ${e.response!.statusCode}';

            if (errorData is Map) {
              errorMessage =
                  errorData['error']?.toString() ??
                  errorData['message']?.toString() ??
                  errorData['exception']?.toString() ??
                  errorData['detail']?.toString() ??
                  errorMessage;
            } else if (errorData is String) {
              errorMessage = errorData;
            }

            throw Exception(errorMessage);
          } catch (_) {
            throw Exception('Server error: ${e.response!.statusCode}');
          }
        } else {
          throw Exception('Server error: No response received');
        }
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException ||
            e.message?.contains('SocketException') == true) {
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        }
        throw Exception('Unknown error: ${e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<CreateOrderResponse> seedItems(CreateOrderRequest createOrder) async {
    debugPrint("james ${createOrder.toJson().toString()}");
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_seeding.create_seed_item',
        data: createOrder.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Invalid message format');
      }

      final status = message['status'];

      if (status == 'failed') {
        final failedItems = message['failed'] as List<dynamic>;

        final errors = failedItems.map((e) => e['item_code']).join(', ');

        throw Exception('Item seeding failed. Duplicate items: $errors');
      }

      return CreateOrderResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint(e.toString());
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;
        throw Exception(err['message'] ?? 'Server error');
      }
      throw Exception(e.message);
    }
  }

  Future<CreateProductResponse> createProduct(
    CreateProductRequest createProduct,
  ) async {
    debugPrint(createProduct.itemGroup);
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.create_product',
        data: createProduct.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      // Check if there's an error in the response
      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      // Parse the successful response based on your earlier structure
      return CreateProductResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        // Check for different error response structures
        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            final failedItems = message['failed'] as List<dynamic>? ?? [];
            final errors = failedItems
                .map((e) => e['item_code']?.toString() ?? 'Unknown')
                .join(', ');
            throw Exception('Item seeding failed. Duplicate items: $errors');
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<CustomerResponse> getAllCustomers(CustomerRequest request) async {
    debugPrint('Fetching all customers... ${request.company}');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.customer_api.list_customers',
        queryParameters: request.toJson(),
      );
      debugPrint(response.toString());
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

      return CustomerResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to fetch customers: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  Future<CreateSupplierGroupResponse> createSupplierGroup(
    CreateSupplierGroupRequest request,
  ) async {
    debugPrint('Creating supplier group: ${request.supplierGroupName}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.supplier_api.create_supplier_group',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return CreateSupplierGroupResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to create supplier group: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to create supplier group: $e');
    }
  }

  Future<SuppliersResponse> getSuppliers({
    String? searchTerm,
    String? supplierGroup,
    required String company,
    required int limit,
    required int offset,
    String? supplierType,
    String? country,
    bool? disabled,
  }) async {
    debugPrint('Fetching suppliers with parameters:');
    debugPrint('searchTerm: $searchTerm');
    debugPrint('supplierGroup: $supplierGroup');
    debugPrint('company: $company');
    debugPrint('limit: $limit');
    debugPrint('offset: $offset');
    debugPrint('supplierType: $supplierType');
    debugPrint('country: $country');
    debugPrint('disabled: $disabled');

    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {
        'search_term': searchTerm ?? '',
        'supplier_group': supplierGroup ?? '',
        'company': company,
        'limit': limit,
        'offset': offset,
      };

      // Add optional parameters if they have values
      if (supplierType != null && supplierType != "All") {
        queryParams['supplier_type'] = supplierType;
      }

      if (country != null && country != "All") {
        queryParams['country'] = country;
      }

      if (disabled != null) {
        queryParams['disabled'] = disabled ? 1 : 0;
      }

      final response = await dio.get(
        'techsavanna_pos.api.supplier_api.get_suppliers',
        queryParameters: queryParams,
      );

      debugPrint('Suppliers response: ${jsonEncode(response.data)}');

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
      if (data.containsKey('message')) {
        return SuppliersResponse.fromJson(data['message']);
      }

      return SuppliersResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Dio error fetching suppliers: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your internet connection.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('_server_messages')) {
          try {
            final serverMessages = jsonDecode(err['_server_messages']);
            if (serverMessages is List && serverMessages.isNotEmpty) {
              final message = jsonDecode(serverMessages.first);
              throw Exception(message['message'] ?? 'Server error');
            }
          } catch (parseError) {
            // If parsing fails, fall back to raw message
          }
        }

        if (err.containsKey('exc_type') &&
            err['exc_type'] == 'ValidationError') {
          throw Exception(
            'Validation error: ${err['exception'] ?? 'Invalid data'}',
          );
        }

        throw Exception(
          err['error'] ?? err['message'] ?? 'Server error occurred',
        );
      }

      throw Exception(
        e.message ?? 'Unknown error occurred while fetching suppliers',
      );
    } catch (e) {
      debugPrint('Error fetching suppliers: $e');
      throw Exception('Failed to fetch suppliers: ${e.toString()}');
    }
  }

  Future<CreatePurchaseOrderResponse> createPurchaseOrder({
    required CreatePurchaseOrderRequest request,
  }) async {
    debugPrint(
      'Creating purchase order with data: ${jsonEncode(request.toJson())}',
    );

    try {
      final response = await dio.post(
        'techsavanna_pos.api.purchase.create_purchase_order',
        data: request.toJson(),
      );

      debugPrint('Purchase order response: ${jsonEncode(response.data)}');

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

      return CreatePurchaseOrderResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Dio error creating purchase order: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Request timeout. Please check your internet connection.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('_server_messages')) {
          try {
            final serverMessages = jsonDecode(err['_server_messages']);
            if (serverMessages is List && serverMessages.isNotEmpty) {
              final message = jsonDecode(serverMessages.first);
              throw Exception(message['message'] ?? 'Server error');
            }
          } catch (parseError) {
            // If parsing fails, fall back to raw message
          }
        }

        if (err.containsKey('exc_type') &&
            err['exc_type'] == 'ValidationError') {
          throw Exception(
            'Validation error: ${err['exception'] ?? 'Invalid data'}',
          );
        }

        throw Exception(
          err['error'] ?? err['message'] ?? 'Server error occurred',
        );
      }

      throw Exception(
        e.message ?? 'Unknown error occurred while creating purchase order',
      );
    } catch (e) {
      debugPrint('Error creating purchase order: $e');
      throw Exception('Failed to create purchase order: ${e.toString()}');
    }
  }

  Future<RoleResponse> getAllRole({
    int page = 1,
    int size = 20,
    String? search,
  }) async {
    debugPrint('Fetching role with page: $page, size: $size, search: $search');

    try {
      final Map<String, dynamic> queryParams = {"page": page, "size": size};
      if (search != null && search.isNotEmpty) {
        queryParams["search"] = search;
      }
      final response = await dio.get(
        'techsavanna_pos.api.role_api.list_roles',
        queryParameters: queryParams,
      );
      debugPrint(response.toString());

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

      return RoleResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to fetch role: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch role: $e');
    }
  }

  Future<ModuleResponse> getModules() async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.system_api.list_modules',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return ModuleResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;
        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch modules: $e');
    }
  }

  Future<DoctypeResponse> getDoctypes(String module) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.system_api.list_doctypes',
        queryParameters: {'module': module, 'page': 1, 'page_size': 20},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return DoctypeResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;
        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch doctypes: $e');
    }
  }

  Future<AssignPermissionsResponse> assignPermissions(
    AssignPermissionsRequest request,
  ) async {
    try {
      final formData = FormData.fromMap(request.toJson());
      final response = await dio.post(
        'techsavanna_pos.api.role_api.assign_permissions_to_role',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return AssignPermissionsResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;
        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to assign permissions: $e');
    }
  }

  Future<GetRoleDetailsResponse> getRoleDetails(String roleName) async {
    debugPrint('Fetching details for role: $roleName');
    try {
      final formData = FormData.fromMap({'role_name': roleName});
      final response = await dio.post(
        // User specified FormData which implies POST
        'techsavanna_pos.api.role_api.get_role_details',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return GetRoleDetailsResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;
        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch role details: $e');
    }
  }

  Future<CreateRoleResponse> disableRole(String roleName) async {
    debugPrint('Disabling role: $roleName');
    try {
      final formData = FormData.fromMap({'role_name': roleName});
      final response = await dio.post(
        'techsavanna_pos.api.role_api.disable_role',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateRoleResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;
        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to disable role: $e');
    }
  }

  Future<CreateRoleResponse> enableRole(String roleName) async {
    debugPrint('Enabling role: $roleName');
    try {
      final formData = FormData.fromMap({'role_name': roleName});
      final response = await dio.post(
        'techsavanna_pos.api.role_api.enable_role',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateRoleResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;
        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to enable role: $e');
    }
  }

  Future<SubmitPurchaseOrderResponse> submitPurchaseOrder({
    required SubmitPurchaseOrderRequest request,
  }) async {
    debugPrint('Submitting purchase order: ${request.lpoNo}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.purchase.submit_purchase_order',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return SubmitPurchaseOrderResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to submit purchase order: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to submit purchase order: $e');
    }
  }

  Future<ReceiveStockResponse> receiveStock(ReceiveStockRequest request) async {
    debugPrint('Receiving stock: ${request.toJson()}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.receive_stock_destination',
        data: request.toJson(),
      );

      debugPrint('Receive Stock Response: ${response.toString()}');

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

      return ReceiveStockResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint("Error receiving stock: ${e.toString()}");

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('success') &&
              message['success'] == false) {
            throw Exception(
              'Failed to receive stock: ${message['message'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to receive stock: $e');
    }
  }

  Future<GetInventoryDiscountRulesResponse> getInventoryDiscountRules(
    GetInventoryDiscountRulesRequest request,
  ) async {
    debugPrint('Getting inventory discount rules...');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.list_inventory_discount_rules',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return GetInventoryDiscountRulesResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to get inventory discount rules: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to get inventory discount rules: $e');
    }
  }

  Future<AddStockTakeResponse> addStockTake(
    AddStockTakeRequest request, {
    StockTakeRole role = StockTakeRole.stockManager,
  }) async {
    debugPrint('Adding stock take: ${request.reconciliationName} as $role');

    String endpoint;
    switch (role) {
      case StockTakeRole.salesPerson:
        endpoint =
            'techsavanna_pos.api.inventory_api.add_sales_person_stock_take';
        break;
      case StockTakeRole.stockController:
        endpoint =
            'techsavanna_pos.api.inventory_api.add_stock_controller_stock_take';
        break;
      case StockTakeRole.stockManager:
        endpoint =
            'techsavanna_pos.api.inventory_api.add_stock_manager_stock_take_and_submit';
        break;
    }

    try {
      final response = await dio.post(endpoint, data: request.toJson());

      debugPrint(response.toString());

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

      final message = data['message'];
      if (message is Map<String, dynamic> && message['success'] == false) {
        throw Exception(message['message'] ?? 'Failed to add stock take');
      }

      return AddStockTakeResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to add stock take: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to add stock take: $e');
    }
  }

  Future<GetStockReconciliationResponse> getStockReconciliation(
    GetStockReconciliationRequest request,
  ) async {
    debugPrint('Getting stock reconciliation: ${request.reconciliationName}');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.inventory_api.get_multi_level_stock_reconciliation',
        queryParameters: request.toQueryParams(),
      );

      debugPrint(response.toString());

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return GetStockReconciliationResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to get stock reconciliation: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to get stock reconciliation: $e');
    }
  }

  Future<CreateStockReconciliationResponse> createStockReconciliation(
    CreateStockReconciliationRequest request,
  ) async {
    debugPrint('Creating stock reconciliation...');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_multi_level_stock_reconciliation',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return CreateStockReconciliationResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to create stock reconciliation: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to create stock reconciliation: $e');
    }
  }

  Future<StockReconciliationsResponse> getStockReconciliations({
    required GetStockReconciliationsRequest request,
  }) async {
    debugPrint('Fetching stock reconciliations: ${request.toJson()}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.list_multi_level_stock_reconciliations',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return StockReconciliationsResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to fetch stock reconciliations: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch stock reconciliations: $e');
    }
  }

  Future<GetStockTransferResponse> getStockTransferRequest(
    String requestId,
  ) async {
    debugPrint('Getting stock transfer request: $requestId');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.stock.get_stock_transfer_request',
        queryParameters: {'request_id': requestId},
      );

      debugPrint('Get Stock Transfer Response: ${response.toString()}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return GetStockTransferResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('success') &&
              message['success'] == false) {
            throw Exception(
              'Failed to get stock transfer request: ${message['message'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to get stock transfer request: $e');
    }
  }

  Future<DispatchStockTransferResponse> dispatchStockTransfer(
    DispatchStockTransferRequest request,
  ) async {
    debugPrint('Dispatching stock transfer: ${request.toJson()}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.dispatch_stock',
        data: request.toJson(),
      );

      debugPrint('Dispatch Stock Transfer Response: ${response.toString()}');

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

      return DispatchStockTransferResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint("error maina ${e.toString()}");
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('success') &&
              message['success'] == false) {
            throw Exception(
              'Failed to dispatch stock transfer: ${message['message'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to dispatch stock transfer: $e');
    }
  }

  Future<SubmitStockTransferResponse> submitStockTransfer(
    SubmitStockTransferRequest request,
  ) async {
    debugPrint('Submitting stock transfer: ${request.requestId}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.submit_stock_transfer_request',
        data: request.toJson(),
      );

      debugPrint('Submit Stock Transfer Response: ${response.toString()}');

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

      return SubmitStockTransferResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('success') &&
              message['success'] == false) {
            throw Exception(
              'Failed to submit stock transfer: ${message['message'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to submit stock transfer: $e');
    }
  }

  Future<PurchaseOrderDetailResponse> getPurchaseOrderDetail({
    required String poName,
  }) async {
    debugPrint('Fetching purchase order detail for: $poName');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.purchase.get_purchase_order',
        queryParameters: {'po_name': poName},
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

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

      // Check if message contains error status
      if (data.containsKey('message') &&
          data['message'] is Map<String, dynamic>) {
        final message = data['message'] as Map<String, dynamic>;
        if (message.containsKey('status') && message['status'] == 'failed') {
          throw Exception(
            message['error'] ??
                message['message'] ??
                'Failed to fetch purchase order',
          );
        }
      }

      return PurchaseOrderDetailResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('DioException type: ${e.type}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic>) {
            if (message.containsKey('status') &&
                message['status'] == 'failed') {
              throw Exception(
                message['error'] ??
                    message['message'] ??
                    'Failed to fetch purchase order',
              );
            } else if (message.containsKey('message')) {
              throw Exception(message['message']);
            }
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      debugPrint('Exception: $e');
      throw Exception('Failed to fetch purchase order: $e');
    }
  }

  Future<CreateGrnResponse> createGrn({
    required CreateGrnRequest request,
  }) async {
    debugPrint('Creating GRN for LPO: ${request.lpoNo}');
    debugPrint('Request data: ${jsonEncode(request.toJson())}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.purchase.create_grn',
        data: request.toJson(),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

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

      return CreateGrnResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('DioException type: ${e.type}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic>) {
            if (message.containsKey('status') &&
                message['status'] == 'failed') {
              throw Exception(
                message['error'] ??
                    message['message'] ??
                    'Failed to create GRN',
              );
            } else if (message.containsKey('message')) {
              throw Exception(message['message']);
            }
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      debugPrint('Exception: $e');
      throw Exception('Failed to create GRN: $e');
    }
  }

  Future<UpdateWarehouseResponse> updateWarehouse(
    UpdateWarehouseRequest updateWarehouseRequest,
  ) async {
    debugPrint('Updating warehouse...');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.warehouse_api.update_warehouse',
        data: updateWarehouseRequest.toJson(),
      );

      debugPrint(response.toString());

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

      return UpdateWarehouseResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to update warehouse: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to update warehouse: $e');
    }
  }

  Future<PurchaseOrderResponse> getPurchaseOrders({
    required String company,
    int limit = 20,
    int offset = 0,
    String? status,
    Map<String, dynamic>? filters,
  }) async {
    debugPrint('Fetching purchase orders for company: $company');

    try {
      // Prepare filters
      final filterMap = filters ?? {'company': company};
      final filtersJson = jsonEncode(filterMap);

      // Prepare query parameters
      final queryParams = {
        'company': company,
        'limit': limit,
        'offset': offset,
        'filters': filtersJson,
      };

      // Add status if provided
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      debugPrint('Query parameters: $queryParams');

      final response = await dio.get(
        'techsavanna_pos.api.purchase.list_purchase_orders',
        queryParameters: queryParams,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

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

      return PurchaseOrderResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('DioException type: ${e.type}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              message['error'] ?? 'Failed to fetch purchase orders',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      debugPrint('Exception: $e');
      throw Exception('Failed to fetch purchase orders: $e');
    }
  }

  Future<StoreGetResponse> getAllStores(
    String company, {
    int limit = 20,
    int offset = 0,
  }) async {
    debugPrint('Fetching all stores... $company');

    try {
      final queryParams = {
        'company': company,
        'offset': offset,
        'limit': limit,
      };
      final response = await dio.get(
        'techsavanna_pos.api.warehouse_api.list_warehouses',
        queryParameters: queryParams,
      );
      debugPrint(response.toString());
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

      return StoreGetResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to fetch customers: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  Future<CreateSupplierResponse> createSupplier(
    CreateSupplierRequest request,
  ) async {
    debugPrint('Creating supplier: ${request.supplierName}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.supplier_api.create_supplier',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return CreateSupplierResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to create supplier: $e');
    }
  }

  Future<CreateSupplierResponse> updateSupplier(
    UpdateSupplierRequest request,
  ) async {
    debugPrint('Updating supplier: ${request.supplierName}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.supplier_api.update_supplier',
        data: request.toJson(),
      );

      debugPrint(response.toString());

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

      return CreateSupplierResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to create supplier: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to create supplier: $e');
    }
  }

  Future<SupplierGroupResponse> getSupplierGroups() async {
    debugPrint('Fetching supplier groups...');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.supplier_api.get_supplier_groups',
      );

      debugPrint(response.toString());

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

      return SupplierGroupResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to fetch supplier groups: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch supplier groups: $e');
    }
  }

  Future<ApproveStockTransferResponse> approveStockTransfer(
    ApproveStockTransferRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.approve_stock_transfer',
        data: request.toJson(),
      );

      debugPrint('Approve Stock Transfer Response: ${response.toString()}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      if (data.containsKey('message') &&
          data['message'] is Map<String, dynamic>) {
        final message = data['message'] as Map<String, dynamic>;

        if (message.containsKey('success') && message['success'] == false) {
          throw Exception(
            message['message'] ?? 'Failed to approve stock transfer',
          );
        }

        return ApproveStockTransferResponse.fromJson(message);
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('success') &&
                message['success'] == false) {
              throw Exception(
                message['message'] ?? 'Failed to approve stock transfer',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to approve stock transfer');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to approve stock transfer: $e');
    }
  }

  Future<CreateMaterialIssueResponse> createMaterialIssue(
    CreateMaterialIssueRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_material_issue',
        data: request.toJson(),
      );

      debugPrint('Create Material Issue Response: ${response.toString()}');

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

      if (data.containsKey('message') &&
          data['message'] is Map<String, dynamic>) {
        final message = data['message'] as Map<String, dynamic>;

        if (message.containsKey('success') && message['success'] == false) {
          throw Exception(
            message['message'] ?? 'Failed to create material issue',
          );
        }

        return CreateMaterialIssueResponse.fromJson(message);
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('success') &&
                message['success'] == false) {
              throw Exception(
                message['message'] ?? 'Failed to create material issue',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to create material issue');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to create material issue: $e');
    }
  }

  Future<MaterialRequestsResponse> getMaterialRequests({
    required GetMaterialRequestsRequest request,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.list_stock_transfer_requests',
        data: request.toJson(),
      );

      debugPrint('Get Material Requests Response: ${response.toString()}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      if (data.containsKey('message') &&
          data['message'] is Map<String, dynamic>) {
        final message = data['message'] as Map<String, dynamic>;

        if (message.containsKey('success') && message['success'] == false) {
          throw Exception(
            message['message'] ?? 'Failed to fetch material requests',
          );
        }

        return MaterialRequestsResponse.fromJson(message);
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('success') &&
                message['success'] == false) {
              throw Exception(
                message['message'] ?? 'Failed to fetch material requests',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to fetch material requests');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to fetch material requests: $e');
    }
  }

  Future<CreateStockTransferResponse> createStockTransfer(
    CreateStockTransferRequest request,
  ) async {
    debugPrint('Creating stock transfer: ${request.toJsonString()}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.create_stock_transfer_request',
        data: request.toJson(),
      );
      debugPrint(response.toString());

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

      return CreateStockTransferResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to create stock transfer: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to create stock transfer: $e');
    }
  }

  Future<CreateMaterialTransferResponse> createMaterialTransferNew(
    CreateMaterialTransferRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_material_transfer',
        data: request.toJson(),
      );

      debugPrint('Create Material Transfer Response: ${response.toString()}');

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

      if (data.containsKey('message') &&
          data['message'] is Map<String, dynamic>) {
        final message = data['message'] as Map<String, dynamic>;

        if (message.containsKey('success') && message['success'] == false) {
          throw Exception(message['message'] ?? 'Failed to create transfer');
        }

        return CreateMaterialTransferResponse.fromJson(message);
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('success') &&
                message['success'] == false) {
              throw Exception(
                message['message'] ?? 'Failed to create transfer',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to create material transfer');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to create material transfer: $e');
    }
  }

  Future<CreateStockEntryResponse> createStockEntry(
    CreateStockEntryRequest request,
  ) async {
    debugPrint('Creating stock entry: ${request.stockEntryType}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_stock_entry',
        data: request.toJson(),
      );

      debugPrint('Response: ${response.toString()}');

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

      return CreateStockEntryResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('status') &&
                message['status'] == 'failed') {
              throw Exception(
                'Failed to create stock entry: ${message['error'] ?? 'Unknown error'}',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to create stock entry');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to create stock entry: $e');
    }
  }

  Future<CreateCustomerResponse> createCustomer(
    CompleteCustomerRequest customer,
  ) async {
    debugPrint('Creating customer: ${customer.company}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.customer_api.create_customer',
        data: customer.toJson(),
      );

      debugPrint('Response: ${response.toString()}');

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

      final message = data['message'];
      if (message is Map<String, dynamic> && message['success'] == false) {
        throw Exception(message['message'] ?? 'Failed to create customer');
      }

      // Use CreateCustomerResponse instead of CustomerResponse
      return CreateCustomerResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      // Handle server errors with response
      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('status') &&
                message['status'] == 'failed') {
              throw Exception(
                'Failed to create customer: ${message['error'] ?? 'Unknown error'}',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to create customer');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<CreateMaterialReceiptResponse> createMaterialReceipt(
    CreateMaterialReceiptRequest request,
  ) async {
    debugPrint('Creating material receipt for company: ${request.company}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_material_receipt',
        data: request.toJson(),
      );

      debugPrint('Response: ${response.toString()}');

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

      return CreateMaterialReceiptResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      // Handle server errors with response
      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('status') &&
                message['status'] == 'failed') {
              throw Exception(
                'Failed to create material receipt: ${message['error'] ?? 'Unknown error'}',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to create material receipt');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to create material receipt: $e');
    }
  }

  Future<StockLedgerResponse> getStockLedgerEntries({
    required String company,
    required String warehouse,
    String? voucherType,
    int? limit,
    int? offset,
  }) async {
    debugPrint('Fetching stock ledger entries: $voucherType $limit $offset');
    debugPrint('Company: $company, Warehouse: $warehouse');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.inventory_api.get_stock_ledger_entries',
        queryParameters: {
          "company": company,
          "warehouse": warehouse,
          if (voucherType != null) "voucher_type": voucherType,
          if (limit != null) "limit": limit,
          if (offset != null) "offset": offset,
        },
      );
      debugPrint(response.toString());

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

      return StockLedgerResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            throw Exception(
              'Failed to fetch stock ledger: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch stock ledger: $e');
    }
  }

  Future<StockEntriesResponse> getStockEntries({
    required StockEntriesRequest request,
  }) async {
    debugPrint('Fetching stock entries: ${request.toJson()}');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.inventory_api.list_stock_entries',
        queryParameters: request.toJson(),
      );

      debugPrint(response.toString());

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

      // Handle API response structure
      if (data.containsKey('message')) {
        final message = data['message'];
        if (message is Map<String, dynamic>) {
          if (message.containsKey('success') && message['success'] == true) {
            return StockEntriesResponse.fromJson(message);
          } else {
            throw Exception(
              message['error'] ?? 'Failed to fetch stock entries',
            );
          }
        }
      }

      throw Exception('Invalid response structure');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('success') &&
              message['success'] == false) {
            throw Exception(
              'Failed to fetch stock entries: ${message['error'] ?? 'Unknown error'}',
            );
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to fetch stock entries: $e');
    }
  }

  Future<ProvisionalAccountResponse> createAccountProvisioning(
    ProvisionalAccountRequest provisioningAccounts,
  ) async {
    debugPrint('Creating accounts: ${provisioningAccounts.company}');

    try {
      // Use POST method instead of GET for creating a customer
      final response = await dio.post(
        'techsavanna_pos.api.account_provisioning_api.auto_configure_provisional_account',
        data: provisioningAccounts.toJson(),
      );

      debugPrint('Response: ${response.toString()}');

      // Successful creation usually returns 201 Created
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
      final request = CreateWarehouseRequest(
        warehouseName: provisioningAccounts.company,
        company: provisioningAccounts.company,
        warehouseType: "Company Warehouse",
        setAsDefault: true,
        addressLine1: "Kenya",
        city: "Nairobi",
      );
      await createWarehouse(request);
      return ProvisionalAccountResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      // Handle server errors with response
      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('status') &&
                message['status'] == 'failed') {
              throw Exception(
                'Failed to create customer: ${message['error'] ?? 'Unknown error'}',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to create customer');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<CreateWarehouseResponse> createWarehouse(
    CreateWarehouseRequest createWarehouseRequest,
  ) async {
    debugPrint('Creating customer: ${createWarehouseRequest.company}');

    try {
      // Use POST method instead of GET for creating a customer
      final response = await dio.post(
        'techsavanna_pos.api.warehouse_api.create_warehouse', // Updated endpoint
        data: createWarehouseRequest.toJson(), // Send the customer data
      );

      debugPrint('Response: ${response.toString()}');

      // Successful creation usually returns 201 Created
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

      // Use CreateCustomerResponse instead of CustomerResponse
      await getCurrentUser();
      return CreateWarehouseResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DioError: ${e.toString()}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      // Handle server errors with response
      if (e.response != null) {
        debugPrint('Error response: ${e.response!.data}');

        if (e.response!.data is Map<String, dynamic>) {
          final err = e.response!.data as Map<String, dynamic>;

          if (err.containsKey('message')) {
            final message = err['message'];
            if (message is Map<String, dynamic> &&
                message.containsKey('status') &&
                message['status'] == 'failed') {
              throw Exception(
                'Failed to create customer: ${message['error'] ?? 'Unknown error'}',
              );
            } else if (message is String) {
              throw Exception(message);
            }
          }

          throw Exception(err['error'] ?? err['message'] ?? 'Server error');
        }
      }

      throw Exception(e.message ?? 'Failed to create customer');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<StaffUsersResponse> createStaffUser(
    StaffUserRequest createStaffRequest,
  ) async {
    debugPrint('Creating staff user: ${createStaffRequest.email}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.staff_api.create_staff_user',
        data: createStaffRequest.toJson(),
      );

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

      return StaffUsersResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];
          if (message is Map<String, dynamic> &&
              message.containsKey('status') &&
              message['status'] == 'failed') {
            final failedItems = message['failed'] as List<dynamic>? ?? [];
            final errors = failedItems
                .map((e) => e['email']?.toString() ?? 'Unknown')
                .join(', ');
            throw Exception('User creation failed. Duplicate users: $errors');
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    }
  }

  Future<StaffUsersResponse> getUserList({
    int limit = 20,
    int offset = 0,
  }) async {
    debugPrint("getting staff users with limit: $limit, offset: $offset");
    try {
      final queryParams = {'enabled_only': false};
      final response = await dio.get(
        'techsavanna_pos.api.staff_api.get_staff_users',
        queryParameters: queryParams,
      );

      final data = response.data;

      debugPrint("xbshaxs $data");

      if (data == null || data['message'] == null) {
        debugPrint("me");
        throw Exception('Invalid response from server');
      }

      debugPrint(" hwjdfghsacdgwe $data");

      return StaffUsersResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<StockItemResponse> getItemsList(
    String company, {
    int page = 1,
    int pageSize = 20,
  }) async {
    debugPrint("getting items");
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

      debugPrint("xbshaxs $data");

      if (data == null || data['message'] == null) {
        debugPrint("me");
        throw Exception('Invalid response from server');
      }

      debugPrint(" hwjdfghsacdgwe $data");

      return StockItemResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UpdateCreditLimitResponse> updateCreditLimit(
    UpdateCreditLimitRequest request,
  ) async {
    debugPrint("updating credit limit");

    try {
      final response = await dio.post(
        'techsavanna_pos.api.customer_api.set_customer_credit_limit',
        data: request.toJson(),
      );

      final data = response.data;

      debugPrint("credit limit response $data");

      if (data == null || data['message'] == null) {
        debugPrint("invalid response structure");
        throw Exception('Invalid response from server');
      }

      return UpdateCreditLimitResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['exception'] ??
            e.response?.data?['message'] ??
            e.message,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<StockResponse> addItemToStock(StockRequest stockRequest) async {
    debugPrint('Adding item to stock: ${stockRequest.itemCode}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.get_stock_balance_api',
        data: stockRequest.toJson(),
      );

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

      return StockResponse.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }

      if (e.response?.data is Map<String, dynamic>) {
        final err = e.response!.data;

        if (err.containsKey('message')) {
          final message = err['message'];

          if (message is Map<String, dynamic>) {
            if (message.containsKey('status') &&
                message['status'] == 'failed') {
              throw Exception(
                'Item addition failed: ${message['error'] ?? 'Unknown error'}',
              );
            }
          } else if (message is String) {
            throw Exception(message);
          }
        }

        throw Exception(err['error'] ?? err['message'] ?? 'Server error');
      }

      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to add item to stock: $e');
    }
  }

  // ✨ NEW METHOD: Get Loyalty Balance
  Future<LoyaltyBalanceResponse> getLoyaltyBalance(String customerId) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.loyalty.get_loyalty_balance',
        queryParameters: {'customer_id': customerId, 'limit': 5},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return LoyaltyBalanceResponse.fromJson(message);
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
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RedeemPointsResponse> redeemPoints(RedeemPointsRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.loyalty.redeem_points',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("error  is  here  $data");
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return RedeemPointsResponse.fromJson(message);
    } on DioException catch (e) {
      debugPrint("error  is  here  ${e.toString()}");
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LoyaltyHistoryResponse> getLoyaltyHistory(
    LoyaltyHistoryRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.loyalty.get_points_history',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return LoyaltyHistoryResponse.fromJson(message);
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
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignLoyaltyProgramResponse> assignLoyaltyProgram(
    AssignLoyaltyProgramRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.loyalty.assign_loyalty_program',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint(data.toString());
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return AssignLoyaltyProgramResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint(e.message);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UpdateCustomerResponse> updateCustomer({
    required UpdateCustomerRequest updateRequest,
    required String customerId,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.customer_api.update_customer',
        queryParameters: {'customer_id': customerId},
        data: updateRequest.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      if (message['success'] == false) {
        throw Exception(message['message'] ?? 'Failed to update customer');
      }

      return UpdateCustomerResponse.fromJson(data);
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
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignRolesResponse> assignRolesToStaff(
    AssignRolesRequest request,
  ) async {
    debugPrint("Assign Roles Response: ${request.toJson().toString()}");
    try {
      final response = await dio.post(
        'techsavanna_pos.api.staff_api.assign_roles_to_staff',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      debugPrint("Assign Roles Response: $data");

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      return AssignRolesResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint("Assign Roles Response: $e");

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateStaffUserResponse> updateStaffUser(
    UpdateStaffUserRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.staff_api.update_staff_user',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      debugPrint("Update Staff User Response: $data");

      // Validate response structure
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      // Get the message object from the response
      final messageData = data['message'];
      if (messageData is! Map<String, dynamic>) {
        throw Exception('message field is not a valid object');
      }

      // Now get staff_user from the message object
      final staffUser = messageData['staff_user'];
      if (staffUser is! Map<String, dynamic>) {
        throw Exception('staff_user field is not a valid object');
      }

      // Pass the entire data to fromJson since UpdateStaffUserResponse.fromJson
      // should be designed to handle this structure
      return UpdateStaffUserResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint("Update Staff User Response: $e");
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Unable to connect to server. Please check your internet.',
        );
      } else if (e.response != null) {
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              errorData['exception'] ??
              'Server error ${e.response!.statusCode}';
          throw Exception(errorMessage.toString());
        } catch (_) {
          throw Exception('Server error: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<RolesResponse> getRolesList() async {
    debugPrint("Getting roles list");
    try {
      final response = await dio.get(
        'techsavanna_pos.api.staff_api.get_all_roles',
      );

      final data = response.data;

      debugPrint("Response data: $data");

      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      return RolesResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint("DioException: ${e.response?.data}");
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint("Error: $e");
      throw Exception(e.toString());
    }
  }

  Future<CurrentUserResponse> getCurrentUser() async {
    debugPrint("DEBUG: calling getCurrentUser...");

    try {
      final response = await dio.get(
        'techsavanna_pos.api.auth_api.get_current_user',
      );

      final data = response.data;
      debugPrint("DEBUG: getCurrentUser response: $data");

      if (data == null || data['message'] == null) {
        debugPrint("DEBUG: getCurrentUser failed - Invalid response");
        throw Exception('Invalid response from server');
      }

      final currentUser = CurrentUserResponse.fromJson(data);

      debugPrint(
        "DEBUG: current user parsed successfully: ${currentUser.message.user.fullName}",
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(currentUser.toJson()));

      return currentUser;
    } on DioException catch (e) {
      debugPrint("DEBUG: DioException during getCurrentUser: ${e.message}");
      debugPrint("DEBUG: Response data: ${e.response?.data}");
      throw Exception(e.response?.data?['exception'] ?? e.message);
    } catch (e) {
      debugPrint("DEBUG: General error during getCurrentUser: $e");
      throw Exception(e.toString());
    }
  }

  // Helper function to retrieve userData
  Future<Message?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('userData');

    if (userDataJson != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      return Message.fromJson(userDataMap);
    }
    return null;
  }

  // Helper function to retrieve userData
  Future<Message?> getCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('companyData');

    if (userDataJson != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      return Message.fromJson(userDataMap);
    }
    return null;
  }

  // Helper function to delete userData
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    debugPrint('USER DATA CLEARED');
  }

  Future<CompanyResponse> registerCompany(CompanyRequest companyRequest) async {
    debugPrint('--- user_remote_datasource: registerCompany START ---');
    try {
      debugPrint('REGISTER PAYLOAD => ${companyRequest.toJson()}');

      final response = await dio.post(
        'techsavanna_pos.api.onboarding_api.create_company',
        data: companyRequest.toJson(),
      );

      final data = response.data;

      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      debugPrint('REGISTER RESPONSE => $data');

      // Save full response if needed
      await getCurrentUser();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('companyData', jsonEncode(data));
      final request = ProvisionalAccountRequest(
        company: companyRequest.companyName,
        createAccountIfMissing: true,
      );
      debugPrint(
        'Calling createAccountProvisioning with company: ${request.company}',
      );
      await createAccountProvisioning(request);
      debugPrint('--- user_remote_datasource: registerCompany SUCCESS ---');
      return CompanyResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DIO ERROR');
      debugPrint('STATUS CODE => ${e.response?.statusCode}');
      debugPrint('ERROR DATA => ${e.response?.data}');

      if (e.response?.data != null && e.response?.data['exception'] != null) {
        throw Exception(e.response!.data['exception']);
      }

      throw Exception(e.message);
    } catch (e) {
      debugPrint('GENERAL ERROR => $e');
      throw Exception(e.toString());
    }
  }

  Future<BrandResponse> getItemBrands() async {
    debugPrint('Fetching item brands...');
    try {
      final response = await dio.get(
        'techsavanna_pos.api.product_api.get_brands',
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      debugPrint("Brand API Response: ${response.statusCode}");

      if (data == null) {
        throw Exception('Empty response from server');
      }

      return BrandResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response!.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ClosePOSSessionResponse> closePOSSession(
    ClosePOSSessionRequest request,
  ) async {
    try {
      final response = await dio.post(
        'savanna_pos.savanna_pos.apis.sales_api.close_pos_opening_entry',
        data: request.toJson(),
      );

      debugPrint('ClosePOSSession Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is String) {
          return ClosePOSSessionResponse.fromJson(jsonDecode(response.data));
        }
        return ClosePOSSessionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to close POS session');
      }
    } catch (e) {
      debugPrint('Error closing POS session: $e');
      throw Exception('Failed to close POS session: $e');
    }
  }

  Future<void> addBarcode(String itemCode, String barcode) async {
    debugPrint('Adding barcode for item $itemCode: $barcode');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.add_barcode',
        data: {'item_code': itemCode, 'barcode': barcode},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message']?['error'] ??
          e.response?.data?['exception'] ??
          e.message;
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateProduct(CreateProductRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.product_api.update_product',
        data: request.toJson(),
      );
      debugPrint('Update Product Response Data: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message']?['error'] ??
          e.response?.data?['exception'] ??
          e.message;
      throw Exception(errorMsg);
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

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message']?['error'] ??
          e.response?.data?['exception'] ??
          e.message;
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
