part of 'invoices_bloc.dart';

@immutable
sealed class InvoicesState {}

final class InvoicesInitial extends InvoicesState {}

final class InvoicesLoading extends InvoicesState {}

final class InvoicesLoaded extends InvoicesState {
  final List<InvoiceListItem> invoices;
  final int count;
  final bool hasMore;

  InvoicesLoaded({
    required this.invoices,
    required this.count,
    required this.hasMore,
  });
}

final class InvoicesError extends InvoicesState {
  final String message;

  InvoicesError({required this.message});
}
