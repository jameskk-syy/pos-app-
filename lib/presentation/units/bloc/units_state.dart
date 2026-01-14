part of 'units_bloc.dart';

@immutable
sealed class UnitsState {}

final class UnitsInitial extends UnitsState {}

final class UnitsLoading extends UnitsState {}

final class UnitsLoaded extends UnitsState {
  final List<UOM> uoms;
  final List<UOM> filteredUoms;

  UnitsLoaded({required this.uoms, required this.filteredUoms});
}

final class UnitsActionSuccess extends UnitsState {
  final String message;

  UnitsActionSuccess(this.message);
}

final class UnitsError extends UnitsState {
  final String message;

  UnitsError(this.message);
}
