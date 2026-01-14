import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/crm_repo.dart';
import 'package:pos/domain/requests/assign_loyalty_program_request.dart';
import 'package:pos/domain/requests/create_customer.dart';
import 'package:pos/domain/requests/customer_credit.dart';
import 'package:pos/domain/requests/get_customer_request.dart';
import 'package:pos/domain/requests/loyalty_history_models.dart';
import 'package:pos/domain/requests/update_customer_request.dart';
import 'package:pos/domain/responses/assign_loyalty_program_response.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/domain/responses/customer_credit.dart';
import 'package:pos/domain/responses/loyalty_response.dart';
import 'package:pos/domain/responses/update_customer_response.dart';

part 'crm_event.dart';
part 'crm_state.dart';

class CrmBloc extends Bloc<CrmEvent, CrmState> {
  final CrmRepo crmRepo;
  CrmBloc({required this.crmRepo}) : super(CrmInitial()) {
    on<CrmEvent>((event, emit) {});
    on<GetAllCustomers>(_getAllCustomers);
    on<CreateCustomer>(_createCustomer);
     on<UpdateCreditLimit>(_updateCreditLimit);
     on<UpdateCustomer>(_updateCustomer);
     on<AssignLoyaltyProgram>(_assignLoyaltyProgram);
       on<GetLoyaltyBalance>(_getLoyaltyBalance);
    on<RedeemPoints>(_redeemPoints);
     on<GetLoyaltyHistory>(_getLoyaltyHistory);
  }
    Future<void> _getLoyaltyHistory(
    GetLoyaltyHistory event,
    Emitter<CrmState> emit,
  ) async {
    debugPrint("Getting loyalty history for customer: ${event.customerId}");
    emit(LoyaltyHistoryLoading());
    try {
      final request = LoyaltyHistoryRequest(
        customerId: event.customerId,
        page: event.page,
        limit: event.limit,
        transactionType: event.transactionType,
      );
      final response = await crmRepo.getLoyaltyHistory(request);
      emit(LoyaltyHistoryLoaded(
        historyResponse: response,
        transactions: response.transactions,
      ));
    } catch (e) {
      debugPrint('Error getting loyalty history: $e');
      emit(LoyaltyHistoryError(error: e.toString()));
    }
  }
   Future<void> _getLoyaltyBalance(
    GetLoyaltyBalance event,
    Emitter<CrmState> emit,
  ) async {
    debugPrint("Getting loyalty balance for customer: ${event.customerId}");
    emit(LoyaltyLoading());
    try {
      final response = await crmRepo.getLoyaltyBalance(event.customerId);
      emit(LoyaltyBalanceLoaded(balanceResponse: response));
    } catch (e) {
      debugPrint('Error getting loyalty balance: $e');
      emit(LoyaltyError(error: e.toString()));
    }
  }
  
  Future<void> _redeemPoints(
    RedeemPoints event,
    Emitter<CrmState> emit,
  ) async {
    debugPrint("Redeeming ${event.pointsToRedeem} points for customer: ${event.customerId}");
    emit(LoyaltyLoading());
    try {
      final request = RedeemPointsRequest(
        customerId: event.customerId,
        pointsToRedeem: event.pointsToRedeem,
      );
      final response = await crmRepo.redeemPoints(request);
      emit(PointsRedeemSuccess(redeemResponse: response));
    } catch (e) {
      debugPrint('Error redeeming points: $e');
      emit(LoyaltyError(error: e.toString()));
    }
  }
  Future<void> _assignLoyaltyProgram(
    AssignLoyaltyProgram event,
    Emitter<CrmState> emit,
  ) async {
    debugPrint("Assigning loyalty program");
    emit(AssignLoyaltyProgramLoading());
    try {
      final response = await crmRepo.assignLoyaltyProgram(event.request);
      emit(AssignLoyaltyProgramSuccess(response: response));
    } catch (e) {
      debugPrint('Error assigning loyalty program: $e');
      emit(AssignLoyaltyProgramError(error: e.toString()));
    }
  }
  Future<void> _updateCustomer(
    UpdateCustomer event,
    Emitter<CrmState> emit,
  ) async {
    emit(CrmStateLoading());
    try {
      final response = await crmRepo.updateCustomer(
        updateRequest: event.updateRequest,
        customerId: event.customerId,
      );
      emit(UpdateCustomerSuccess(response: response));
    } catch (e) {
      emit(CrmStateFailure(error: e.toString()));
      debugPrint(e.toString());
    }
  }

  Future<void> _getAllCustomers(
    GetAllCustomers event,
    Emitter<CrmState> emit,
  ) async {
    emit(CrmStateLoading());
    try {
      final response = await crmRepo.getAllCustomers(event.custmoerRequest);
      emit(CrmStateSuccess(customerResponse: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(CrmStateFailure(error: e.toString()));
    }
  }
   Future<void> _updateCreditLimit(
    UpdateCreditLimit event,
    Emitter<CrmState> emit,
  ) async {
    emit(CrmStateLoading());
    try {
      final response =
          await crmRepo.updateCreditLimit(event.request);
      emit(UpdateCreditLimitSuccess(response: response));
    } catch (e) {
      emit(CrmStateFailure(error: e.toString()));
    }
  }

  Future<void> _createCustomer(
    CreateCustomer event,
    Emitter<CrmState> emit,
  ) async {
    debugPrint("clicking");
    emit(CrmStateLoading());
    try {
      await crmRepo.createCustomer(event.completeCustomerequest);
      emit(CrmStateSuccessful());
    } catch (e) {
      emit(CrmStateFailure(error: e.toString()));
      debugPrint(e.toString());
    }
  }
}
