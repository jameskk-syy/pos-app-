import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/invoice_model_get.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/models/pos_session_model.dart';
import 'package:pos/domain/repository/abstract_sales_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository salesRepository;
  final List<BalanceDetail> _balanceDetails = [];

  SalesBloc({required this.salesRepository}) : super(SalesInitial()) {
    on<GetPaymentMethod>(_getPaymentMethods);
    on<CreatePOSSession>(_createPOSSession);
    on<CreateInvoice>(_createInvoice);
    on<AddBalanceDetail>(_addBalanceDetail);
    on<ClearBalanceDetails>(_clearBalanceDetails);
    on<GetSalesInvoice>(_getSalesInvoice);
    on<ClosePOSSession>(_closePOSSession);
  }

  List<BalanceDetail> get balanceDetails => List.from(_balanceDetails);

  FutureOr<void> _getPaymentMethods(
    GetPaymentMethod event,
    Emitter<SalesState> emit,
  ) async {
    emit(PaymentMethodsLoading());
    try {
      final paymentMethods = await salesRepository.fetchPaymentMethods(
        company: event.company,
        onlyEnabled: event.onlyEnabled,
      );
      emit(PaymentMethodsLoaded(paymentMethods: paymentMethods));
    } catch (e) {
      emit(PaymentMethodsError(message: e.toString()));
    }
  }

  FutureOr<void> _createPOSSession(
    CreatePOSSession event,
    Emitter<SalesState> emit,
  ) async {
    emit(POSSessionLoading());
    try {
      final session = await salesRepository.createPOSSession(
        request: event.request,
      );

      await _saveSessionToPrefs(session);
      _balanceDetails.clear();

      emit(
        POSSessionCreated(
          session: session,
          message: 'POS Session opened successfully',
        ),
      );
    } catch (e) {
      emit(POSSessionError(message: e.toString()));
    }
  }

  FutureOr<void> _createInvoice(
    CreateInvoice event,
    Emitter<SalesState> emit,
  ) async {
    emit(InvoiceLoading());
    try {
      final invoiceResponse = await salesRepository.createInvoice(
        request: event.request,
      );

      emit(
        InvoiceCreated(
          invoiceResponse: invoiceResponse,
          message: invoiceResponse.message,
        ),
      );
    } catch (e) {
      emit(InvoiceError(message: e.toString()));
    }
  }

  Future<void> _saveSessionToPrefs(POSSessionResponse session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'current_pos_session',
        jsonEncode({
          'name': session.name,
          'pos_profile': session.posProfile,
          'company': session.company,
          'user': session.user,
          'status': session.status,
          'posting_date': session.postingDate,
          'period_start_date': session.periodStartDate,
          'balance_details': session.balanceDetails
              .map(
                (bd) => {
                  'mode_of_payment': bd.modeOfPayment,
                  'opening_amount': bd.openingAmount,
                },
              )
              .toList(),
        }),
      );
    } catch (e) {
      debugPrint('Error saving session to prefs: $e');
    }
  }

  void _addBalanceDetail(AddBalanceDetail event, Emitter<SalesState> emit) {
    _balanceDetails.add(event.balanceDetail);
    emit(BalanceDetailsUpdated(balanceDetails: List.from(_balanceDetails)));
  }

  void _clearBalanceDetails(
    ClearBalanceDetails event,
    Emitter<SalesState> emit,
  ) {
    _balanceDetails.clear();
    emit(BalanceDetailsUpdated(balanceDetails: []));
  }

  FutureOr<void> _getSalesInvoice(
    GetSalesInvoice event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesInvoiceLoading());

    try {
      final response = await salesRepository.getSalesInvoice(
        invoiceName: event.invoiceName,
      );

      if (response.success) {
        emit(
          SalesInvoiceLoaded(
            salesInvoiceResponse: response,
            message: 'Invoice details loaded successfully',
          ),
        );
      } else {
        emit(
          SalesInvoiceError(
            message: response.error ?? 'Failed to load invoice details',
          ),
        );
      }
    } catch (e) {
      emit(SalesInvoiceError(message: e.toString()));
    }
  }

  FutureOr<void> _closePOSSession(
    ClosePOSSession event,
    Emitter<SalesState> emit,
  ) async {
    emit(POSSessionCloseLoading());
    try {
      final response = await salesRepository.closePOSSession(
        request: event.request,
      );

      // If successful, we might want to clear the session from prefs or update it
      // But keeping it simple for now as per requirements
      if (response.success) {
        emit(POSSessionClosed(response: response, message: response.message));
      } else {
        emit(POSSessionCloseError(message: response.message));
      }
    } catch (e) {
      emit(POSSessionCloseError(message: e.toString()));
    }
  }
}
