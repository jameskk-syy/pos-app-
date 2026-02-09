import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/repository/purchase_repo.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_detail_response.dart';
import 'package:pos/domain/requests/purchase/pay_purchase_invoice_request.dart';
import 'package:pos/domain/responses/purchase/pay_purchase_invoice_response.dart';

part 'purchase_invoice_event.dart';
part 'purchase_invoice_state.dart';

class PurchaseInvoiceBloc
    extends Bloc<PurchaseInvoiceEvent, PurchaseInvoiceState> {
  final PurchaseRepo purchaseRepo;

  PurchaseInvoiceBloc({required this.purchaseRepo})
    : super(PurchaseInvoiceInitial()) {
    on<FetchPurchaseInvoicesEvent>(_onFetchPurchaseInvoices);
    on<RefreshPurchaseInvoicesEvent>(_onRefreshPurchaseInvoices);
    on<FetchPurchaseInvoiceDetailEvent>(_onFetchPurchaseInvoiceDetail);
    on<CreatePurchaseInvoiceFromGrnEvent>(_onCreatePurchaseInvoiceFromGrn);
    on<PayPurchaseInvoiceEvent>(_onPayPurchaseInvoice);
  }

  Future<void> _onFetchPurchaseInvoices(
    FetchPurchaseInvoicesEvent event,
    Emitter<PurchaseInvoiceState> emit,
  ) async {
    emit(PurchaseInvoiceLoading());

    try {
      final response = await purchaseRepo.getPurchaseInvoices(
        page: event.page,
        pageSize: event.pageSize,
        company: event.company,
        status: event.status,
        supplier: event.supplier,
      );

      if (response.data.isEmpty) {
        emit(PurchaseInvoiceEmpty());
      } else {
        emit(
          PurchaseInvoiceLoaded(
            purchaseInvoices: response.data,
            totalCount: response.meta.total,
            currentPage: response.meta.page,
            totalPages: response.meta.totalPages,
          ),
        );
      }
    } catch (e) {
      emit(PurchaseInvoiceError(message: e.toString()));
    }
  }

  Future<void> _onRefreshPurchaseInvoices(
    RefreshPurchaseInvoicesEvent event,
    Emitter<PurchaseInvoiceState> emit,
  ) async {
    // Optionally emit loading or just fetch directly
    try {
      final response = await purchaseRepo.getPurchaseInvoices(
        page: 1,
        pageSize: 20,
        company: event.company,
        status: event.status,
        supplier: event.supplier,
      );

      if (response.data.isEmpty) {
        emit(PurchaseInvoiceEmpty());
      } else {
        emit(
          PurchaseInvoiceLoaded(
            purchaseInvoices: response.data,
            totalCount: response.meta.total,
            currentPage: response.meta.page,
            totalPages: response.meta.totalPages,
          ),
        );
      }
    } catch (e) {
      emit(PurchaseInvoiceError(message: e.toString()));
    }
  }

  Future<void> _onFetchPurchaseInvoiceDetail(
    FetchPurchaseInvoiceDetailEvent event,
    Emitter<PurchaseInvoiceState> emit,
  ) async {
    emit(PurchaseInvoiceDetailLoading());

    try {
      final response = await purchaseRepo.getPurchaseInvoiceDetails(
        invoiceNo: event.invoiceNo,
      );
      emit(PurchaseInvoiceDetailLoaded(response: response));
    } catch (e) {
      emit(
        PurchaseInvoiceDetailError(
          message: e.toString(),
          invoiceNo: event.invoiceNo,
        ),
      );
    }
  }

  Future<void> _onCreatePurchaseInvoiceFromGrn(
    CreatePurchaseInvoiceFromGrnEvent event,
    Emitter<PurchaseInvoiceState> emit,
  ) async {
    emit(PurchaseInvoiceCreating());

    try {
      await purchaseRepo.createPurchaseInvoiceFromGrn(
        grnNo: event.grnNo,
        doNotSubmit: event.doNotSubmit,
        billDate: event.billDate,
        fileBase64: event.fileBase64,
        fileName: event.fileName,
      );
      emit(PurchaseInvoiceCreated());
    } catch (e) {
      emit(PurchaseInvoiceCreateError(message: e.toString()));
    }
  }

  Future<void> _onPayPurchaseInvoice(
    PayPurchaseInvoiceEvent event,
    Emitter<PurchaseInvoiceState> emit,
  ) async {
    emit(PayingPurchaseInvoice());

    try {
      final response = await purchaseRepo.payPurchaseInvoice(
        request: event.request,
      );
      emit(PaidPurchaseInvoice(response: response));
    } catch (e) {
      emit(PayPurchaseInvoiceError(message: e.toString()));
    }
  }
}
