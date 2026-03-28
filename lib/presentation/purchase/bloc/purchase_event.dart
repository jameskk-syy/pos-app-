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

class CreatePurchaseReturnEvent extends PurchaseEvent {
  final CreatePurchaseReturnRequest request;

  CreatePurchaseReturnEvent({required this.request});
}

class FetchPurchaseReturnsEvent extends PurchaseEvent {
  final String company;
  final int page;
  final int pageSize;
  final String? searchTerm;
  final bool isRefresh;

  FetchPurchaseReturnsEvent({
    required this.company,
    this.page = 1,
    this.pageSize = 20,
    this.searchTerm,
    this.isRefresh = false,
  });
}
