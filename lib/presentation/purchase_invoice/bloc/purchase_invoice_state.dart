part of 'purchase_invoice_bloc.dart';

@immutable
sealed class PurchaseInvoiceState {}

final class PurchaseInvoiceInitial extends PurchaseInvoiceState {}

final class PurchaseInvoiceLoading extends PurchaseInvoiceState {}

final class PurchaseInvoiceLoaded extends PurchaseInvoiceState {
  final List<PurchaseInvoiceData> purchaseInvoices;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  PurchaseInvoiceLoaded({
    required this.purchaseInvoices,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });
}

final class PurchaseInvoiceError extends PurchaseInvoiceState {
  final String message;

  PurchaseInvoiceError({required this.message});
}

final class PurchaseInvoiceEmpty extends PurchaseInvoiceState {}

final class PurchaseInvoiceDetailLoading extends PurchaseInvoiceState {}

final class PurchaseInvoiceDetailLoaded extends PurchaseInvoiceState {
  final PurchaseInvoiceDetailResponse response;

  PurchaseInvoiceDetailLoaded({required this.response});
}

final class PurchaseInvoiceDetailError extends PurchaseInvoiceState {
  final String message;
  final String? invoiceNo;

  PurchaseInvoiceDetailError({required this.message, this.invoiceNo});
}

final class PurchaseInvoiceCreating extends PurchaseInvoiceState {}

final class PurchaseInvoiceCreated extends PurchaseInvoiceState {}

final class PurchaseInvoiceCreateError extends PurchaseInvoiceState {
  final String message;
  PurchaseInvoiceCreateError({required this.message});
}

final class PayingPurchaseInvoice extends PurchaseInvoiceState {}

final class PaidPurchaseInvoice extends PurchaseInvoiceState {
  final PayPurchaseInvoiceResponse response;
  PaidPurchaseInvoice({required this.response});
}

final class PayPurchaseInvoiceError extends PurchaseInvoiceState {
  final String message;
  PayPurchaseInvoiceError({required this.message});
}
