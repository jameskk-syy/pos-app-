part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterUser extends RegisterEvent {
  final RegisterRequest registerRequest;
  final String businessName;

  RegisterUser({required this.registerRequest, required this.businessName});
}
