part of 'subdomain_bloc.dart';

@immutable
abstract class SubdomainState {}

class SubdomainInitial extends SubdomainState {}

class SubdomainLoading extends SubdomainState {}

class SubdomainSuccess extends SubdomainState {
  final SubdomainResponse response;

  SubdomainSuccess({required this.response});
}

class SubdomainFailure extends SubdomainState {
  final String error;

  SubdomainFailure({required this.error});
}
