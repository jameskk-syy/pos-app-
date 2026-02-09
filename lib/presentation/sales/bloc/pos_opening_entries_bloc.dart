import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pos/domain/models/pos_opening_entry_model.dart';
import 'package:pos/domain/repository/products_repo.dart';

part 'pos_opening_entries_event.dart';
part 'pos_opening_entries_state.dart';

class PosOpeningEntriesBloc
    extends Bloc<PosOpeningEntriesEvent, PosOpeningEntriesState> {
  final ProductsRepo productsRepo;

  PosOpeningEntriesBloc({required this.productsRepo})
    : super(PosOpeningEntriesInitial()) {
    on<GetPosOpeningEntries>(_onGetPosOpeningEntries);
    on<CloseOpeningEntry>(_onCloseOpeningEntry);
  }

  Future<void> _onGetPosOpeningEntries(
    GetPosOpeningEntries event,
    Emitter<PosOpeningEntriesState> emit,
  ) async {
    final currentState = state;
    List<PosOpeningEntry> currentEntries = [];
    if (event.loadMore && currentState is PosOpeningEntriesLoaded) {
      currentEntries = List.from(currentState.entries);
    } else {
      emit(PosOpeningEntriesLoading());
    }

    try {
      final response = await productsRepo.listPosOpeningEntries(
        company: event.company,
        limit: event.limit,
        offset: event.offset,
      );

      final allEntries = event.loadMore
          ? [...currentEntries, ...response.data]
          : response.data;

      emit(
        PosOpeningEntriesLoaded(
          entries: allEntries,
          count: response.count,
          hasMore: allEntries.length < response.count,
        ),
      );
    } catch (e) {
      emit(PosOpeningEntriesError(message: e.toString()));
    }
  }

  Future<void> _onCloseOpeningEntry(
    CloseOpeningEntry event,
    Emitter<PosOpeningEntriesState> emit,
  ) async {
    emit(PosOpeningEntryClosing());
    try {
      final response = await productsRepo.closePosOpeningEntry(
        posOpeningEntry: event.posOpeningEntry,
        doNotSubmit: event.doNotSubmit,
      );

      if (response.success) {
        emit(
          PosOpeningEntryCloseSuccess(
            message: response.message ?? 'Successfully closed opening entry',
          ),
        );
      } else {
        emit(
          PosOpeningEntriesError(
            message: response.message ?? 'Failed to close opening entry',
          ),
        );
      }
    } catch (e) {
      emit(PosOpeningEntriesError(message: e.toString()));
    }
  }
}
