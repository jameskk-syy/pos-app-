import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/authenticating_user_repo.dart';
import 'package:pos/domain/requests/login.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticateUserRepo authenticateUserRepo;
  LoginBloc({required this.authenticateUserRepo}) : super(LoginInitial()) {
    on<LoginEvent>((event, emit) {});
    on<LoginUser>(_loginUser);
  }

  Future<void> _loginUser(LoginUser event, Emitter<LoginState> emit) async {
    emit(LoginUserLoading());
    try {
      final response = await authenticateUserRepo.login(event.loginRequest);
      debugPrint(response.toString());
      emit(LoginUserSuccess());
    } catch (e) {
      emit(LoginUserFailure(error: e.toString()));
      debugPrintStack(label: e.toString());
    }
  }
}
