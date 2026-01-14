part of 'inventory_bloc.dart';

@immutable
sealed class InventoryState {}

final class InventoryInitial extends InventoryState {}

final class LowStockLoading extends InventoryState {}
final class LowStockLoaded extends InventoryState {
  final StockResponses response;
  LowStockLoaded(this.response);
}
final class LowStockError extends InventoryState {
  final String message;
  LowStockError(this.message);
}

final class StockSummaryLoading extends InventoryState {}
final class StockSummaryLoaded extends InventoryState {
  final StockSummaryResponse response;
  StockSummaryLoaded(this.response);
}
final class StockSummaryError extends InventoryState {
  final String message;
  StockSummaryError(this.message);
}

final class CreateMaterialTransferLoading extends InventoryState {}
final class CreateMaterialTransferSuccess extends InventoryState {
  final CreateMaterialTransferResponse response;
  CreateMaterialTransferSuccess(this.response);
}
final class CreateMaterialTransferError extends InventoryState {
  final String message;
  CreateMaterialTransferError(this.message);
}

final class ExportCSVLoading extends InventoryState {}
final class ExportCSVSuccess extends InventoryState {
  final String message;
  ExportCSVSuccess(this.message);
}
final class ExportCSVError extends InventoryState {
  final String message;
  ExportCSVError(this.message);
}

final class StockLedgerLoading extends InventoryState {}
final class StockLedgerLoaded extends InventoryState {
  final StockLedgerResponse response;
  StockLedgerLoaded(this.response);
}
final class StockLedgerError extends InventoryState {
  final String message;
  StockLedgerError(this.message);
}
final class CreateStockEntryLoading extends InventoryState {}
final class CreateStockEntrySuccess extends InventoryState {
  final CreateStockEntryResponse response;
  CreateStockEntrySuccess(this.response);
}
final class CreateStockEntryError extends InventoryState {
  final String message;
  CreateStockEntryError(this.message);
}
final class StockEntriesLoading extends InventoryState {}
final class StockEntriesLoaded extends InventoryState {
  final StockEntriesResponse response;
  StockEntriesLoaded(this.response);
}
final class StockEntriesError extends InventoryState {
  final String message;
  StockEntriesError(this.message);
}
final class CreateMaterialReceiptLoading extends InventoryState {}
final class CreateMaterialReceiptSuccess extends InventoryState {
  final CreateMaterialReceiptResponse response;
  CreateMaterialReceiptSuccess(this.response);
}
final class CreateMaterialReceiptError extends InventoryState {
  final String message;
  CreateMaterialReceiptError(this.message);
}
final class CreateMaterialIssueLoading extends InventoryState {}
final class CreateMaterialIssueSuccess extends InventoryState {
  final CreateMaterialIssueResponse response;
  CreateMaterialIssueSuccess(this.response);
}
final class CreateMaterialIssueError extends InventoryState {
  final String message;
  CreateMaterialIssueError(this.message);
}
final class CreateStockTransferLoading extends InventoryState {}
final class CreateStockTransferSuccess extends InventoryState {
  final CreateStockTransferResponse response;
  CreateStockTransferSuccess(this.response);
}
final class CreateStockTransferError extends InventoryState {
  final String message;
  CreateStockTransferError(this.message);
}
final class MaterialRequestsLoading extends InventoryState {}
final class MaterialRequestsLoaded extends InventoryState {
  final MaterialRequestsResponse response;
  MaterialRequestsLoaded(this.response);
}
final class MaterialRequestsError extends InventoryState {
  final String message;
  MaterialRequestsError(this.message);
}
final class ApproveStockTransferLoading extends InventoryState {}

final class ApproveStockTransferSuccess extends InventoryState {
  final ApproveStockTransferResponse response;
  ApproveStockTransferSuccess(this.response);
}

final class ApproveStockTransferError extends InventoryState {
  final String message;
  ApproveStockTransferError(this.message);
}
final class SubmitStockTransferLoading extends InventoryState {}
final class SubmitStockTransferSuccess extends InventoryState {
  final SubmitStockTransferResponse response;
  SubmitStockTransferSuccess(this.response);
}
final class SubmitStockTransferError extends InventoryState {
  final String message;
  SubmitStockTransferError(this.message);
}
final class DispatchStockTransferLoading extends InventoryState {}
final class DispatchStockTransferSuccess extends InventoryState {
  final DispatchStockTransferResponse response;
  DispatchStockTransferSuccess(this.response);
}
final class DispatchStockTransferError extends InventoryState {
  final String message;
  DispatchStockTransferError(this.message);
}
final class StockTransferRequestLoading extends InventoryState {}
final class StockTransferRequestLoaded extends InventoryState {
  final GetStockTransferResponse response;
  StockTransferRequestLoaded(this.response);
}
final class StockTransferRequestError extends InventoryState {
  final String message;
  StockTransferRequestError(this.message);
}
final class ReceiveStockLoading extends InventoryState {}

final class ReceiveStockSuccess extends InventoryState {
  final ReceiveStockResponse response;
  ReceiveStockSuccess(this.response);
}

final class ReceiveStockError extends InventoryState {
  final String message;
  ReceiveStockError(this.message);
}
final class StockReconciliationsLoading extends InventoryState {}

final class StockReconciliationsLoaded extends InventoryState {
  final StockReconciliationsResponse response;
  StockReconciliationsLoaded(this.response);
}

final class StockReconciliationsError extends InventoryState {
  final String message;
  StockReconciliationsError(this.message);
}
final class CreateStockReconciliationLoading extends InventoryState {}

final class CreateStockReconciliationSuccess extends InventoryState {
  final CreateStockReconciliationResponse response;
  CreateStockReconciliationSuccess(this.response);
}

final class CreateStockReconciliationError extends InventoryState {
  final String message;
  CreateStockReconciliationError(this.message);
}
final class GetStockReconciliationLoading extends InventoryState {}

final class GetStockReconciliationLoaded extends InventoryState {
  final GetStockReconciliationResponse response;
  GetStockReconciliationLoaded(this.response);
}

final class GetStockReconciliationError extends InventoryState {
  final String message;
  GetStockReconciliationError(this.message);
}
final class AddStockTakeLoading extends InventoryState {}

final class AddStockTakeSuccess extends InventoryState {
  final AddStockTakeResponse response;
  AddStockTakeSuccess(this.response);
}

final class AddStockTakeError extends InventoryState {
  final String message;
  AddStockTakeError(this.message);
}
final class GetInventoryDiscountRulesLoading extends InventoryState {}

final class GetInventoryDiscountRulesLoaded extends InventoryState {
  final GetInventoryDiscountRulesResponse response;
  GetInventoryDiscountRulesLoaded(this.response);
}

final class GetInventoryDiscountRulesError extends InventoryState {
  final String message;
  GetInventoryDiscountRulesError(this.message);
}
final class CreateDiscountRuleLoading extends InventoryState {}

final class CreateDiscountRuleSuccess extends InventoryState {
  final CreateDiscountRuleResponse response;
  CreateDiscountRuleSuccess(this.response);
}

final class CreateDiscountRuleError extends InventoryState {
  final String message;
  CreateDiscountRuleError(this.message);
}
final class GetLoyaltyProgramsLoading extends InventoryState {}

final class GetLoyaltyProgramsLoaded extends InventoryState {
  final GetLoyaltyProgramsResponse response;
  GetLoyaltyProgramsLoaded(this.response);
}

final class GetLoyaltyProgramsError extends InventoryState {
  final String message;
  GetLoyaltyProgramsError(this.message);
}
final class CreateLoyaltyProgramLoading extends InventoryState {}

final class CreateLoyaltyProgramSuccess extends InventoryState {
  final CreateLoyaltyProgramResponse response;
  CreateLoyaltyProgramSuccess(this.response);
}

final class CreateLoyaltyProgramError extends InventoryState {
  final String message;
  CreateLoyaltyProgramError(this.message);
}
