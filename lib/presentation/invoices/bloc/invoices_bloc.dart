import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/repository/products_repo.dart';

part 'invoices_event.dart';
part 'invoices_state.dart';

class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  final ProductsRepo productsRepo;

  InvoicesBloc({required this.productsRepo}) : super(InvoicesInitial()) {
    on<GetInvoices>(_onGetInvoices);
  }

  Future<void> _onGetInvoices(
    GetInvoices event,
    Emitter<InvoicesState> emit,
  ) async {
    final currentState = state;
    List<InvoiceListItem> currentInvoices = [];
    if (event.loadMore && currentState is InvoicesLoaded) {
      currentInvoices = List.from(currentState.invoices);
    } else {
      emit(InvoicesLoading());
    }

    try {
      final response = event.isPos
          ? await productsRepo.listPosInvoices(
              company: event.company,
              limit: event.limit,
              offset: event.offset,
              customer: event.customer,
              fromDate: event.fromDate,
              toDate: event.toDate,
              status: event.status,
            )
          : await productsRepo.listSalesInvoices(
              company: event.company,
              limit: event.limit,
              offset: event.offset,
              customer: event.customer,
              fromDate: event.fromDate,
              toDate: event.toDate,
              status: event.status,
            );

      final allInvoices = event.loadMore
          ? [...currentInvoices, ...response.data]
          : response.data;

      emit(
        InvoicesLoaded(
          invoices: allInvoices,
          count: response.count,
          hasMore: allInvoices.length < response.count,
        ),
      );
    } catch (e) {
      emit(InvoicesError(message: e.toString()));
    }
  }
}
