part of 'store_bloc.dart';

@immutable
sealed class StoreState {}

final class StoreInitial extends StoreState {}

final class StoreStateLoading extends StoreState {}
final class StoreSuccessfulState extends StoreState {}
final class StoreStateSuccess extends StoreState {
  final StoreGetResponse storeGetResponse;

  StoreStateSuccess({required this.storeGetResponse});
}

final class StoreStateFailure extends StoreState {
  final String error;

  StoreStateFailure({required this.error});
}

final class StoreUpdateSuccessState extends StoreState {}
