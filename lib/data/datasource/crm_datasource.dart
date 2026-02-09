import 'package:dio/dio.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/requests/sales/create_customer.dart';
import 'package:pos/domain/requests/sales/update_customer_request.dart';
import 'package:pos/domain/requests/finance/customer_credit.dart';
import 'package:pos/domain/requests/crm/assign_loyalty_program_request.dart';
import 'package:pos/domain/requests/crm/create_loyalty_program_request.dart';
import 'package:pos/domain/requests/crm/get_loyalty_programs_request.dart';
import 'package:pos/domain/requests/crm/loyalty_history_models.dart';
import 'package:pos/domain/responses/sales/create_customer.dart';
import 'package:pos/domain/responses/sales/update_customer_response.dart';
import 'package:pos/domain/responses/finance/customer_credit.dart';
import 'package:pos/domain/responses/crm/loyalty_response.dart';
import 'package:pos/domain/responses/crm/assign_loyalty_program_response.dart';
import 'package:pos/domain/responses/crm/create_loyalty_program_response.dart';
import 'package:pos/domain/responses/crm/get_loyalty_programs_response.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/domain/requests/sales/get_customer_request.dart';

class CrmRemoteDataSource extends BaseRemoteDataSource {
  CrmRemoteDataSource(super.dio);

  Future<CustomerResponse> getAllCustomers(CustomerRequest request) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.customer_api.list_customers',
        queryParameters: request.toJson(),
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

      return CustomerResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateCustomerResponse> createCustomer(
    CompleteCustomerRequest customer,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.customer_api.create_customer',
        data: customer.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is Map<String, dynamic> && message['success'] == false) {
        throw Exception(message['message'] ?? 'Failed to create customer');
      }

      return CreateCustomerResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
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
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is Map<String, dynamic> && message['success'] == false) {
        throw Exception(message['message'] ?? 'Failed to update customer');
      }

      return UpdateCustomerResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateCreditLimitResponse> updateCreditLimit(
    UpdateCreditLimitRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.customer_api.set_customer_credit_limit',
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      return UpdateCreditLimitResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<LoyaltyBalanceResponse> getLoyaltyBalance(
    String customerId, {
    double? invoiceAmount,
    String? company,
  }) async {
    try {
      final queryParams = {
        'customer_id': customerId,
        'invoice_amount': invoiceAmount ?? 0,
      };
      if (company != null) {
        queryParams['company'] = company;
      }

      final response = await dio.get(
        'techsavanna_pos.api.loyalty.get_customer_loyalty_details',
        queryParameters: queryParams,
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return LoyaltyBalanceResponse.fromJson(message);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
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
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return RedeemPointsResponse.fromJson(message);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<EarnLoyaltyPointsResponse> earnLoyaltyPoints(
    EarnLoyaltyPointsRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.loyalty.earn_loyalty_points',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return EarnLoyaltyPointsResponse.fromJson(message);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
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
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message is! Map<String, dynamic>) {
        throw Exception('Message field is not a valid object');
      }

      return LoyaltyHistoryResponse.fromJson(message);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
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
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return AssignLoyaltyProgramResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateLoyaltyProgramResponse> createLoyaltyProgram(
    CreateLoyaltyProgramRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.loyalty.create_loyalty_program',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateLoyaltyProgramResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<GetLoyaltyProgramsResponse> getLoyaltyPrograms(
    GetLoyaltyProgramsRequest request,
  ) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.loyalty.list_loyalty_programs',
        queryParameters: request.toQueryParams(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return GetLoyaltyProgramsResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }
}
