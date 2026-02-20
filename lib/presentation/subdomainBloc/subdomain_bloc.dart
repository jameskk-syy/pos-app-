import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/models/subdomain_response.dart';
import 'package:pos/domain/repository/subdomain_repository.dart';

part 'subdomain_event.dart';
part 'subdomain_state.dart';

class SubdomainBloc extends Bloc<SubdomainEvent, SubdomainState> {
  final SubdomainRepository subdomainRepository;

  SubdomainBloc({required this.subdomainRepository})
    : super(SubdomainInitial()) {
    on<ValidateSubdomain>(_onValidateSubdomain);
  }

  Future<void> _onValidateSubdomain(
    ValidateSubdomain event,
    Emitter<SubdomainState> emit,
  ) async {
    emit(SubdomainLoading());
    try {
      final response = await subdomainRepository.validateSubdomain(event.slug);
      emit(SubdomainSuccess(response: response));
    } catch (e) {
      emit(SubdomainFailure(error: e.toString()));
    }
  }
}
