import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/industries_list_repo.dart';
import 'package:pos/domain/requests/seed_item.dart';
import 'package:pos/domain/responses/bulk_upload.dart';
import 'package:pos/domain/responses/industries_list_response.dart';
import 'package:pos/domain/responses/seed_items_response.dart';

part 'industries_event.dart';
part 'industries_state.dart';

class IndustriesBloc extends Bloc<IndustriesEvent, IndustriesState> {
  final IndustriesRepo industriesRepo;
  IndustriesBloc({required this.industriesRepo}) : super(IndustriesInitial()) {
    on<IndustriesEvent>((event, emit) {});
    on<GetIndustriesList>(_getAllIndustries);
    on<SeedProducts>(_seedProducts);
    on<SeedItems>(_seedItem);
  }

  Future<void> _getAllIndustries(
    GetIndustriesList event,
    Emitter<IndustriesState> emit,
  ) async {
    emit(IndustriesLoading());
    try {
      final response = await industriesRepo.getIndustriesList();
      emit(IndustriesSuccess(response));
    } catch (e) {
      debugPrint(e.toString());
      emit(IndustriesFailure(e.toString()));
    }
  }

  Future<void> _seedProducts(
    SeedProducts event,
    Emitter<IndustriesState> emit,
  ) async {
    debugPrint(event.industry);
    emit(IndustriesLoading());
    try {
      final response = await industriesRepo.seedProducts(event.industry);
      emit(IndustriesSeedProductSuccess(response));
    } catch (e) {
      debugPrint(e.toString());
      emit(IndustriesFailure(e.toString()));
    }
  }

  Future<void> _seedItem(SeedItems event, Emitter<IndustriesState> emit) async {
     debugPrint(event.createOrderRequest.toString());
    emit(IndustriesLoading());
    try {
      final response = await industriesRepo.seedItems(event.createOrderRequest);
      emit(IndustriesSeedItemState(createOrderResponse: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(IndustriesFailure(e.toString()));
    }
  }
}
