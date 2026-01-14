part of 'sales_bloc.dart';

@immutable
sealed class SalesEvent {}

class GetPaymentMethod extends SalesEvent {
  final String company;
  final bool onlyEnabled;

  GetPaymentMethod({required this.company, this.onlyEnabled = true});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetPaymentMethod &&
          runtimeType == other.runtimeType &&
          company == other.company &&
          onlyEnabled == other.onlyEnabled;

  @override
  int get hashCode => company.hashCode ^ onlyEnabled.hashCode;
}

class CreatePOSSession extends SalesEvent {
  final POSSessionRequest request;

  CreatePOSSession({required this.request});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePOSSession &&
          runtimeType == other.runtimeType &&
          request == other.request;

  @override
  int get hashCode => request.hashCode;
}

class GetSalesInvoice extends SalesEvent {
  final String invoiceName;

  GetSalesInvoice({required this.invoiceName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetSalesInvoice &&
          runtimeType == other.runtimeType &&
          invoiceName == other.invoiceName;

  @override
  int get hashCode => invoiceName.hashCode;
}

class CreateInvoice extends SalesEvent {
  final InvoiceRequest request;

  CreateInvoice({required this.request});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateInvoice &&
          runtimeType == other.runtimeType &&
          request == other.request;

  @override
  int get hashCode => request.hashCode;
}

class AddBalanceDetail extends SalesEvent {
  final BalanceDetail balanceDetail;

  AddBalanceDetail({required this.balanceDetail});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddBalanceDetail &&
          runtimeType == other.runtimeType &&
          balanceDetail == other.balanceDetail;

  @override
  int get hashCode => balanceDetail.hashCode;
}

class ClearBalanceDetails extends SalesEvent {}

class ClosePOSSession extends SalesEvent {
  final ClosePOSSessionRequest request;

  ClosePOSSession({required this.request});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClosePOSSession &&
          runtimeType == other.runtimeType &&
          request == other.request;

  @override
  int get hashCode => request.hashCode;
}
