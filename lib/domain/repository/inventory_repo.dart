import 'package:pos/domain/models/stock_ledger_entry.dart';
import 'package:pos/domain/requests/inventory/add_stock_take_request.dart';
import 'package:pos/domain/requests/inventory/approve_stock_transfer_request.dart';
import 'package:pos/domain/requests/create_discount_rule_request.dart';
import 'package:pos/domain/requests/crm/create_loyalty_program_request.dart';
import 'package:pos/domain/requests/inventory/create_material_issue_request.dart';
import 'package:pos/domain/requests/inventory/create_material_receipt_request.dart';
import 'package:pos/domain/requests/inventory/create_stock_reconciliation_request.dart';
import 'package:pos/domain/requests/inventory/create_stock_transfer_request.dart';
import 'package:pos/domain/requests/inventory/create_transfer_request.dart';
import 'package:pos/domain/requests/disable_discount_rule_request.dart';
import 'package:pos/domain/requests/enable_discount_rule_request.dart';
import 'package:pos/domain/requests/inventory/dispatch_stock_transfer_request.dart';
import 'package:pos/domain/requests/get_inventory_discount_rules_request.dart';
import 'package:pos/domain/requests/crm/get_loyalty_programs_request.dart';
import 'package:pos/domain/requests/inventory/get_material_requests_request.dart';
import 'package:pos/domain/requests/inventory/get_stock_reconciliation_request.dart';
import 'package:pos/domain/requests/inventory/get_stock_reconciliations_request.dart';
import 'package:pos/domain/requests/inventory/receive_stock_request.dart';
import 'package:pos/domain/requests/inventory/stock_entries_request.dart';
import 'package:pos/domain/requests/inventory/stock_entry.dart';
import 'package:pos/domain/requests/inventory/submit_stock_transfer_request.dart';
import 'package:pos/domain/requests/update_discount_rule_request.dart';
import 'package:pos/domain/responses/inventory/add_stock_take_response.dart';
import 'package:pos/domain/responses/inventory/approve_stock_transfer_response.dart';
import 'package:pos/domain/responses/create_discount_rule_response.dart';
import 'package:pos/domain/responses/crm/create_loyalty_program_response.dart';
import 'package:pos/domain/responses/inventory/create_material_issue_response.dart';
import 'package:pos/domain/responses/inventory/create_material_receipt_response.dart';
import 'package:pos/domain/responses/inventory/create_stock_reconciliation_response.dart';
import 'package:pos/domain/responses/inventory/create_stock_transfer_response.dart';
import 'package:pos/domain/responses/inventory/create_transfer_response.dart';
import 'package:pos/domain/responses/disable_discount_rule_response.dart';
import 'package:pos/domain/responses/enable_discount_rule_response.dart';
import 'package:pos/domain/responses/inventory/dispatch_stock_transfer_response.dart';
import 'package:pos/domain/responses/get_inventory_discount_rules_response.dart';
import 'package:pos/domain/responses/crm/get_loyalty_programs_response.dart';
import 'package:pos/domain/responses/inventory/get_stock_reconciliation_response.dart';
import 'package:pos/domain/responses/inventory/get_stock_transfer_response.dart';
import 'package:pos/domain/responses/inventory/low_alert_response.dart';
import 'package:pos/domain/responses/inventory/material_requests_response.dart';
import 'package:pos/domain/responses/inventory/receive_stock_response.dart';
import 'package:pos/domain/responses/inventory/stock_entries_response.dart';
import 'package:pos/domain/responses/inventory/stock_entry_response.dart';
import 'package:pos/domain/responses/inventory/stock_reconciliations_response.dart';
import 'package:pos/domain/responses/inventory/stock_summary_response.dart';
import 'package:pos/domain/responses/inventory/submit_stock_transfer_response.dart';
import 'package:pos/domain/responses/update_discount_rule_response.dart';

abstract class InventoryRepo {
  Future<StockResponses> getLowStock({
    String? warehouse,
    String? company,
    double? threshold,
  });

  Future<StockSummaryResponse> getStockSummary({
    required String company,
    int? limit,
    int? offset,
    String? warehouse,
    String? itemGroup,
    String? search,
  });

  Future<StockLedgerResponse> getStockLedger({
    required String company,
    required String warehouse,
    String? voucherType,
    int? limit,
    int? offset,
  });
  Future<StockEntriesResponse> getStockEntries({
    required StockEntriesRequest request,
  });
  Future<CreateStockEntryResponse> createStockEntry(
    CreateStockEntryRequest request,
  );
  Future<CreateMaterialReceiptResponse> createMaterialReceipt(
    CreateMaterialReceiptRequest request,
  );
  Future<CreateMaterialIssueResponse> createMaterialIssue(
    CreateMaterialIssueRequest request,
  );

  Future<CreateMaterialTransferResponse> createMaterialTransfer(
    CreateMaterialTransferRequest request,
  );
  Future<CreateStockTransferResponse> createStockTransfer(
    CreateStockTransferRequest request,
  );
  Future<MaterialRequestsResponse> getMaterialRequests({
    required GetMaterialRequestsRequest request,
  });
  Future<ApproveStockTransferResponse> approveStockTransfer(
    ApproveStockTransferRequest request,
  );
  Future<SubmitStockTransferResponse> submitStockTransfer(
    SubmitStockTransferRequest request,
  );
  Future<DispatchStockTransferResponse> dispatchStockTransfer(
    DispatchStockTransferRequest request,
  );
  Future<GetStockTransferResponse> getStockTransferRequest(String requestId);
  Future<ReceiveStockResponse> receiveStock(ReceiveStockRequest request);
  Future<StockReconciliationsResponse> getStockReconciliations({
    required GetStockReconciliationsRequest request,
  });
  Future<CreateStockReconciliationResponse> createStockReconciliation(
    CreateStockReconciliationRequest request,
  );
  Future<GetStockReconciliationResponse> getStockReconciliation(
    GetStockReconciliationRequest request,
  );
  Future<AddStockTakeResponse> addStockTake(
    AddStockTakeRequest request, {
    StockTakeRole role = StockTakeRole.stockManager,
  });
  Future<GetInventoryDiscountRulesResponse> getInventoryDiscountRules(
    GetInventoryDiscountRulesRequest request,
  );
  Future<CreateDiscountRuleResponse> createDiscountRule(
    CreateDiscountRuleRequest request,
  );
  Future<UpdateDiscountRuleResponse> updateDiscountRule(
    UpdateDiscountRuleRequest request,
  );
  Future<DisableDiscountRuleResponse> disableDiscountRule(
    DisableDiscountRuleRequest request,
  );
  Future<EnableDiscountRuleResponse> enableDiscountRule(
    EnableDiscountRuleRequest request,
  );
  Future<CreateLoyaltyProgramResponse> createLoyaltyProgram(
    CreateLoyaltyProgramRequest request,
  );
  Future<GetLoyaltyProgramsResponse> getLoyaltyPrograms(
    GetLoyaltyProgramsRequest request,
  );
}
