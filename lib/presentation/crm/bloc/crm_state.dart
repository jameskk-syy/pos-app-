part of 'crm_bloc.dart';

@immutable
sealed class CrmState {}

final class CrmInitial extends CrmState {}

final class CrmStateLoading extends CrmState {}

final class CrmStateSuccessful extends CrmState {}

final class CrmStateSuccess extends CrmState {
  final CustomerResponse customerResponse;

  CrmStateSuccess({required this.customerResponse});
}

final class CrmStateFailure extends CrmState {
  final String error;

  CrmStateFailure({required this.error});
}
// crm_state.dart
final class UpdateCreditLimitSuccess extends CrmState {
  final UpdateCreditLimitResponse response;

  UpdateCreditLimitSuccess({required this.response});
}
final class UpdateCustomerSuccess extends CrmState {
  final UpdateCustomerResponse response;

  UpdateCustomerSuccess({required this.response});
}
final class AssignLoyaltyProgramLoading extends CrmState {}

final class AssignLoyaltyProgramSuccess extends CrmState {
  final AssignLoyaltyProgramResponse response;

  AssignLoyaltyProgramSuccess({required this.response});
}

final class AssignLoyaltyProgramError extends CrmState {
  final String error;

  AssignLoyaltyProgramError({required this.error});
}
final class LoyaltyLoading extends CrmState {}

final class LoyaltyBalanceLoaded extends CrmState {
  final LoyaltyBalanceResponse balanceResponse;
  LoyaltyBalanceLoaded({required this.balanceResponse});
}

final class PointsRedeemSuccess extends CrmState {
  final RedeemPointsResponse redeemResponse;
  PointsRedeemSuccess({required this.redeemResponse});
}

final class LoyaltyError extends CrmState {
  final String error;
  LoyaltyError({required this.error});
}
final class LoyaltyHistoryLoading extends CrmState {}

final class LoyaltyHistoryLoaded extends CrmState {
  final LoyaltyHistoryResponse historyResponse;
  final List<LoyaltyHistoryTransaction> transactions;
  
  LoyaltyHistoryLoaded({
    required this.historyResponse,
    required this.transactions,
  });
}

final class LoyaltyHistoryError extends CrmState {
  final String error;
  LoyaltyHistoryError({required this.error});
}
