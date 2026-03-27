import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pos/domain/repository/biller_repo.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/responses/biller/biller_responses.dart';
import 'package:pos/domain/models/biller_models.dart';

part 'biller_event.dart';
part 'biller_state.dart';

class BillerBloc extends Bloc<BillerEvent, BillerState> {
  final BillerRepo billerRepo;

  BillerBloc({required this.billerRepo}) : super(BillerInitial()) {
    on<GetUserContext>(_getUserContext);
    on<SetActiveBiller>(_setActiveBiller);
    on<GetBillerDetails>(_getBillerDetails);
    on<ListBillers>(_listBillers);
    on<CreateBiller>(_createBiller);
  }

  FutureOr<void> _getUserContext(
    GetUserContext event,
    Emitter<BillerState> emit,
  ) async {
    emit(UserContextLoading());
    try {
      final response = await billerRepo.getUserContext();
      emit(UserContextLoaded(response));
    } catch (e) {
      emit(UserContextError(_cleanError(e)));
    }
  }

  FutureOr<void> _setActiveBiller(
    SetActiveBiller event,
    Emitter<BillerState> emit,
  ) async {
    emit(SetActiveBillerLoading());
    try {
      final response = await billerRepo.setActiveBiller(event.request);
      emit(SetActiveBillerSuccess(response));
    } catch (e) {
      emit(SetActiveBillerError(_cleanError(e)));
    }
  }

  FutureOr<void> _getBillerDetails(
    GetBillerDetails event,
    Emitter<BillerState> emit,
  ) async {
    emit(BillerDetailsLoading());
    try {
      final response = await billerRepo.getBillerDetails(event.request);
      emit(BillerDetailsLoaded(response));
    } catch (e) {
      emit(BillerDetailsError(_cleanError(e)));
    }
  }

  FutureOr<void> _listBillers(
    ListBillers event,
    Emitter<BillerState> emit,
  ) async {
    final isFirstFetch = event.request.offset == 0;
    
    if (isFirstFetch) {
      emit(ListBillersLoading());
    } else {
      final currentState = state;
      if (currentState is ListBillersLoaded) {
        emit(ListBillersMoreLoading(currentState.response.billers));
      }
    }

    try {
      final response = await billerRepo.listBillers(event.request);
      
      if (isFirstFetch) {
        emit(ListBillersLoaded(
          response,
          hasReachedMax: response.billers.length >= response.totalCount,
        ));
      } else {
        final currentState = state;
        if (currentState is ListBillersMoreLoading) {
          final updatedBillers = currentState.existingBillers + response.billers;
          emit(ListBillersLoaded(
            ListBillersResponse(
              success: response.success,
              billers: updatedBillers,
              totalCount: response.totalCount,
            ),
            hasReachedMax: updatedBillers.length >= response.totalCount,
          ));
        }
      }
    } catch (e) {
      emit(ListBillersError(_cleanError(e)));
    }
  }

  FutureOr<void> _createBiller(
    CreateBiller event,
    Emitter<BillerState> emit,
  ) async {
    emit(CreateBillerLoading());
    try {
      final response = await billerRepo.createBiller(event.request);
      emit(CreateBillerSuccess(response));
    } catch (e) {
      emit(CreateBillerError(_cleanError(e)));
    }
  }

  String _cleanError(dynamic e) {
    String message = e.toString();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }
    return message.trim();
  }
}
