part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class LoginUser extends LoginEvent {
  final LoginRequest loginRequest;

  LoginUser({required this.loginRequest});
}

class ChangePassword extends LoginEvent {
  final String oldPassword;
  final String newPassword;

  ChangePassword({required this.oldPassword, required this.newPassword});
}
