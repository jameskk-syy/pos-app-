part of 'subdomain_bloc.dart';

@immutable
abstract class SubdomainEvent {}

class ValidateSubdomain extends SubdomainEvent {
  final String slug;

  ValidateSubdomain({required this.slug});
}
