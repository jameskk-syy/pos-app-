part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class SendOtpLoading extends ForgotPasswordState {}

class SendOtpSuccess extends ForgotPasswordState {
  final String message;
  SendOtpSuccess({required this.message});
}

class SendOtpFailure extends ForgotPasswordState {
  final String error;
  SendOtpFailure({required this.error});
}

class VerifyOtpLoading extends ForgotPasswordState {}

class VerifyOtpSuccess extends ForgotPasswordState {
  final String message;
  VerifyOtpSuccess({required this.message});
}

class VerifyOtpFailure extends ForgotPasswordState {
  final String error;
  VerifyOtpFailure({required this.error});
}

class ResetPasswordLoading extends ForgotPasswordState {}

class ResetPasswordSuccess extends ForgotPasswordState {
  final String message;
  ResetPasswordSuccess({required this.message});
}

class ResetPasswordFailure extends ForgotPasswordState {
  final String error;
  ResetPasswordFailure({required this.error});
}
