import 'package:flutter/foundation.dart';

@immutable
sealed class PriceState {}

final class PriceInitial extends PriceState {}

final class PriceLoading extends PriceState {}

final class PriceSuccess extends PriceState {
  final String message;
  PriceSuccess(this.message);
}

final class PriceFailure extends PriceState {
  final String error;
  PriceFailure(this.error);
}
