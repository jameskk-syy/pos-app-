// lib/presentation/suppliers/bloc/suppliers_state.dart
part of 'suppliers_bloc.dart';

@immutable
sealed class SuppliersState {}

final class SuppliersInitial extends SuppliersState {}

final class SuppliersLoading extends SuppliersState {}

final class SuppliersLoaded extends SuppliersState {
  final SuppliersResponse response;
  SuppliersLoaded({required this.response});
}

final class SuppliersError extends SuppliersState {
  final String message;
  SuppliersError({required this.message});
}

final class SupplierGroupsLoading extends SuppliersState {}

final class SupplierGroupsSuccess extends SuppliersState {
  final SupplierGroupResponse response;
  SupplierGroupsSuccess({required this.response});
}

final class SupplierGroupsError extends SuppliersState {
  final String message;
  SupplierGroupsError({required this.message});
}

final class CreateSupplierLoading extends SuppliersState {}

final class CreateSupplierSuccess extends SuppliersState {
  final CreateSupplierResponse response;
  CreateSupplierSuccess({required this.response});
}

final class CreateSupplierError extends SuppliersState {
  final String message;
  CreateSupplierError({required this.message});
}

final class UpdateSupplierLoading extends SuppliersState {}

final class UpdateSupplierSuccess extends SuppliersState {
  final CreateSupplierResponse response;
  UpdateSupplierSuccess({required this.response});
}

final class UpdateSupplierError extends SuppliersState {
  final String message;
  UpdateSupplierError({required this.message});
}

final class CreateSupplierGroupLoading extends SuppliersState {}

final class CreateSupplierGroupSuccess extends SuppliersState {
  final CreateSupplierGroupResponse response;
  CreateSupplierGroupSuccess({required this.response});
}

final class CreateSupplierGroupError extends SuppliersState {
  final String message;
  CreateSupplierGroupError({required this.message});
}
