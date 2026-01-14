part of 'industries_bloc.dart';

@immutable
sealed class IndustriesEvent {}

class GetIndustriesList extends IndustriesEvent {}

class SeedProducts extends IndustriesEvent {
  final String industry;

  SeedProducts({required this.industry});
}
class SeedItems extends IndustriesEvent {
  final CreateOrderRequest createOrderRequest;

  SeedItems({required this.createOrderRequest});

}

