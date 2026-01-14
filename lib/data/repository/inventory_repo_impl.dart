import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/models/stock_ledger_entry.dart';
import 'package:pos/domain/repository/inventory_repo.dart';
import 'package:pos/domain/requests/add_stock_take_request.dart';
import 'package:pos/domain/requests/approve_stock_transfer_request.dart';
import 'package:pos/domain/requests/create_discount_rule_request.dart';
import 'package:pos/domain/requests/create_loyalty_program_request.dart';
import 'package:pos/domain/requests/create_material_issue_request.dart';
import 'package:pos/domain/requests/create_material_receipt_request.dart';
import 'package:pos/domain/requests/create_stock_reconciliation_request.dart';
import 'package:pos/domain/requests/create_stock_transfer_request.dart';
import 'package:pos/domain/requests/create_transfer_request.dart';
import 'package:pos/domain/requests/dispatch_stock_transfer_request.dart';
import 'package:pos/domain/requests/get_inventory_discount_rules_request.dart';
import 'package:pos/domain/requests/get_loyalty_programs_request.dart';
import 'package:pos/domain/requests/get_material_requests_request.dart';
import 'package:pos/domain/requests/get_stock_reconciliation_request.dart';
import 'package:pos/domain/requests/get_stock_reconciliations_request.dart';
import 'package:pos/domain/requests/receive_stock_request.dart';
import 'package:pos/domain/requests/stock_entries_request.dart';
import 'package:pos/domain/requests/stock_entry.dart';
import 'package:pos/domain/requests/submit_stock_transfer_request.dart';
import 'package:pos/domain/responses/add_stock_take_response.dart';
import 'package:pos/domain/responses/approve_stock_transfer_response.dart';
import 'package:pos/domain/responses/create_discount_rule_response.dart';
import 'package:pos/domain/responses/create_loyalty_program_response.dart';
import 'package:pos/domain/responses/create_material_issue_response.dart';
import 'package:pos/domain/responses/create_material_receipt_response.dart';
import 'package:pos/domain/responses/create_stock_reconciliation_response.dart';
import 'package:pos/domain/responses/create_stock_transfer_response.dart';
import 'package:pos/domain/responses/create_transfer_response.dart';
import 'package:pos/domain/responses/dispatch_stock_transfer_response.dart';
import 'package:pos/domain/responses/get_inventory_discount_rules_response.dart';
import 'package:pos/domain/responses/get_loyalty_programs_response.dart';
import 'package:pos/domain/responses/get_stock_reconciliation_response.dart';
import 'package:pos/domain/responses/get_stock_transfer_response.dart';
import 'package:pos/domain/responses/low_alert_response.dart';
import 'package:pos/domain/responses/material_requests_response.dart';
import 'package:pos/domain/responses/receive_stock_response.dart';
import 'package:pos/domain/responses/stock_entries_response.dart';
import 'package:pos/domain/responses/stock_entry_response.dart';
import 'package:pos/domain/responses/stock_reconciliations_response.dart';
import 'package:pos/domain/responses/stock_summary_response.dart';
import 'package:pos/domain/responses/submit_stock_transfer_response.dart';

class InventoryRepoImpl implements InventoryRepo {
  final RemoteDataSource remoteDataSource;

  InventoryRepoImpl({required this.remoteDataSource});

  @override
  Future<StockResponses> getLowStock({
    String? warehouse,
    String? company,
    double? threshold,
  }) async {
    return await remoteDataSource.getLowStockAlert(
      warehouse,
      threshold,
      company,
    );
  }

  @override
  Future<StockSummaryResponse> getStockSummary({
    required String company,
    int? limit,
    int? offset,
    String? warehouse,
    String? itemGroup,
    String? search,
  }) async {
    return await remoteDataSource.getStockSummary(
      company: company,
      limit: limit,
      offset: offset,
      warehouse: warehouse,
      itemGroup: itemGroup,
      search: search,
    );
  }

  @override
  Future<CreateMaterialTransferResponse> createMaterialTransfer(
    CreateMaterialTransferRequest request,
  ) async {
    return await remoteDataSource.createMaterialTransferNew(request);
  }

  @override
  Future<StockLedgerResponse> getStockLedger({
    required String company,
    required String warehouse,
    String? voucherType,
    int? limit,
    int? offset,
  }) async {
    return await remoteDataSource.getStockLedgerEntries(
      company: company,
      warehouse: warehouse,
      voucherType: voucherType,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<StockEntriesResponse> getStockEntries({
    required StockEntriesRequest request,
  }) async {
    return await remoteDataSource.getStockEntries(request: request);
  }

  @override
  Future<CreateStockEntryResponse> createStockEntry(
    CreateStockEntryRequest request,
  ) async {
    return await remoteDataSource.createStockEntry(request);
  }

  @override
  Future<CreateMaterialReceiptResponse> createMaterialReceipt(
    CreateMaterialReceiptRequest request,
  ) async {
    return await remoteDataSource.createMaterialReceipt(request);
  }

  @override
  Future<CreateMaterialIssueResponse> createMaterialIssue(
    CreateMaterialIssueRequest request,
  ) async {
    return await remoteDataSource.createMaterialIssue(request);
  }

  @override
  Future<CreateStockTransferResponse> createStockTransfer(
    CreateStockTransferRequest request,
  ) async {
    return await remoteDataSource.createStockTransfer(request);
  }

  @override
  Future<MaterialRequestsResponse> getMaterialRequests({
    required GetMaterialRequestsRequest request,
  }) async {
    return await remoteDataSource.getMaterialRequests(request: request);
  }

  @override
  Future<ApproveStockTransferResponse> approveStockTransfer(
    ApproveStockTransferRequest request,
  ) async {
    return await remoteDataSource.approveStockTransfer(request);
  }

  @override
  Future<SubmitStockTransferResponse> submitStockTransfer(
    SubmitStockTransferRequest request,
  ) async {
    return await remoteDataSource.submitStockTransfer(request);
  }

  @override
  Future<DispatchStockTransferResponse> dispatchStockTransfer(
    DispatchStockTransferRequest request,
  ) async {
    return await remoteDataSource.dispatchStockTransfer(request);
  }

  @override
  Future<GetStockTransferResponse> getStockTransferRequest(
    String requestId,
  ) async {
    return await remoteDataSource.getStockTransferRequest(requestId);
  }

  @override
  Future<ReceiveStockResponse> receiveStock(ReceiveStockRequest request) async {
    return await remoteDataSource.receiveStock(request);
  }

  @override
  Future<StockReconciliationsResponse> getStockReconciliations({
    required GetStockReconciliationsRequest request,
  }) async {
    return await remoteDataSource.getStockReconciliations(request: request);
  }

  @override
  Future<CreateStockReconciliationResponse> createStockReconciliation(
    CreateStockReconciliationRequest request,
  ) async {
    return await remoteDataSource.createStockReconciliation(request);
  }

  @override
  Future<GetStockReconciliationResponse> getStockReconciliation(
    GetStockReconciliationRequest request,
  ) async {
    return await remoteDataSource.getStockReconciliation(request);
  }

  @override
  Future<AddStockTakeResponse> addStockTake(
    AddStockTakeRequest request, {
    StockTakeRole role = StockTakeRole.stockManager,
  }) async {
    return await remoteDataSource.addStockTake(request, role: role);
  }

  @override
  Future<GetInventoryDiscountRulesResponse> getInventoryDiscountRules(
    GetInventoryDiscountRulesRequest request,
  ) async {
    return await remoteDataSource.getInventoryDiscountRules(request);
  }

  @override
  Future<CreateDiscountRuleResponse> createDiscountRule(
    CreateDiscountRuleRequest request,
  ) async {
    return await remoteDataSource.createDiscountRule(request);
  }

  @override
  Future<CreateLoyaltyProgramResponse> createLoyaltyProgram(
    CreateLoyaltyProgramRequest request,
  ) async {
    return await remoteDataSource.createLoyaltyProgram(request);
  }

  @override
  Future<GetLoyaltyProgramsResponse> getLoyaltyPrograms(
    GetLoyaltyProgramsRequest request,
  ) async {
    return await remoteDataSource.getLoyaltyPrograms(request);
  }
}
