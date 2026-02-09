part of 'grn_bloc.dart';

abstract class GrnEvent {}

class FetchGrnListEvent extends GrnEvent {
  final int page;
  final int pageSize;
  final String? company;
  final String? supplier;
  final String? searchTerm;

  FetchGrnListEvent({
    this.page = 1,
    this.pageSize = 20,
    this.company,
    this.supplier,
    this.searchTerm,
  });
}

class FetchGrnDetailEvent extends GrnEvent {
  final String grnNo;
  FetchGrnDetailEvent({required this.grnNo});
}
