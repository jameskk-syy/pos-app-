import 'package:pos/domain/requests/crm/assign_loyalty_program_request.dart';
import 'package:pos/domain/requests/sales/create_customer.dart';
import 'package:pos/domain/requests/finance/customer_credit.dart';
import 'package:pos/domain/requests/sales/get_customer_request.dart';
import 'package:pos/domain/requests/crm/loyalty_history_models.dart';
import 'package:pos/domain/requests/sales/update_customer_request.dart';
import 'package:pos/domain/responses/crm/assign_loyalty_program_response.dart';
import 'package:pos/domain/responses/sales/create_customer.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/domain/responses/finance/customer_credit.dart';
import 'package:pos/domain/responses/crm/loyalty_response.dart';
import 'package:pos/domain/responses/sales/update_customer_response.dart';

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
  Future<UpdateCreditLimitResponse> updateCreditLimit(
    UpdateCreditLimitRequest request,
  );
  Future<LoyaltyBalanceResponse> getLoyaltyBalance(
    String customerId, {
    double? invoiceAmount,
    String? company,
  });

  Future<RedeemPointsResponse> redeemPoints(RedeemPointsRequest request);
  Future<EarnLoyaltyPointsResponse> earnLoyaltyPoints(
    EarnLoyaltyPointsRequest request,
  );
  Future<LoyaltyHistoryResponse> getLoyaltyHistory(
    LoyaltyHistoryRequest request,
  );
}
