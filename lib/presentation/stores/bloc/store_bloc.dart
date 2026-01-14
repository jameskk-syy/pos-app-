import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/store_repo.dart';
import 'package:pos/domain/requests/create_warehouse.dart';
import 'package:pos/domain/requests/update_warehouse.dart';
import 'package:pos/domain/responses/store_response.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepo storeRepo;
  StoreBloc({required this.storeRepo}) : super(StoreInitial()) {
    on<StoreEvent>((event, emit) {});
    on<GetAllStores>(_getAllStores);
    on<Createwarehouse>(_createWarehouse);
    on<UpdateWarehouse>(_updateWarehouse);
  }

  Future<void> _getAllStores(
    GetAllStores event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreStateLoading());
    try {
      final response = await storeRepo.getAllStores(
        event.company,
        limit: event.limit,
        offset: event.offset,
      );
      emit(StoreStateSuccess(storeGetResponse: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(StoreStateFailure(error: e.toString()));
    }
  }

  FutureOr<void> _createWarehouse(
    Createwarehouse event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreStateLoading());
    try {
      await storeRepo.createWarehouse(event.createWarehouseRequest);
      emit(StoreSuccessfulState());
    } catch (e) {
      emit(StoreStateFailure(error: e.toString()));
    }
  }

  FutureOr<void> _updateWarehouse(
    UpdateWarehouse event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreStateLoading());
    try {
      await storeRepo.updateWarehouse(event.updateWarehouseRequest);
      emit(StoreUpdateSuccessState());
    } catch (e) {
      emit(StoreStateFailure(error: e.toString()));
    }
  }
}
