part of 'warehouse_cubit.dart';

abstract class WarehouseState {}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoading extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final Warehouse? warehouse;

  WarehouseLoaded(this.warehouse);
}

class WarehouseError extends WarehouseState {
  final String message;

  WarehouseError(this.message);
}
