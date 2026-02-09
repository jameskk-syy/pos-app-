part of 'pos_opening_entries_bloc.dart';

@immutable
sealed class PosOpeningEntriesEvent {}

class GetPosOpeningEntries extends PosOpeningEntriesEvent {
  final String company;
  final int limit;
  final int offset;
  final bool loadMore;

  GetPosOpeningEntries({
    required this.company,
    this.limit = 20,
    this.offset = 0,
    this.loadMore = false,
  });
}

class CloseOpeningEntry extends PosOpeningEntriesEvent {
  final String posOpeningEntry;
  final bool doNotSubmit;

  CloseOpeningEntry({required this.posOpeningEntry, this.doNotSubmit = false});
}
