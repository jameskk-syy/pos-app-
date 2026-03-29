part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent {}

class RequestOtp extends ForgotPasswordEvent {
  final String email;
  RequestOtp({required this.email});
}

class VerifyOtp extends ForgotPasswordEvent {
  final String email;
  final String code;
  VerifyOtp({required this.email, required this.code});
}

class ResetPassword extends ForgotPasswordEvent {
  final String email;
  final String newPassword;
  ResetPassword({required this.email, required this.newPassword});
}
