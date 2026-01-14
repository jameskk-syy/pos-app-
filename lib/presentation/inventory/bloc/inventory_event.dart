part of 'inventory_bloc.dart';

@immutable
sealed class InventoryEvent {}

class GetLowStock extends InventoryEvent {
  final String? warehouse;
  final String? company;
  final double? threshold;

  GetLowStock({this.warehouse, this.threshold, this.company});
}

class GetStockSummary extends InventoryEvent {
  final String company;
  final int? limit;
  final int? offset;
  final String? warehouse;
  final String? itemGroup;
  final String? search;

  GetStockSummary({
    required this.company,
    this.limit = 20,
    this.offset = 0,
    this.warehouse,
    this.itemGroup,
    this.search,
  });
}

class CreateMaterialTransfer extends InventoryEvent {
  final CreateMaterialTransferRequest request;

  CreateMaterialTransfer({required this.request});
}

class CreateStockEntry extends InventoryEvent {
  final CreateStockEntryRequest request;

  CreateStockEntry({required this.request});
}

class ExportLowStockCSV extends InventoryEvent {
  final String? warehouse;
  final double? threshold;

  ExportLowStockCSV({this.warehouse, this.threshold});
}

class GetStockLedger extends InventoryEvent {
  final String company;
  final String warehouse;
  final String? voucherType;
  final int? limit;
  final int? offset;

  GetStockLedger({
    required this.company,
    required this.warehouse,
    this.voucherType,
    this.limit,
    this.offset,
  });
}

class GetStockEntries extends InventoryEvent {
  final String company;
  final int page;
  final int pageSize;
  final String? stockEntryType;
  final String? warehouse;
  final int? docstatus;

  GetStockEntries({
    required this.company,
    this.page = 1,
    this.pageSize = 20,
    this.stockEntryType,
    this.warehouse,
    this.docstatus,
  });
}

class CreateMaterialReceipt extends InventoryEvent {
  final CreateMaterialReceiptRequest request;

  CreateMaterialReceipt({required this.request});
}

class CreateMaterialIssue extends InventoryEvent {
  final CreateMaterialIssueRequest request;

  CreateMaterialIssue({required this.request});
}

class CreateStockTransfer extends InventoryEvent {
  final CreateStockTransferRequest request;

  CreateStockTransfer({required this.request});
}

class GetMaterialRequests extends InventoryEvent {
  final GetMaterialRequestsRequest request;

  GetMaterialRequests({required this.request});
}

class ApproveStockTransfer extends InventoryEvent {
  final ApproveStockTransferRequest request;

  ApproveStockTransfer({required this.request});
}

class SubmitStockTransfer extends InventoryEvent {
  final SubmitStockTransferRequest request;

  SubmitStockTransfer({required this.request});
}

class DispatchStockTransfer extends InventoryEvent {
  final DispatchStockTransferRequest request;

  DispatchStockTransfer({required this.request});
}

class GetStockTransferRequest extends InventoryEvent {
  final String requestId;

  GetStockTransferRequest({required this.requestId});
}

class ReceiveStock extends InventoryEvent {
  final ReceiveStockRequest request;

  ReceiveStock({required this.request});
}

class GetStockReconciliations extends InventoryEvent {
  final GetStockReconciliationsRequest request;

  GetStockReconciliations({required this.request});
}

class CreateStockReconciliation extends InventoryEvent {
  final CreateStockReconciliationRequest request;

  CreateStockReconciliation({required this.request});
}

class GetStockReconciliation extends InventoryEvent {
  final GetStockReconciliationRequest request;

  GetStockReconciliation({required this.request});
}

class AddStockTake extends InventoryEvent {
  final AddStockTakeRequest request;
  final StockTakeRole role;

  AddStockTake({required this.request, this.role = StockTakeRole.stockManager});
}

class GetInventoryDiscountRules extends InventoryEvent {
  final GetInventoryDiscountRulesRequest request;

  GetInventoryDiscountRules({required this.request});
}

class CreateDiscountRule extends InventoryEvent {
  final CreateDiscountRuleRequest request;

  CreateDiscountRule({required this.request});
}

class CreateLoyaltyProgram extends InventoryEvent {
  final CreateLoyaltyProgramRequest request;

  CreateLoyaltyProgram({required this.request});
}

class GetLoyaltyPrograms extends InventoryEvent {
  final GetLoyaltyProgramsRequest request;

  GetLoyaltyPrograms({required this.request});
}
