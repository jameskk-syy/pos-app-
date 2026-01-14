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

abstract class CrmRepo {
  Future<CustomerResponse> getAllCustomers(CustomerRequest customerRequest);
  Future<CreateCustomerResponse> createCustomer(
    CompleteCustomerRequest customer,
  );
   Future<UpdateCustomerResponse> updateCustomer({
    required UpdateCustomerRequest updateRequest,
    required String customerId,
  });
  
  Future<AssignLoyaltyProgramResponse> assignLoyaltyProgram(
    AssignLoyaltyProgramRequest request,
  );
  Future<UpdateCreditLimitResponse > updateCreditLimit(UpdateCreditLimitRequest request);
    Future<LoyaltyBalanceResponse> getLoyaltyBalance(String customerId);
  
  Future<RedeemPointsResponse> redeemPoints(RedeemPointsRequest request);
    Future<LoyaltyHistoryResponse> getLoyaltyHistory(LoyaltyHistoryRequest request);
}
