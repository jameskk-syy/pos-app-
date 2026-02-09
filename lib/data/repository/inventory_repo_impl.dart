import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';
import 'package:pos/data/datasource/inventory_datasource.dart';
import 'package:pos/data/datasource/crm_datasource.dart';
import 'package:pos/domain/models/stock_ledger_entry.dart';
import 'package:pos/domain/repository/inventory_repo.dart';
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

class InventoryRepoImpl implements InventoryRepo {
  final InventoryRemoteDataSource remoteDataSource;
  final CrmRemoteDataSource crmRemoteDataSource;

  final ConnectivityService connectivityService;
  final LocalDataSource localDataSource;

  InventoryRepoImpl({
    required this.remoteDataSource,
    required this.crmRemoteDataSource,
    required this.connectivityService,
    required this.localDataSource,
  });

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
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      try {
        final response = await remoteDataSource.getInventoryDiscountRules(
          request,
        );
        // Cache the rules
        await localDataSource.cacheInventoryRules(
          response.message.data.rules.map((e) => e.toJson()).toList(),
        );
        return response;
      } catch (e) {
        rethrow;
      }
    } else {
      // Offline fallback
      final cached = localDataSource.getCachedInventoryRules();
      if (cached.isNotEmpty) {
        final rules = cached
            .map((e) => InventoryDiscountRule.fromJson(e))
            .toList();
        return GetInventoryDiscountRulesResponse(
          message: InventoryDiscountRulesMessage(
            success: true,
            data: InventoryDiscountRulesData(
              rules: rules,
              pagination: PaginationData(
                page: 1,
                pageSize: rules.length,
                total: rules.length,
                totalPages: 1,
              ),
            ),
          ),
        );
      } else {
        throw Exception('No internet connection and no cached discount rules.');
      }
    }
  }

  @override
  Future<CreateDiscountRuleResponse> createDiscountRule(
    CreateDiscountRuleRequest request,
  ) async {
    return await remoteDataSource.createDiscountRule(request);
  }

  @override
  Future<UpdateDiscountRuleResponse> updateDiscountRule(
    UpdateDiscountRuleRequest request,
  ) async {
    return await remoteDataSource.updateDiscountRule(request);
  }

  @override
  Future<DisableDiscountRuleResponse> disableDiscountRule(
    DisableDiscountRuleRequest request,
  ) async {
    return await remoteDataSource.disableDiscountRule(request);
  }

  @override
  Future<EnableDiscountRuleResponse> enableDiscountRule(
    EnableDiscountRuleRequest request,
  ) async {
    return await remoteDataSource.enableDiscountRule(request);
  }

  @override
  Future<CreateLoyaltyProgramResponse> createLoyaltyProgram(
    CreateLoyaltyProgramRequest request,
  ) async {
    return await crmRemoteDataSource.createLoyaltyProgram(request);
  }

  @override
  Future<GetLoyaltyProgramsResponse> getLoyaltyPrograms(
    GetLoyaltyProgramsRequest request,
  ) async {
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      try {
        final response = await crmRemoteDataSource.getLoyaltyPrograms(request);
        // Cache the programs
        await localDataSource.cacheLoyaltyPrograms(
          response.message.programs.map((e) => e.toJson()).toList(),
        );
        return response;
      } catch (e) {
        rethrow;
      }
    } else {
      // Offline fallback
      final cached = localDataSource.getCachedLoyaltyPrograms();
      if (cached.isNotEmpty) {
        final programs = cached
            .map((e) => LoyaltyProgramItem.fromJson(e))
            .toList();
        return GetLoyaltyProgramsResponse(
          message: LoyaltyProgramsMessage(
            status: 'success',
            message: 'Loaded from cache',
            programs: programs,
            totalPrograms: programs.length,
          ),
        );
      } else {
        throw Exception(
          'No internet connection and no cached loyalty programs.',
        );
      }
    }
  }
}
