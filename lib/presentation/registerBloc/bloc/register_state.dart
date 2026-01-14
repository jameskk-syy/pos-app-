part of 'register_bloc.dart';

@immutable
abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final Message message;

  RegisterSuccess(this.message);
}

class RegisterFailure extends RegisterState {
  final String error;

  RegisterFailure(this.error);
}
