import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/crm_repo.dart';
import 'package:pos/domain/requests/assign_loyalty_program_request.dart';
import 'package:pos/domain/requests/create_customer.dart';
import 'package:pos/domain/requests/customer_credit.dart';
import 'package:pos/domain/requests/get_customer_request.dart';
import 'package:pos/domain/requests/loyalty_history_models.dart';
import 'package:pos/domain/requests/update_customer_request.dart';
import 'package:pos/domain/responses/assign_loyalty_program_response.dart';
import 'package:pos/domain/responses/create_customer.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/domain/responses/customer_credit.dart';
import 'package:pos/domain/responses/loyalty_response.dart';
import 'package:pos/domain/responses/update_customer_response.dart';

class CrmRepoImpl implements CrmRepo {
  final RemoteDataSource remoteDataSource;

  CrmRepoImpl({required this.remoteDataSource});
  @override
  Future<CustomerResponse> getAllCustomers(CustomerRequest request) async {
    try {
      final result = await remoteDataSource.getAllCustomers(request);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreateCustomerResponse> createCustomer(
    CompleteCustomerRequest customer,
  ) async {
    return await remoteDataSource.createCustomer(customer);
  }

  @override
  Future<UpdateCreditLimitResponse> updateCreditLimit(
    UpdateCreditLimitRequest request,
  ) async {
    return await remoteDataSource.updateCreditLimit(request);
  }

  @override
  Future<UpdateCustomerResponse> updateCustomer({
    required UpdateCustomerRequest updateRequest,
    required String customerId,
  }) async {
    return await remoteDataSource.updateCustomer(
      updateRequest: updateRequest,
      customerId: customerId,
    );
  }

  @override
  Future<AssignLoyaltyProgramResponse> assignLoyaltyProgram(
    AssignLoyaltyProgramRequest request,
  ) async {
    return await remoteDataSource.assignLoyaltyProgram(request);
  }

  @override
  Future<LoyaltyBalanceResponse> getLoyaltyBalance(String customerId) async {
    return await remoteDataSource.getLoyaltyBalance(customerId);
  }

  @override
  Future<RedeemPointsResponse> redeemPoints(RedeemPointsRequest request) async {
    return await remoteDataSource.redeemPoints(request);
  }

  @override
  Future<LoyaltyHistoryResponse> getLoyaltyHistory(
    LoyaltyHistoryRequest request,
  ) async {
    return await remoteDataSource.getLoyaltyHistory(request);
  }
}
