import 'package:dio/dio.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/models/stock_ledger_entry.dart';
import 'package:pos/domain/requests/inventory/add_stock_take_request.dart';
import 'package:pos/domain/requests/inventory/approve_stock_transfer_request.dart';
import 'package:pos/domain/requests/inventory/create_material_issue_request.dart';
import 'package:pos/domain/requests/inventory/create_material_receipt_request.dart';
import 'package:pos/domain/requests/inventory/create_stock_reconciliation_request.dart';
import 'package:pos/domain/requests/inventory/create_stock_transfer_request.dart';
import 'package:pos/domain/requests/inventory/create_transfer_request.dart';
import 'package:pos/domain/requests/inventory/create_warehouse.dart';
import 'package:pos/domain/requests/inventory/update_warehouse.dart';
import 'package:pos/domain/requests/disable_discount_rule_request.dart';
import 'package:pos/domain/requests/enable_discount_rule_request.dart';
import 'package:pos/domain/requests/inventory/dispatch_stock_transfer_request.dart';
import 'package:pos/domain/requests/get_inventory_discount_rules_request.dart';
import 'package:pos/domain/requests/inventory/get_material_requests_request.dart';
import 'package:pos/domain/requests/inventory/get_stock_reconciliation_request.dart';
import 'package:pos/domain/requests/inventory/get_stock_reconciliations_request.dart';
import 'package:pos/domain/requests/inventory/receive_stock_request.dart';
import 'package:pos/domain/requests/inventory/stock_entries_request.dart';
import 'package:pos/domain/requests/inventory/stock_entry.dart';
import 'package:pos/domain/requests/inventory/stock_request.dart';
import 'package:pos/domain/requests/inventory/submit_stock_transfer_request.dart';
import 'package:pos/domain/requests/update_discount_rule_request.dart';
import 'package:pos/domain/requests/create_discount_rule_request.dart';

import 'package:pos/domain/responses/inventory/add_stock_take_response.dart';
import 'package:pos/domain/responses/inventory/approve_stock_transfer_response.dart';
import 'package:pos/domain/responses/create_discount_rule_response.dart';
import 'package:pos/domain/responses/inventory/update_warehouse_response.dart';
import 'package:pos/domain/responses/inventory/create_material_issue_response.dart';
import 'package:pos/domain/responses/inventory/create_material_receipt_response.dart';
import 'package:pos/domain/responses/inventory/create_stock_reconciliation_response.dart';
import 'package:pos/domain/responses/inventory/create_stock_transfer_response.dart';
import 'package:pos/domain/responses/inventory/create_transfer_response.dart';
import 'package:pos/domain/responses/inventory/dispatch_stock_transfer_response.dart';
import 'package:pos/domain/responses/get_inventory_discount_rules_response.dart';
import 'package:pos/domain/responses/inventory/get_stock_reconciliation_response.dart';
import 'package:pos/domain/responses/inventory/get_stock_transfer_response.dart';
import 'package:pos/domain/responses/inventory/low_alert_response.dart';
import 'package:pos/domain/responses/inventory/material_requests_response.dart';
import 'package:pos/domain/responses/inventory/receive_stock_response.dart';
import 'package:pos/domain/responses/inventory/stock_entries_response.dart';
import 'package:pos/domain/responses/inventory/stock_reconciliations_response.dart';
import 'package:pos/domain/responses/inventory/stock_summary_response.dart';
import 'package:pos/domain/responses/inventory/submit_stock_transfer_response.dart';
import 'package:pos/domain/responses/inventory/stock_entry_response.dart';
import 'package:pos/domain/responses/update_discount_rule_response.dart';
import 'package:pos/domain/responses/disable_discount_rule_response.dart';
import 'package:pos/domain/responses/enable_discount_rule_response.dart';
import 'package:pos/domain/responses/inventory/create_warehouse.dart';
import 'package:pos/domain/responses/inventory/stock_reco.dart';

class InventoryRemoteDataSource extends BaseRemoteDataSource {
  InventoryRemoteDataSource(super.dio);

  Future<StockResponses> getLowStockAlert(
    String? warehouse,
    double? threshold,
    String? company,
  ) async {
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
      throw Exception(getErrorMessage(e));
    } catch (e) {
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
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      return StockSummaryResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
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

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
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
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
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
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
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

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
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
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateStockTransferResponse> createStockTransfer(
    CreateStockTransferRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.create_stock_transfer_request',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateStockTransferResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
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
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateStockEntryResponse> createStockEntry(
    CreateStockEntryRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_stock_entry',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateStockEntryResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateMaterialReceiptResponse> createMaterialReceipt(
    CreateMaterialReceiptRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_material_receipt',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateMaterialReceiptResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<StockLedgerResponse> getStockLedgerEntries({
    required String company,
    required String warehouse,
    String? voucherType,
    int? limit,
    int? offset,
  }) async {
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return StockLedgerResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<StockEntriesResponse> getStockEntries({
    required StockEntriesRequest request,
  }) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.inventory_api.list_stock_entries',
        queryParameters: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

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
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<ReceiveStockResponse> receiveStock(ReceiveStockRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.receive_stock_destination',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('message') &&
          data['message'] is Map<String, dynamic>) {
        return ReceiveStockResponse.fromJson(
          data['message'] as Map<String, dynamic>,
        );
      }

      return ReceiveStockResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<GetInventoryDiscountRulesResponse> getInventoryDiscountRules(
    GetInventoryDiscountRulesRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.list_inventory_discount_rules',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return GetInventoryDiscountRulesResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<AddStockTakeResponse> addStockTake(
    AddStockTakeRequest request, {
    StockTakeRole role = StockTakeRole.stockManager,
  }) async {
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is Map<String, dynamic> && message['success'] == false) {
        throw Exception(message['message'] ?? 'Failed to add stock take');
      }

      return AddStockTakeResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<GetStockReconciliationResponse> getStockReconciliation(
    GetStockReconciliationRequest request,
  ) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.inventory_api.get_multi_level_stock_reconciliation',
        queryParameters: request.toQueryParams(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return GetStockReconciliationResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateStockReconciliationResponse> createStockReconciliation(
    CreateStockReconciliationRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_multi_level_stock_reconciliation',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateStockReconciliationResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<StockReconciliationsResponse> getStockReconciliations({
    required GetStockReconciliationsRequest request,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.list_multi_level_stock_reconciliations',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return StockReconciliationsResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<GetStockTransferResponse> getStockTransferRequest(
    String requestId,
  ) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.stock.get_stock_transfer_request',
        queryParameters: {'request_id': requestId},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return GetStockTransferResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<DispatchStockTransferResponse> dispatchStockTransfer(
    DispatchStockTransferRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.dispatch_stock',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return DispatchStockTransferResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<SubmitStockTransferResponse> submitStockTransfer(
    SubmitStockTransferRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.stock.submit_stock_transfer_request',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return SubmitStockTransferResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateDiscountRuleResponse> createDiscountRule(
    CreateDiscountRuleRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.create_inventory_discount_rule',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateDiscountRuleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateDiscountRuleResponse> updateDiscountRule(
    UpdateDiscountRuleRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.update_inventory_discount_rule',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data['message'] != null) {
        final messageData = data['message'];
        if (messageData is Map<String, dynamic>) {
          if (messageData['success'] == false) {
            throw Exception(messageData['message'] ?? 'Failed to update rule');
          }
        }
      }

      return UpdateDiscountRuleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<DisableDiscountRuleResponse> disableDiscountRule(
    DisableDiscountRuleRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.disable_inventory_discount_rule',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data['message'] != null) {
        final messageData = data['message'];
        if (messageData is Map<String, dynamic>) {
          if (messageData['success'] == false) {
            throw Exception(messageData['message'] ?? 'Failed to disable rule');
          }
        }
      }

      return DisableDiscountRuleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<EnableDiscountRuleResponse> enableDiscountRule(
    EnableDiscountRuleRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.enable_inventory_discount_rule',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data['message'] != null) {
        final messageData = data['message'];
        if (messageData is Map<String, dynamic>) {
          if (messageData['success'] == false) {
            throw Exception(messageData['message'] ?? 'Failed to enable rule');
          }
        }
      }

      return EnableDiscountRuleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateWarehouseResponse> createWarehouse(
    CreateWarehouseRequest createWarehouseRequest,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.warehouse_api.create_warehouse',
        data: createWarehouseRequest.toJson(),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      return CreateWarehouseResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateWarehouseResponse> updateWarehouse(
    UpdateWarehouseRequest updateWarehouseRequest,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.warehouse_api.update_warehouse',
        data: updateWarehouseRequest.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      return UpdateWarehouseResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<StockResponse> addItemToStock(StockRequest stockRequest) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.inventory_api.add_stock_to_warehouse',
        data: stockRequest.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      return StockResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }
}
