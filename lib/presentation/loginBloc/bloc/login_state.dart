part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginUserLoading extends LoginState {}

final class LoginUserSuccess extends LoginState {}

final class LoginUserFailure extends LoginState {
  final String error;

  LoginUserFailure({required this.error});
}

final class ChangePasswordLoading extends LoginState {}

final class ChangePasswordSuccess extends LoginState {
  final String message;

  ChangePasswordSuccess({required this.message});
}

final class ChangePasswordFailure extends LoginState {
  final String error;

  ChangePasswordFailure({required this.error});
}
