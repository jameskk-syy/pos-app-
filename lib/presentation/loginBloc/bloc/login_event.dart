part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class LoginUser extends LoginEvent {
  final LoginRequest loginRequest;

  LoginUser({required this.loginRequest});
}
