part of 'sales_bloc.dart';

@immutable
sealed class SalesState {}

final class SalesInitial extends SalesState {}

final class PaymentMethodsLoading extends SalesState {}

final class PaymentMethodsLoaded extends SalesState {
  final List<PaymentMethod> paymentMethods;

  PaymentMethodsLoaded({required this.paymentMethods});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodsLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(paymentMethods, other.paymentMethods);

  @override
  int get hashCode => paymentMethods.hashCode;
}

final class SalesInvoiceLoading extends SalesState {}

final class SalesInvoiceLoaded extends SalesState {
  final GetSalesInvoiceResponse salesInvoiceResponse;
  final String message;

  SalesInvoiceLoaded({
    required this.salesInvoiceResponse,
    required this.message,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesInvoiceLoaded &&
          runtimeType == other.runtimeType &&
          salesInvoiceResponse == other.salesInvoiceResponse &&
          message == other.message;

  @override
  int get hashCode => salesInvoiceResponse.hashCode ^ message.hashCode;
}

final class SalesInvoiceError extends SalesState {
  final String message;

  SalesInvoiceError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesInvoiceError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

final class PaymentMethodsError extends SalesState {
  final String message;

  PaymentMethodsError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodsError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

final class POSSessionLoading extends SalesState {}

final class POSSessionCreated extends SalesState {
  final POSSessionResponse session;
  final String message;

  POSSessionCreated({required this.session, required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is POSSessionCreated &&
          runtimeType == other.runtimeType &&
          session == other.session &&
          message == other.message;

  @override
  int get hashCode => session.hashCode ^ message.hashCode;
}

final class POSSessionError extends SalesState {
  final String message;

  POSSessionError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is POSSessionError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

final class BalanceDetailsUpdated extends SalesState {
  final List<BalanceDetail> balanceDetails;

  BalanceDetailsUpdated({required this.balanceDetails});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceDetailsUpdated &&
          runtimeType == other.runtimeType &&
          listEquals(balanceDetails, other.balanceDetails);

  @override
  int get hashCode => balanceDetails.hashCode;
}

final class InvoiceLoading extends SalesState {}

final class InvoiceCreated extends SalesState {
  final CreateInvoiceResponse invoiceResponse;
  final String message;

  InvoiceCreated({required this.invoiceResponse, required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceCreated &&
          runtimeType == other.runtimeType &&
          invoiceResponse == other.invoiceResponse &&
          message == other.message;

  @override
  int get hashCode => invoiceResponse.hashCode ^ message.hashCode;
}

final class InvoiceError extends SalesState {
  final String message;

  InvoiceError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

final class POSSessionCloseLoading extends SalesState {}

final class POSSessionClosed extends SalesState {
  final ClosePOSSessionResponse response;
  final String message;

  POSSessionClosed({required this.response, required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is POSSessionClosed &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          message == other.message;

  @override
  int get hashCode => response.hashCode ^ message.hashCode;
}

final class POSSessionCloseError extends SalesState {
  final String message;

  POSSessionCloseError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is POSSessionCloseError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

final class CreateCreditPaymentLoading extends SalesState {}

final class CreditPaymentCreated extends SalesState {
  final Map<String, dynamic> response;
  final String message;

  CreditPaymentCreated({required this.response, required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditPaymentCreated &&
          runtimeType == other.runtimeType &&
          response == other.response &&
          message == other.message;

  @override
  int get hashCode => response.hashCode ^ message.hashCode;
}

final class CreateCreditPaymentError extends SalesState {
  final String message;

  CreateCreditPaymentError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateCreditPaymentError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

final class ReceivableAccountLoading extends SalesState {}

final class ReceivableAccountLoaded extends SalesState {
  final Map<String, dynamic> data;

  ReceivableAccountLoaded({required this.data});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceivableAccountLoaded &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

final class ReceivableAccountError extends SalesState {
  final String message;

  ReceivableAccountError({required this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceivableAccountError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
