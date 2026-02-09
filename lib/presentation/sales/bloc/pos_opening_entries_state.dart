part of 'pos_opening_entries_bloc.dart';

@immutable
sealed class PosOpeningEntriesState {}

final class PosOpeningEntriesInitial extends PosOpeningEntriesState {}

final class PosOpeningEntriesLoading extends PosOpeningEntriesState {}

final class PosOpeningEntriesLoaded extends PosOpeningEntriesState {
  final List<PosOpeningEntry> entries;
  final int count;
  final bool hasMore;

  PosOpeningEntriesLoaded({
    required this.entries,
    required this.count,
    required this.hasMore,
  });
}

final class PosOpeningEntriesError extends PosOpeningEntriesState {
  final String message;

  PosOpeningEntriesError({required this.message});
}

final class PosOpeningEntryClosing extends PosOpeningEntriesState {}

final class PosOpeningEntryCloseSuccess extends PosOpeningEntriesState {
  final String message;

  PosOpeningEntryCloseSuccess({required this.message});
}
