part of 'suppliers_bloc.dart';

@immutable
sealed class SuppliersEvent {}

class GetSupplierGroups extends SuppliersEvent {}

class CreateSupplier extends SuppliersEvent {
  final CreateSupplierRequest request;

  CreateSupplier({required this.request});
}

class UpdateSupplier extends SuppliersEvent {
  final UpdateSupplierRequest request;

  UpdateSupplier({required this.request});
}

class CreateSupplierGroup extends SuppliersEvent {
  final CreateSupplierGroupRequest request;
  CreateSupplierGroup({required this.request});
}

class GetSuppliers extends SuppliersEvent {
  final String? searchTerm;
  final String? supplierGroup;
  final String company;
  final int limit;
  final int offset;
  final String? supplierType;
  final String? country;
  final bool? disabled;

  GetSuppliers({
    this.searchTerm,
    this.supplierGroup,
    required this.company,
    required this.limit,
    required this.offset,
    this.supplierType,
    this.country,
    this.disabled,
  });
}
