// lib/presentation/bloc/purchase/purchase_event.dart

part of 'purchase_bloc.dart';

@immutable
sealed class PurchaseEvent {}

class FetchPurchaseOrdersEvent extends PurchaseEvent {
  final String company;
  final int limit;
  final int offset;
  final String? status;
  final String? searchTerm;
  final Map<String, dynamic>? filters;

  FetchPurchaseOrdersEvent({
    required this.company,
    this.limit = 20,
    this.offset = 0,
    this.status,
    this.searchTerm,
    this.filters,
  });
}

class RefreshPurchaseOrdersEvent extends PurchaseEvent {
  final String company;

  RefreshPurchaseOrdersEvent({required this.company});
}

class CreatePurchaseOrderEvent extends PurchaseEvent {
  final CreatePurchaseOrderRequest request;

  CreatePurchaseOrderEvent({required this.request});
}

class SubmitPurchaseOrderEvent extends PurchaseEvent {
  final String lpoNo;

  SubmitPurchaseOrderEvent({required this.lpoNo});
}

final class PurchaseOrderSubmitting extends PurchaseState {
  final String lpoNo;

  PurchaseOrderSubmitting({required this.lpoNo});
}

final class PurchaseOrderSubmitted extends PurchaseState {
  final SubmitPurchaseOrderResponse response;
  final String message;

  PurchaseOrderSubmitted({required this.response, required this.message});
}

final class PurchaseOrderSubmitError extends PurchaseState {
  final String message;
  final String? lpoNo;

  PurchaseOrderSubmitError({required this.message, this.lpoNo});
}

class ResubmitPurchaseOrderEvent extends PurchaseEvent {
  final String lpoNo;

  ResubmitPurchaseOrderEvent({required this.lpoNo});
}

class CreateGrnEvent extends PurchaseEvent {
  final CreateGrnRequest request;

  CreateGrnEvent({required this.request});
}

class FetchPurchaseOrderDetailEvent extends PurchaseEvent {
  final String poName;

  FetchPurchaseOrderDetailEvent({required this.poName});
}
