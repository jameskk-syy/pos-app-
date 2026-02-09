import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/authenticating_user_repo.dart';
import 'package:pos/domain/requests/users/login.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticateUserRepo authenticateUserRepo;
  LoginBloc({required this.authenticateUserRepo}) : super(LoginInitial()) {
    on<LoginEvent>((event, emit) {});
    on<LoginUser>(_loginUser);
    on<ChangePassword>(_changePassword);
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

  Future<void> _changePassword(
    ChangePassword event,
    Emitter<LoginState> emit,
  ) async {
    emit(ChangePasswordLoading());
    try {
      final response = await authenticateUserRepo.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );

      // response format according to user: {"message":{"message":"Password changed successfully"}}
      String message = 'Password changed successfully';
      if (response['message'] != null && response['message'] is Map) {
        message = response['message']['message'] ?? message;
      }

      emit(ChangePasswordSuccess(message: message));
    } catch (e) {
      emit(ChangePasswordFailure(error: e.toString()));
    }
  }
}
