// lib/presentation/bloc/purchase/purchase_state.dart

part of 'purchase_bloc.dart';

@immutable
sealed class PurchaseState {}

final class PurchaseInitial extends PurchaseState {}

final class PurchaseLoading extends PurchaseState {}

final class PurchaseLoaded extends PurchaseState {
  final List<PurchaseOrderData> purchaseOrders;
  final int totalCount;

  PurchaseLoaded({
    required this.purchaseOrders,
    required this.totalCount,
  });
}

final class PurchaseError extends PurchaseState {
  final String message;

  PurchaseError({required this.message});
}

final class PurchaseEmpty extends PurchaseState {}
final class PurchaseOrderCreating extends PurchaseState {}

final class PurchaseOrderCreated extends PurchaseState {
  final CreatePurchaseOrderResponse response;

  PurchaseOrderCreated({required this.response});
}

final class PurchaseOrderCreateError extends PurchaseState {
  final String message;

  PurchaseOrderCreateError({required this.message});
}

final class GrnCreating extends PurchaseState {}

final class GrnCreated extends PurchaseState {
  final CreateGrnResponse response;
  final String message;

  GrnCreated({
    required this.response,
    required this.message,
  });
}

final class GrnCreateError extends PurchaseState {
  final String message;
  final String? lpoNo;

  GrnCreateError({
    required this.message,
    this.lpoNo,
  });
}
final class PurchaseOrderDetailLoading extends PurchaseState {}

final class PurchaseOrderDetailLoaded extends PurchaseState {
  final PurchaseOrderDetailResponse response;

  PurchaseOrderDetailLoaded({required this.response});
}

final class PurchaseOrderDetailError extends PurchaseState {
  final String message;
  final String? poName;

  PurchaseOrderDetailError({
    required this.message,
    this.poName,
  });
}