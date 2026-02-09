part of 'invoices_bloc.dart';

@immutable
sealed class InvoicesEvent {}

class GetInvoices extends InvoicesEvent {
  final bool isPos;
  final String company;
  final int limit;
  final int offset;
  final String? customer;
  final String? fromDate;
  final String? toDate;
  final String? status;
  final bool loadMore;

  GetInvoices({
    required this.isPos,
    required this.company,
    this.limit = 20,
    this.offset = 0,
    this.customer,
    this.fromDate,
    this.toDate,
    this.status,
    this.loadMore = false,
  });
}
