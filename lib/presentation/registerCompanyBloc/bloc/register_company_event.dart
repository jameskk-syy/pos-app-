part of 'register_company_bloc.dart';

@immutable
sealed class RegisterCompanyEvent {}

class RegisterCompanyEventIntial extends RegisterCompanyEvent {
  final CompanyRequest companyRequest;
  RegisterCompanyEventIntial({required this.companyRequest});
}
