part of 'industries_bloc.dart';

@immutable
sealed class IndustriesState {}

final class IndustriesInitial extends IndustriesState {}

class IndustriesLoading extends IndustriesState {}

class IndustriesSuccess extends IndustriesState {
  final IndustriesResponse message;

  IndustriesSuccess(this.message);
}

class IndustriesSeedProductSuccess extends IndustriesState {
  final ProcessResponse  message;

  IndustriesSeedProductSuccess(this.message);
}

class IndustriesSeedItemState extends IndustriesState {
  final CreateOrderResponse createOrderResponse;

  IndustriesSeedItemState({required this.createOrderResponse});
}

class IndustriesFailure extends IndustriesState {
  final String error;

  IndustriesFailure(this.error);
}
