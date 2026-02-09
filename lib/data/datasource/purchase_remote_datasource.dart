import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/requests/purchase/create_grn_request.dart';
import 'package:pos/domain/requests/purchase/create_purchase_order_request.dart';
import 'package:pos/domain/requests/purchase/pay_purchase_invoice_request.dart';
import 'package:pos/domain/requests/purchase/submit_purchase_order_request.dart';
import 'package:pos/domain/requests/suppliers/create_supplier_group_request.dart';
import 'package:pos/domain/requests/suppliers/create_supplier_request.dart';
import 'package:pos/domain/requests/suppliers/update_supplier_request.dart';
import 'package:pos/domain/responses/purchase/create_grn_response.dart';
import 'package:pos/domain/responses/purchase/create_purchase_order_response.dart';
import 'package:pos/domain/responses/purchase/grn_detail_response.dart';
import 'package:pos/domain/responses/purchase/grn_response.dart';
import 'package:pos/domain/responses/purchase/pay_purchase_invoice_response.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_detail_response.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';
import 'package:pos/domain/responses/purchase/purchase_order_detail_response.dart';
import 'package:pos/domain/responses/purchase/purchase_order_response.dart';
import 'package:pos/domain/responses/purchase/submit_purchase_order_response.dart';
import 'package:pos/domain/responses/suppliers/create_supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers/create_supplier_response.dart';
import 'package:pos/domain/responses/suppliers/supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers/suppliers_response.dart';


class PurchaseRemoteDataSource extends BaseRemoteDataSource {
  PurchaseRemoteDataSource(super.dio);

  Future<SubmitPurchaseOrderResponse> submitPurchaseOrder({
    required SubmitPurchaseOrderRequest request,
  }) async {
    //debugPrint('Submitting purchase order: ${request.lpoNo}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.purchase.submit_purchase_order',
        data: request.toJson(),
      );

      //debugPrint(response.toString());

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

  Future<PurchaseOrderDetailResponse> getPurchaseOrderDetail({
    required String poName,
  }) async {

    try {
      final response = await dio.get(
        'techsavanna_pos.api.purchase.get_purchase_order',
        queryParameters: {'po_name': poName},
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
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to fetch purchase order: $e');
    }
  }

  Future<CreateGrnResponse> createGrn({
    required CreateGrnRequest request,
  }) async {
    //debugPrint('Creating GRN for LPO: ${request.lpoNo}');
    //debugPrint('Request data: ${jsonEncode(request.toJson())}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.purchase.create_grn',
        data: request.toJson(),
      );

      //debugPrint('Response status: ${response.statusCode}');
      //debugPrint('Response data: ${response.data}');

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
      //debugPrint('DioException: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      //debugPrint('Exception: $e');
      throw Exception('Failed to create GRN: $e');
    }
  }

  Future<PurchaseOrderResponse> getPurchaseOrders({
    required String company,
    int limit = 20,
    int offset = 0,
    String? status,
    String? searchTerm,
    Map<String, dynamic>? filters,
  }) async {
    //debugPrint('Fetching purchase orders for company: $company');

    try {
      // Prepare filters
      final filterMap = filters ?? {'company': company};
      if (searchTerm != null && searchTerm.isNotEmpty) {
        filterMap['name'] = ['like', '%$searchTerm%'];
      }
      final filtersJson = jsonEncode(filterMap);

      // Prepare query parameters
      final queryParams = {
        'company': company,
        'limit': limit,
        'offset': offset,
        'filters': filtersJson,
        'search_term': searchTerm ?? '',
      };

      // Add status if provided
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      //debugPrint('Query parameters: $queryParams');

      final response = await dio.get(
        'techsavanna_pos.api.purchase.list_purchase_orders',
        queryParameters: queryParams,
      );

      //debugPrint('Response status: ${response.statusCode}');
      //debugPrint('Response data: ${response.data}');

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
      //debugPrint('DioException: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      //debugPrint('Exception: $e');
      throw Exception('Failed to fetch purchase orders: $e');
    }
  }

  Future<CreateSupplierResponse> createSupplier(
    CreateSupplierRequest request,
  ) async {
    //debugPrint('Creating supplier: ${request.supplierName}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.supplier_api.create_supplier',
        data: request.toJson(),
      );

      //debugPrint(response.toString());

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
    //debugPrint('Updating supplier: ${request.supplierName}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.supplier_api.update_supplier',
        data: request.toJson(),
      );

      //debugPrint(response.toString());

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
      // Reusing logic similar to createSupplier or generic error handler
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
          // ... simple error handling
          throw Exception(err['message'] ?? 'Server error');
        }
        throw Exception(err['error'] ?? 'Server error');
      }
      throw Exception(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  Future<SupplierGroupResponse> getSupplierGroups() async {
    //debugPrint('Fetching supplier groups...');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.supplier_api.get_supplier_groups',
      );

      //debugPrint(response.toString());

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
      throw Exception(
        getErrorMessage(e),
      ); // Simplified using base helper if applicable or standard check
    } catch (e) {
      throw Exception('Failed to fetch supplier groups: $e');
    }
  }

  Future<PurchaseInvoiceResponse> getPurchaseInvoices({
    int page = 1,
    int pageSize = 20,
    String? company,
    String? status,
    String? supplier,
  }) async {
    //debugPrint('Fetching purchase invoices: page=$page, pageSize=$pageSize, company=$company, status=$status, supplier=$supplier',);

    try {
      final Map<String, dynamic> queryParams = {
        "page": page,
        "page_size": pageSize,
      };

      if (company != null && company.isNotEmpty) {
        queryParams["company"] = company;
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams["status"] = status;
      }
      if (supplier != null && supplier.isNotEmpty) {
        queryParams["supplier"] = supplier;
      }

      final response = await dio.get(
        'techsavanna_pos.api.purchase.list_purchase_invoices',
        queryParameters: queryParams,
      );

      //debugPrint('Purchase invoices response: ${jsonEncode(response.data)}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is Map<String, dynamic> && message['status'] == 'error') {
        throw Exception(message['message'] ?? 'Unknown error from server');
      }

      return PurchaseInvoiceResponse.fromJson(data);
    } on DioException catch (e) {
      //debugPrint('Dio error fetching purchase invoices: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      //debugPrint('Error fetching purchase invoices: $e');
      throw Exception('Failed to fetch purchase invoices: ${e.toString()}');
    }
  }

  Future<PurchaseInvoiceDetailResponse> getPurchaseInvoiceDetails(
    String invoiceNo,
  ) async {
    //debugPrint('Fetching purchase invoice details for: $invoiceNo');

    try {
      final response = await dio.get(
        'techsavanna_pos.api.purchase.get_purchase_invoice_details',
        queryParameters: {"invoice_no": invoiceNo},
      );

      //debugPrint('Purchase invoice details response: ${jsonEncode(response.data)}',);

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is Map<String, dynamic> && message['status'] == 'error') {
        throw Exception(message['message'] ?? 'Unknown error from server');
      }

      return PurchaseInvoiceDetailResponse.fromJson(data);
    } on DioException catch (e) {
      //debugPrint('Dio error fetching purchase invoice details: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      //debugPrint('Error fetching purchase invoice details: $e');
      throw Exception(
        'Failed to fetch purchase invoice details: ${e.toString()}',
      );
    }
  }

  Future<GrnListResponse> getGrnList({
    int page = 1,
    int pageSize = 20,
    String? company,
    String? supplier,
    String? searchTerm,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        "page": page,
        "page_size": pageSize,
      };

      if (company != null && company.isNotEmpty) {
        queryParams["company"] = company;
      }
      if (supplier != null && supplier.isNotEmpty) {
        queryParams["supplier"] = supplier;
      }
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams["search"] = searchTerm;
      }

      final response = await dio.get(
        'techsavanna_pos.api.reports.grn_list_report',
        queryParameters: queryParams,
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      return GrnListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to fetch GRN list: ${e.toString()}');
    }
  }

  Future<GrnDetailResponse> getGrnDetails(String grnNo) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.reports.grn_detail_report',
        queryParameters: {"grn_no": grnNo},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      return GrnDetailResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to fetch GRN details: ${e.toString()}');
    }
  }

  Future<void> createPurchaseInvoiceFromGrn({
    required String grnNo,
    required bool doNotSubmit,
    required String billDate,
    String? fileBase64,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        "grn_no": grnNo,
        "do_not_submit": doNotSubmit,
        "bill_date": billDate,
      };

      if (fileBase64 != null && fileBase64.isNotEmpty) {
        requestData["supplier_invoice_file"] = fileBase64;
        requestData["supplier_invoice_filename"] = fileName ?? "invoice.png";
      }

      final response = await dio.post(
        'techsavanna_pos.api.purchase.create_purchase_invoice_from_grn',
        data: requestData,
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data != null && data['message'] != null) {
        final message = data['message'];
        if (message is Map<String, dynamic> && message['status'] == 'error') {
          throw Exception(message['message'] ?? 'Failed to create invoice');
        }
      }
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to create purchase invoice: ${e.toString()}');
    }
  }

  Future<PayPurchaseInvoiceResponse> payPurchaseInvoice({
    required PayPurchaseInvoiceRequest request,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.purchase.pay_purchase_invoice',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data != null && data['message'] != null) {
        final message = data['message'];
        if (message is Map<String, dynamic> && message['status'] == 'error') {
          throw Exception(
            message['message'] ?? 'Failed to pay purchase invoice',
          );
        }
      }

      return PayPurchaseInvoiceResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to pay purchase invoice: ${e.toString()}');
    }
  }

  Future<CreatePurchaseOrderResponse> createPurchaseOrder({
    required CreatePurchaseOrderRequest request,
  }) async {
    //debugPrint('Creating purchase order with data: ${jsonEncode(request.toJson())}',);

    try {
      final response = await dio.post(
        'techsavanna_pos.api.purchase.create_purchase_order',
        data: request.toJson(),
      );

      //debugPrint('Purchase order response: ${jsonEncode(response.data)}');

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
        final messageData = data['message'];
        if (messageData['status'] == 'error') {
          throw Exception(
            messageData['message'] ?? 'Unknown error from server',
          );
        }
      }

      return CreatePurchaseOrderResponse.fromJson(data);
    } on DioException catch (e) {
      //debugPrint('Dio error creating purchase order: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      //debugPrint('Error creating purchase order: $e');
      throw Exception('Failed to create purchase order: ${e.toString()}');
    }
  }

  Future<CreateSupplierGroupResponse> createSupplierGroup(
    CreateSupplierGroupRequest request,
  ) async {
    //debugPrint('Creating supplier group: ${request.supplierGroupName}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.supplier_api.create_supplier_group',
        data: request.toJson(),
      );

      //debugPrint(response.toString());

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
      throw Exception(getErrorMessage(e));
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
    //debugPrint('Fetching suppliers with parameters:');
    //debugPrint('searchTerm: $searchTerm');
    //debugPrint('supplierGroup: $supplierGroup');
    //debugPrint('company: $company');
    //debugPrint('limit: $limit');
    //debugPrint('offset: $offset');
    //debugPrint('supplierType: $supplierType');
    //debugPrint('country: $country');
    //debugPrint('disabled: $disabled');

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

      //debugPrint('Suppliers response: ${jsonEncode(response.data)}');

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
      //debugPrint('Dio error fetching suppliers: ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      //debugPrint('Error fetching suppliers: $e');
      throw Exception('Failed to fetch suppliers: ${e.toString()}');
    }
  }
}
