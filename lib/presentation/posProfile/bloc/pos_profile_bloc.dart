import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pos/domain/repository/pos_profile_repo.dart';
import 'package:pos/domain/requests/sales/create_pos_request.dart';

part 'pos_profile_event.dart';
part 'pos_profile_state.dart';

class PosProfileBloc extends Bloc<PosProfileEvent, PosProfileState> {
  final PosProfileRepo posProfileRepo;
  PosProfileBloc({required this.posProfileRepo}) : super(PosProfileInitial()) {
    on<PosProfileEvent>((event, emit) {});
    on<CreateProfilePos>(_createPosProfile);
  }

  FutureOr<void> _createPosProfile(
    CreateProfilePos event,
    Emitter<PosProfileState> emit,
  ) async {
    emit(PosProfileStateLoading());
    try {
      await posProfileRepo.createPosProfile(event.companyProfileRequest);
      emit(PosProfileStateSuccess());
    } catch (e) {
      emit(PosProfileStateFailure(error: e.toString()));
      debugPrint(e.toString());
    }
  }
}
