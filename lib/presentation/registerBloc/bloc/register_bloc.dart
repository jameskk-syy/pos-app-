import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/models/message.dart';
import 'package:pos/domain/requests/register_user.dart';
import 'package:pos/domain/repository/register_user_repo.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository registerRepository;

  RegisterBloc({required this.registerRepository}) : super(RegisterInitial()) {
    on<RegisterUser>(_onRegisterUser);
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      final Message response = await registerRepository.registerUser(
        event.registerRequest,
      );
      emit(RegisterSuccess(response));
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
