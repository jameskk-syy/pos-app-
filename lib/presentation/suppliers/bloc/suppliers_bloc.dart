import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pos/domain/repository/suppliers_repo.dart';
import 'package:pos/domain/requests/suppliers/create_supplier_group_request.dart';
import 'package:pos/domain/requests/suppliers/create_supplier_request.dart';
import 'package:pos/domain/requests/suppliers/update_supplier_request.dart';
import 'package:pos/domain/responses/suppliers/create_supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers/create_supplier_response.dart';
import 'package:pos/domain/responses/suppliers/supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers/suppliers_response.dart';

part 'suppliers_event.dart';
part 'suppliers_state.dart';

class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  final SuppliersRepo suppliersRepo;
  SuppliersBloc({required this.suppliersRepo}) : super(SuppliersInitial()) {
    on<GetSupplierGroups>(_onGetSupplierGroups);
    on<GetSuppliers>(_onGetSuppliers);
    on<CreateSupplier>(_onCreateSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<CreateSupplierGroup>(_onCreateSupplierGroup);
  }
  Future<void> _onCreateSupplierGroup(
    CreateSupplierGroup event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(CreateSupplierGroupLoading());
    try {
      final response = await suppliersRepo.createSupplierGroup(event.request);
      emit(CreateSupplierGroupSuccess(response: response));
    } catch (e) {
      emit(CreateSupplierGroupError(message: e.toString()));
    }
  }

  Future<void> _onGetSuppliers(
    GetSuppliers event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(SuppliersLoading());
    try {
      final response = await suppliersRepo.getSuppliers(
        searchTerm: event.searchTerm,
        supplierGroup: event.supplierGroup,
        company: event.company,
        limit: event.limit,
        offset: event.offset,
        supplierType: event.supplierType,
        country: event.country,
        disabled: event.disabled,
      );
      emit(SuppliersLoaded(response: response));
    } catch (e) {
      emit(SuppliersError(message: e.toString()));
    }
  }

  Future<void> _onCreateSupplier(
    CreateSupplier event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(CreateSupplierLoading());
    try {
      final response = await suppliersRepo.createSupplier(event.request);
      emit(CreateSupplierSuccess(response: response));
    } catch (e) {
      emit(CreateSupplierError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplier event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(UpdateSupplierLoading());
    try {
      final response = await suppliersRepo.updateSupplier(event.request);
      emit(UpdateSupplierSuccess(response: response));
    } catch (e) {
      emit(UpdateSupplierError(message: e.toString()));
    }
  }

  Future<void> _onGetSupplierGroups(
    GetSupplierGroups event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(SupplierGroupsLoading());
    try {
      final response = await suppliersRepo.getSupplierGroups();
      emit(SupplierGroupsSuccess(response: response));
    } catch (e) {
      emit(SupplierGroupsError(message: e.toString()));
    }
  }
}
