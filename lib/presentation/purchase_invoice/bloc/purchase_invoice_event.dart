part of 'purchase_invoice_bloc.dart';

@immutable
sealed class PurchaseInvoiceEvent {}

class FetchPurchaseInvoicesEvent extends PurchaseInvoiceEvent {
  final int page;
  final int pageSize;
  final String? company;
  final String? status;
  final String? supplier;

  FetchPurchaseInvoicesEvent({
    this.page = 1,
    this.pageSize = 20,
    this.company,
    this.status,
    this.supplier,
  });
}

class RefreshPurchaseInvoicesEvent extends PurchaseInvoiceEvent {
  final String? company;
  final String? status;
  final String? supplier;

  RefreshPurchaseInvoicesEvent({this.company, this.status, this.supplier});
}

class FetchPurchaseInvoiceDetailEvent extends PurchaseInvoiceEvent {
  final String invoiceNo;

  FetchPurchaseInvoiceDetailEvent({required this.invoiceNo});
}

class CreatePurchaseInvoiceFromGrnEvent extends PurchaseInvoiceEvent {
  final String grnNo;
  final bool doNotSubmit;
  final String billDate;
  final String? fileBase64;
  final String? fileName;

  CreatePurchaseInvoiceFromGrnEvent({
    required this.grnNo,
    required this.doNotSubmit,
    required this.billDate,
    this.fileBase64,
    this.fileName,
  });
}

class PayPurchaseInvoiceEvent extends PurchaseInvoiceEvent {
  final PayPurchaseInvoiceRequest request;

  PayPurchaseInvoiceEvent({required this.request});
}
