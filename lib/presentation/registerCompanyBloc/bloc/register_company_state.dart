part of 'register_company_bloc.dart';

@immutable
sealed class RegisterCompanyState {}

final class RegisterCompanyInitial extends RegisterCompanyState {}

final class RegisterCompanyLoading extends RegisterCompanyState {}

final class RegisterCompanySuccess extends RegisterCompanyState {}

final class RegisterCompanyFailure extends RegisterCompanyState {
  final String error;
  
  RegisterCompanyFailure({required this.error});
}