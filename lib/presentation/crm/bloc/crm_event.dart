part of 'crm_bloc.dart';

@immutable
sealed class CrmEvent {}

class GetAllCustomers extends CrmEvent {
  final CustomerRequest custmoerRequest;

  GetAllCustomers({required this.custmoerRequest});
}

class CreateCustomer extends CrmEvent {
  final CompleteCustomerRequest completeCustomerequest;

  CreateCustomer({required this.completeCustomerequest});
}

class UpdateCreditLimit extends CrmEvent {
  final UpdateCreditLimitRequest request;

  UpdateCreditLimit({required this.request});
}
final class UpdateCustomer extends CrmEvent {
  final UpdateCustomerRequest updateRequest;
  final String customerId;

  UpdateCustomer({
    required this.updateRequest,
    required this.customerId,
  });
  
}
final class AssignLoyaltyProgram extends CrmEvent {
  final AssignLoyaltyProgramRequest request;

  AssignLoyaltyProgram({required this.request});
}
final class GetLoyaltyBalance extends CrmEvent {
  final String customerId;

  GetLoyaltyBalance({required this.customerId});
}

final class RedeemPoints extends CrmEvent {
  final String customerId;
  final double pointsToRedeem;
  final String? referenceDocument;

  RedeemPoints({
    required this.customerId,
    required this.pointsToRedeem,
    this.referenceDocument,
  });
}
class GetLoyaltyHistory extends CrmEvent {
  final String customerId;
  final int page;
  final int limit;
  final String? transactionType;

  GetLoyaltyHistory({
    required this.customerId,
    this.page = 1,
    this.limit = 50,
    this.transactionType,
  });
}
