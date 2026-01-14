import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/register_company_repo.dart';
import 'package:pos/domain/requests/register_company.dart';

part 'register_company_event.dart';
part 'register_company_state.dart';

class RegisterCompanyBloc
    extends Bloc<RegisterCompanyEvent, RegisterCompanyState> {
  final RegisterCompanyRepo registerCompanyRepo;
  RegisterCompanyBloc({required this.registerCompanyRepo})
    : super(RegisterCompanyInitial()) {
    on<RegisterCompanyEvent>((event, emit) {});
    on<RegisterCompanyEventIntial>(_createCompany);
  }

  Future<void> _createCompany(
    RegisterCompanyEventIntial event,
    Emitter<RegisterCompanyState> emit,
  ) async {
    emit(RegisterCompanyLoading());

    try {
      final response = await registerCompanyRepo.registerCompany(
        event.companyRequest,
      );
      debugPrint('REGISTER RESPONSE => $response');
      emit(RegisterCompanySuccess());
    } catch (e) {
      emit(RegisterCompanyFailure(error: e.toString()));
    }
  }
}
