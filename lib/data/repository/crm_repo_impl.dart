import 'package:pos/data/datasource/crm_datasource.dart';
import 'package:pos/domain/repository/crm_repo.dart';
import 'package:pos/domain/requests/crm/assign_loyalty_program_request.dart';
import 'package:pos/domain/requests/sales/create_customer.dart';
import 'package:pos/domain/requests/finance/customer_credit.dart';
import 'package:pos/domain/requests/sales/get_customer_request.dart';
import 'package:pos/domain/requests/crm/loyalty_history_models.dart';
import 'package:pos/domain/requests/sales/update_customer_request.dart';
import 'package:pos/domain/responses/crm/assign_loyalty_program_response.dart'
    hide Customer;
import 'package:pos/domain/responses/sales/create_customer.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/domain/responses/finance/customer_credit.dart';
import 'package:pos/domain/responses/crm/loyalty_response.dart';
import 'package:pos/domain/responses/sales/update_customer_response.dart';
import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';

class CrmRepoImpl implements CrmRepo {
  final CrmRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final LocalDataSource localDataSource;

  CrmRepoImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.localDataSource,
  });

  @override
  Future<CustomerResponse> getAllCustomers(CustomerRequest request) async {
    final isConnected = await connectivityService.checkNow();

    if (isConnected) {
      try {
        final result = await remoteDataSource.getAllCustomers(request);
        // Cache customers for offline use
        final customersData = result.message.data
            .map((c) => c.toJson())
            .toList();
        await localDataSource.cacheCustomers(customersData);
        return result;
      } catch (e) {
        rethrow;
      }
    } else {
      // Offline: Return cached customers
      final cached = localDataSource.getCachedCustomers();
      if (cached.isNotEmpty) {
        final customers = cached.map((c) => Customer.fromJson(c)).toList();
        // Create a response matching the expected structure
        return CustomerResponse(
          message: CrmMessage(
            success: true,
            data: customers,
            count: customers.length,
          ),
        );
      } else {
        throw Exception(
          'No internet connection and no cached customers available.',
        );
      }
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
  Future<LoyaltyBalanceResponse> getLoyaltyBalance(
    String customerId, {
    double? invoiceAmount,
    String? company,
  }) async {
    return await remoteDataSource.getLoyaltyBalance(
      customerId,
      invoiceAmount: invoiceAmount,
      company: company,
    );
  }

  @override
  Future<RedeemPointsResponse> redeemPoints(RedeemPointsRequest request) async {
    return await remoteDataSource.redeemPoints(request);
  }

  @override
  Future<EarnLoyaltyPointsResponse> earnLoyaltyPoints(
    EarnLoyaltyPointsRequest request,
  ) async {
    final isConnected = await connectivityService.checkNow();

    if (isConnected) {
      try {
        return await remoteDataSource.earnLoyaltyPoints(request);
      } catch (e) {
        rethrow;
      }
    } else {
      // Offline: Save for later sync
      await localDataSource.saveOfflineLoyaltyPoints(request.toJson());

      // Return mock success response
      return EarnLoyaltyPointsResponse(
        status: 'success',
        message: 'Loyalty points queued offline. Will sync when online.',
        pointsEarned: 0, // Will be calculated when synced
        totalPoints: 0, // Will be updated when synced
        debug: ['Saved offline'],
      );
    }
  }

  @override
  Future<LoyaltyHistoryResponse> getLoyaltyHistory(
    LoyaltyHistoryRequest request,
  ) async {
    return await remoteDataSource.getLoyaltyHistory(request);
  }
}
