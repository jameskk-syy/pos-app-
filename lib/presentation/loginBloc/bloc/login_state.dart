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
