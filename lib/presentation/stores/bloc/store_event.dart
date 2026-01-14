part of 'store_bloc.dart';

@immutable
sealed class StoreEvent {}

class GetAllStores extends StoreEvent {
  final String company;
  final int limit;
  final int offset;

  GetAllStores({required this.company, this.limit = 20, this.offset = 0});
}

class Createwarehouse extends StoreEvent {
  final CreateWarehouseRequest createWarehouseRequest;

  Createwarehouse({required this.createWarehouseRequest});
}

class UpdateWarehouse extends StoreEvent {
  final UpdateWarehouseRequest updateWarehouseRequest;

  UpdateWarehouse({required this.updateWarehouseRequest});
}
