import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/authenticating_user_repo.dart';
import 'package:pos/domain/requests/users/login.dart';
import 'package:pos/domain/requests/users/send_otp_request.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticateUserRepo authenticateUserRepo;
  LoginBloc({required this.authenticateUserRepo}) : super(LoginInitial()) {
    on<LoginEvent>((event, emit) {});
    on<LoginUser>(_loginUser);
    on<ChangePassword>(_changePassword);
    on<VerifyEmailCode>(_verifyEmailCode);
    on<SendOtp>(_sendOtp);
  }

  Future<void> _verifyEmailCode(
    VerifyEmailCode event,
    Emitter<LoginState> emit,
  ) async {
    emit(VerifyEmailCodeLoading());
    try {
      final response = await authenticateUserRepo.verifyEmailCode(
        event.email,
        event.code,
      );

      String message = 'Email verified successfully';
      if (response['message'] != null) {
        if (response['message'] is String) {
          message = response['message'];
        } else if (response['message'] is Map &&
            response['message']['message'] != null) {
          message = response['message']['message'].toString();
        }
      }

      // If successful, we might want to ensure user data is ready or just proceed
      // The UI will handle navigation based on success state

      emit(LoginUserSuccess());
    } catch (e) {
      emit(VerifyEmailCodeFailure(error: e.toString()));
    }
  }

  Future<void> _loginUser(LoginUser event, Emitter<LoginState> emit) async {
    emit(LoginUserLoading());
    try {
      final response = await authenticateUserRepo.login(event.loginRequest);
      debugPrint(response.toString());

      // Save encrypted password for App Lock
      final storageService = getIt<StorageService>();
      await storageService.saveEncryptedPassword(event.loginRequest.password);

      // Send OTP after successful credentials check
      // await authenticateUserRepo.sendOtpEmail(
      //   SendOtpRequest(email: event.loginRequest.email),
      // );

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

  Future<void> _sendOtp(SendOtp event, Emitter<LoginState> emit) async {
    // We could add a SendOtpLoading state if we wanted, but the UI already handles 60s timer
    try {
      await authenticateUserRepo.sendOtpEmail(SendOtpRequest(email: event.email));
    } catch (e) {
      debugPrint("Resend OTP failed: $e");
    }
  }
}
