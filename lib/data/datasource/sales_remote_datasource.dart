import 'dart:convert';
import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/invoice_model_get.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/models/pos_session_model.dart';
import 'package:pos/domain/models/pos_opening_entry_model.dart';
import 'package:pos/domain/requests/sales/dashboard_request.dart';
import 'package:pos/domain/responses/sales/dashboard_response.dart';
import 'package:pos/core/services/storage_service.dart';

class SalesRemoteDataSource extends BaseRemoteDataSource {
  final StorageService storageService;
  SalesRemoteDataSource(super.dio, this.storageService);

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
      // debugPrint("Create POS Session API Response: ${response.statusCode}");
      // debugPrint("Response Data: ${jsonEncode(data)}");

      // Validate response structure
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        // debugPrint('Response type: ${data.runtimeType}');
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

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

      final session = POSSessionResponse.fromJson(sessionData);

      await storageService.setString(
        'current_session',
        jsonEncode(sessionData),
      );

      return session;
    } on DioException catch (e) {
      // debugPrint('Dio Error: ${e.type} - ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      // debugPrint('Unexpected error: $e');
      // debugPrint('Stack trace: $stackTrace');
      rethrow;
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
      // debugPrint("Get Sales Invoice API Response: ${response.statusCode}");
      // debugPrint("Response Data: ${jsonEncode(data)}");

      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        final error = data['error'];
        throw Exception(error.toString());
      }

      return GetSalesInvoiceResponse.fromJson(data);
    } on DioException catch (e) {
      // debugPrint('Dio Error: ${e.type} - ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      // debugPrint('Unexpected error: $e');
      // debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<CreateInvoiceResponse> createInvoice(InvoiceRequest request) async {
    try {
      // final payload = request.toJson();
      // debugPrint('--- CREATE INVOICE PAYLOAD START ---');
      // debugPrint(const JsonEncoder.withIndent('  ').convert(payload));
      // debugPrint('--- CREATE INVOICE PAYLOAD END ---');

      final response = await dio.post(
        'techsavanna_pos.api.sales_api.create_pos_invoice',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("Create Invoice API Response: ${response.statusCode}");
      // debugPrint("Response Data: ${jsonEncode(data)}");
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        // debugPrint('Response type: ${data.runtimeType}');
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
      // debugPrint('Dio Error: ${e.type} - ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      // debugPrint('Unexpected error: $e');
      // debugPrint('Stack trace: $stackTrace');
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
      // debugPrint("Payment Methods API Response: ${response.statusCode}");
      // debugPrint("Response Data: ${jsonEncode(data)}");

      // Validate response structure
      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data is! Map<String, dynamic>) {
        // debugPrint('Response type: ${data.runtimeType}');
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
      await storageService.setString('payment_methods_data', jsonEncode(data));

      return paymentMethods;
    } on DioException catch (e) {
      // debugPrint('Dio Error: ${e.type} - ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      // debugPrint('Unexpected error: $e');
      // debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<DashboardResponse> getDashboardData(DashboardRequest request) async {
    // debugPrint("Request Data: ${jsonEncode(request.toJson())}");
    try {
      final response = await dio.post(
        'techsavanna_pos.api.dashboard_api.get_dashboard_metrics',
        data: request.toJson(),
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
        // debugPrint('Response type: ${data.runtimeType}');
        throw Exception(
          'Response is not a valid JSON object. Type: ${data.runtimeType}',
        );
      }

      // FIX: Check if response is wrapped in "message" key
      Map<String, dynamic> actualData = data;
      if (data.containsKey('message') &&
          data['message'] is Map<String, dynamic>) {
        // debugPrint('Response wrapped in "message" key, unwrapping...');
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
        // debugPrint('Data type: ${dashboardData.runtimeType}');
        throw Exception(
          'Data field is not a valid object. Type: ${dashboardData.runtimeType}',
        );
      }

      // Save the actual data (not the wrapper)
      await storageService.setString('dashboardData', jsonEncode(actualData));
      // debugPrint('Dashboard data saved to local storage');

      // Note: getCurrentUser() is in UserRemoteDataSource/AuthRemoteDataSource.
      // Avoiding circular dependency/unnecessary call here if not strictly needed or move it.
      // If needed, we might need to inject AuthRemoteDataSource or duplicate logic.
      // For now, removing the call as it might be side-effect of original code.
      // await getCurrentUser();

      // Parse the actual data
      return DashboardResponse.fromJson(actualData);
    } on DioException catch (e) {
      // debugPrint('Dio Error: ${e.type} - ${e.message}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      // debugPrint('Unexpected error: $e');
      // debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<InvoiceListResponse> listSalesInvoices({
    required String company,
    int limit = 20,
    int offset = 0,
    String? customer,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      final queryParams = {
        'company': company,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (customer != null) queryParams['customer'] = customer;
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;
      if (status != null && status != 'All') queryParams['status'] = status;

      final response = await dio.get(
        'techsavanna_pos.api.sales_api.list_sales_invoices',
        queryParameters: queryParams,
      );

      return InvoiceListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<InvoiceListResponse> listPosInvoices({
    required String company,
    int limit = 20,
    int offset = 0,
    String? customer,
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    try {
      final queryParams = {
        'company': company,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (customer != null) queryParams['customer'] = customer;
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;
      if (status != null && status != 'All') queryParams['status'] = status;

      final response = await dio.get(
        'techsavanna_pos.api.sales_api.list_pos_invoices',
        queryParameters: queryParams,
      );

      return InvoiceListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
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

      // debugPrint('ClosePOSSession Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is String) {
          return ClosePOSSessionResponse.fromJson(jsonDecode(response.data));
        }
        return ClosePOSSessionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to close POS session');
      }
    } catch (e) {
      // debugPrint('Error closing POS session: $e');
      throw Exception('Failed to close POS session: $e');
    }
  }

  Future<PosOpeningEntryResponse> listPosOpeningEntries({
    required String company,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.sales_api.list_pos_opening_entries',
        queryParameters: {
          'company': company,
          'limit_start': offset,
          'limit_page_length': limit,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Invalid response from server');
      }

      return PosOpeningEntryResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to list POS opening entries: $e');
    }
  }

  Future<ClosePosOpeningEntryResponse> closePosOpeningEntry({
    required String posOpeningEntry,
    bool doNotSubmit = false,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.sales_api.close_pos_opening_entry',
        data: {
          'pos_opening_entry': posOpeningEntry,
          'do_not_submit': doNotSubmit,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Invalid response from server');
      }

      return ClosePosOpeningEntryResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to close POS opening entry: $e');
    }
  }

  Future<Map<String, dynamic>> createCreditModeOfPayment({
    required Map<String, dynamic> request,
  }) async {
    // debugPrint('Creating credit mode of payment: $request');
    try {
      final response = await dio.post(
        'techsavanna_pos.api.sales_api.create_credit_mode_of_payment',
        data: request,
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      // debugPrint("Create Credit MOP Response: ${response.toString()}");

      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') &&
            data['message'] is Map<String, dynamic>) {
          return data['message'];
        }
        return data;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      // debugPrint('Create Credit MOP Error: $e');
      throw Exception('Failed to create credit MOP: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReceivableAccount({
    required String customer,
    required String company,
  }) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.sales_api.get_receivable_account',
        queryParameters: {'customer': customer, 'company': company},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'];
      }
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      // debugPrint('Get Receivable Account Error: $e');
      throw Exception('Failed to get receivable account: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
