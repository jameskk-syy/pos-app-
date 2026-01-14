// lib/presentation/bloc/inventory_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
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
part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepo inventoryRepo;

  InventoryBloc({required this.inventoryRepo}) : super(InventoryInitial()) {
    on<GetLowStock>(_getLowStock);
    on<GetStockSummary>(_getStockSummary);
    on<CreateMaterialTransfer>(_createMaterialTransfer);
    on<CreateStockEntry>(_createStockEntry);
    on<GetStockLedger>(_getStockLedger);
    on<GetStockEntries>(_getStockEntries);
    on<CreateMaterialReceipt>(_createMaterialReceipt);
    on<CreateMaterialIssue>(_createMaterialIssue);
    on<CreateStockTransfer>(_createStockTransfer);
    on<GetMaterialRequests>(_getMaterialRequests);
    on<ApproveStockTransfer>(_approveStockTransfer);
    on<SubmitStockTransfer>(_submitStockTransfer);
    on<DispatchStockTransfer>(_dispatchStockTransfer);
    on<GetStockTransferRequest>(_getStockTransferRequest);
    on<ReceiveStock>(_receiveStock);
    on<GetStockReconciliation>(_getStockReconciliation);
    on<GetStockReconciliations>(_getStockReconciliations);
    on<CreateStockReconciliation>(_createStockReconciliation);
    on<AddStockTake>(_addStockTake);
    on<GetInventoryDiscountRules>(_getInventoryDiscountRules);
    on<CreateDiscountRule>(_createDiscountRule);
    on<CreateLoyaltyProgram>(_createLoyaltyProgram);
    on<GetLoyaltyPrograms>(_getLoyaltyPrograms);
  }
  FutureOr<void> _getLoyaltyPrograms(
    GetLoyaltyPrograms event,
    Emitter<InventoryState> emit,
  ) async {
    emit(GetLoyaltyProgramsLoading());
    debugPrint("Fetching loyalty programs...");

    try {
      final response = await inventoryRepo.getLoyaltyPrograms(event.request);
      emit(GetLoyaltyProgramsLoaded(response));
      debugPrint(
        "Loyalty programs fetched: ${response.message.totalPrograms} programs",
      );
    } catch (e) {
      debugPrint("Error fetching loyalty programs: $e");
      emit(GetLoyaltyProgramsError(e.toString()));
    }
  }

  FutureOr<void> _createLoyaltyProgram(
    CreateLoyaltyProgram event,
    Emitter<InventoryState> emit,
  ) async {
    emit(CreateLoyaltyProgramLoading());
    debugPrint("Creating loyalty program: ${event.request.loyaltyProgramName}");

    try {
      final response = await inventoryRepo.createLoyaltyProgram(event.request);
      emit(CreateLoyaltyProgramSuccess(response));
      debugPrint(
        "Loyalty program created successfully: ${response.message.loyaltyProgram.name}",
      );
    } catch (e) {
      debugPrint("Error creating loyalty program: $e");
      emit(CreateLoyaltyProgramError(e.toString()));
    }
  }

  FutureOr<void> _createDiscountRule(
    CreateDiscountRule event,
    Emitter<InventoryState> emit,
  ) async {
    emit(CreateDiscountRuleLoading());
    debugPrint("Creating inventory discount rule...");

    try {
      final response = await inventoryRepo.createDiscountRule(event.request);
      emit(CreateDiscountRuleSuccess(response));
      debugPrint(
        "Discount rule created successfully: ${response.message.data.name}",
      );
    } catch (e) {
      debugPrint("Error creating discount rule: $e");
      emit(CreateDiscountRuleError(e.toString()));
    }
  }

  FutureOr<void> _getInventoryDiscountRules(
    GetInventoryDiscountRules event,
    Emitter<InventoryState> emit,
  ) async {
    emit(GetInventoryDiscountRulesLoading());
    debugPrint("Getting inventory discount rules...");

    try {
      final response = await inventoryRepo.getInventoryDiscountRules(
        event.request,
      );
      emit(GetInventoryDiscountRulesLoaded(response));
      debugPrint(
        "Inventory discount rules fetched: ${response.message.data.rules.length} items",
      );
    } catch (e) {
      debugPrint("Error getting inventory discount rules: $e");
      emit(GetInventoryDiscountRulesError(e.toString()));
    }
  }

  FutureOr<void> _addStockTake(
    AddStockTake event,
    Emitter<InventoryState> emit,
  ) async {
    emit(AddStockTakeLoading());
    debugPrint("Adding stock take: ${event.request.reconciliationName}");

    try {
      final response = await inventoryRepo.addStockTake(
        event.request,
        role: event.role,
      );
      emit(AddStockTakeSuccess(response));
      debugPrint(
        "Stock take added successfully: ${response.message.data.reconciliationName} - ${response.message.data.workflowStatus}",
      );
    } catch (e) {
      debugPrint("Error adding stock take: $e");
      emit(AddStockTakeError(e.toString()));
    }
  }

  FutureOr<void> _getStockReconciliation(
    GetStockReconciliation event,
    Emitter<InventoryState> emit,
  ) async {
    emit(GetStockReconciliationLoading());
    debugPrint(
      "Getting stock reconciliation: ${event.request.reconciliationName}",
    );

    try {
      final response = await inventoryRepo.getStockReconciliation(
        event.request,
      );
      emit(GetStockReconciliationLoaded(response));
      debugPrint(
        "Stock reconciliation fetched: ${response.message.data.name} - ${response.message.data.workflowStatus}",
      );
    } catch (e) {
      debugPrint("Error getting stock reconciliation: $e");
      emit(GetStockReconciliationError(e.toString()));
    }
  }

  FutureOr<void> _createStockReconciliation(
    CreateStockReconciliation event,
    Emitter<InventoryState> emit,
  ) async {
    emit(CreateStockReconciliationLoading());
    debugPrint("Creating stock reconciliation...");

    try {
      final response = await inventoryRepo.createStockReconciliation(
        event.request,
      );
      emit(CreateStockReconciliationSuccess(response));
      debugPrint(
        "Stock reconciliation created successfully: ${response.message.data.name} - ${response.message.data.workflowStatus}",
      );
    } catch (e) {
      debugPrint("Error creating stock reconciliation: $e");
      emit(CreateStockReconciliationError(e.toString()));
    }
  }

  FutureOr<void> _getStockReconciliations(
    GetStockReconciliations event,
    Emitter<InventoryState> emit,
  ) async {
    emit(StockReconciliationsLoading());
    debugPrint("Fetching stock reconciliations...");

    try {
      final response = await inventoryRepo.getStockReconciliations(
        request: event.request,
      );
      emit(StockReconciliationsLoaded(response));
      debugPrint(
        "Stock reconciliations fetched: ${response.message.data.reconciliations.length} items (${response.message.data.totalCount} total)",
      );
    } catch (e) {
      debugPrint("Error fetching stock reconciliations: $e");
      emit(StockReconciliationsError(e.toString()));
    }
  }

  FutureOr<void> _receiveStock(
    ReceiveStock event,
    Emitter<InventoryState> emit,
  ) async {
    emit(ReceiveStockLoading());
    debugPrint("Receiving stock: ${event.request.requestId}");

    try {
      final response = await inventoryRepo.receiveStock(event.request);
      emit(ReceiveStockSuccess(response));
      debugPrint(
        "Stock received successfully: ${response.data?.stockEntry} - ${response.data?.status}",
      );
    } catch (e) {
      debugPrint("Error receiving stock: $e");
      emit(ReceiveStockError(e.toString()));
    }
  }

  FutureOr<void> _getStockTransferRequest(
    GetStockTransferRequest event,
    Emitter<InventoryState> emit,
  ) async {
    emit(StockTransferRequestLoading());
    debugPrint("Fetching stock transfer request: ${event.requestId}");

    try {
      final response = await inventoryRepo.getStockTransferRequest(
        event.requestId,
      );
      emit(StockTransferRequestLoaded(response));
      debugPrint(
        "Stock transfer request fetched: ${response.message.data.name} - ${response.message.data.status}",
      );
    } catch (e) {
      debugPrint("Error fetching stock transfer request: $e");
      emit(StockTransferRequestError(e.toString()));
    }
  }

  FutureOr<void> _dispatchStockTransfer(
    DispatchStockTransfer event,
    Emitter<InventoryState> emit,
  ) async {
    emit(DispatchStockTransferLoading());
    debugPrint("Dispatching stock transfer: ${event.request.requestId}");

    try {
      final response = await inventoryRepo.dispatchStockTransfer(event.request);
      emit(DispatchStockTransferSuccess(response));
      debugPrint(
        "Stock dispatched successfully: ${response.message.data.stockEntry} - ${response.message.data.status}",
      );
    } catch (e) {
      debugPrint("Error dispatching stock transfer: $e");
      emit(DispatchStockTransferError(e.toString()));
    }
  }

  FutureOr<void> _submitStockTransfer(
    SubmitStockTransfer event,
    Emitter<InventoryState> emit,
  ) async {
    emit(SubmitStockTransferLoading());
    debugPrint("Submitting stock transfer request: ${event.request.requestId}");

    try {
      final response = await inventoryRepo.submitStockTransfer(event.request);
      emit(SubmitStockTransferSuccess(response));
      debugPrint(
        "Stock transfer submitted successfully: ${response.message.data.requestId} - ${response.message.data.status}",
      );
    } catch (e) {
      debugPrint("Error submitting stock transfer: $e");
      emit(SubmitStockTransferError(e.toString()));
    }
  }

  FutureOr<void> _approveStockTransfer(
    ApproveStockTransfer event,
    Emitter<InventoryState> emit,
  ) async {
    emit(ApproveStockTransferLoading());
    debugPrint("Approving stock transfer: ${event.request.requestId}");

    try {
      final response = await inventoryRepo.approveStockTransfer(event.request);
      emit(ApproveStockTransferSuccess(response));
      debugPrint(
        "Stock transfer approved: ${response.data.requestId} - ${response.data.approvalStatus}",
      );
    } catch (e) {
      debugPrint("Error approving stock transfer: $e");
      emit(ApproveStockTransferError(e.toString()));
    }
  }

  FutureOr<void> _getMaterialRequests(
    GetMaterialRequests event,
    Emitter<InventoryState> emit,
  ) async {
    emit(MaterialRequestsLoading());
    debugPrint("Fetching material requests...");

    try {
      final response = await inventoryRepo.getMaterialRequests(
        request: event.request,
      );
      emit(MaterialRequestsLoaded(response));
      debugPrint(
        "Material requests fetched: ${response.data.requests.length} items",
      );
    } catch (e) {
      debugPrint("Error fetching material requests: $e");
      emit(MaterialRequestsError(e.toString()));
    }
  }

  FutureOr<void> _createStockTransfer(
    CreateStockTransfer event,
    Emitter<InventoryState> emit,
  ) async {
    emit(CreateStockTransferLoading());
    debugPrint("Creating stock transfer request...");

    try {
      final response = await inventoryRepo.createStockTransfer(event.request);
      emit(CreateStockTransferSuccess(response));
      debugPrint(
        "Stock transfer request created: ${response.message.data.materialRequest}",
      );
    } catch (e) {
      debugPrint("Error creating stock transfer request: $e");
      emit(CreateStockTransferError(e.toString()));
    }
  }

  FutureOr<void> _createMaterialIssue(
    CreateMaterialIssue event,
    Emitter<InventoryState> emit,
  ) async {
    emit(CreateMaterialIssueLoading());
    debugPrint("Creating material issue...");

    try {
      final response = await inventoryRepo.createMaterialIssue(event.request);
      emit(CreateMaterialIssueSuccess(response));
      debugPrint("Material issue created: ${response.data?.name}");
    } catch (e) {
      debugPrint("Error creating material issue: $e");
      emit(CreateMaterialIssueError(e.toString()));
    }
  }

  FutureOr<void> _createMaterialReceipt(
    CreateMaterialReceipt event,
    Emitter<InventoryState> emit,
  ) async {
    emit(CreateMaterialReceiptLoading());
    debugPrint("Creating material receipt...");

    try {
      final response = await inventoryRepo.createMaterialReceipt(event.request);
      emit(CreateMaterialReceiptSuccess(response));
      debugPrint("Material receipt created: ${response.data?.name}");
    } catch (e) {
      debugPrint("Error creating material receipt: $e");
      emit(CreateMaterialReceiptError(e.toString()));
    }
  }

  FutureOr<void> _getStockEntries(
    GetStockEntries event,
    Emitter<InventoryState> emit,
  ) async {
    emit(StockEntriesLoading());
    debugPrint("sxcbhajcgvhrgvfhj");
    try {
      final request = StockEntriesRequest(
        company: event.company,
        page: event.page,
        pageSize: event.pageSize,
        stockEntryType: event.stockEntryType,
        warehouse: event.warehouse,
        docstatus: event.docstatus,
      );

      final response = await inventoryRepo.getStockEntries(request: request);
      emit(StockEntriesLoaded(response));
    } catch (e) {
      emit(StockEntriesError(e.toString()));
    }
  }

  FutureOr<void> _getLowStock(
    GetLowStock event,
    Emitter<InventoryState> emit,
  ) async {
    emit(LowStockLoading());

    try {
      final response = await inventoryRepo.getLowStock(
        warehouse: event.warehouse,
        threshold: event.threshold,
        company: event.company,
      );

      emit(LowStockLoaded(response));
    } catch (e) {
      emit(LowStockError(e.toString()));
    }
  }

  FutureOr<void> _createStockEntry(
    CreateStockEntry event,
    Emitter<InventoryState> emit,
  ) async {
    emit(CreateStockEntryLoading());

    try {
      final response = await inventoryRepo.createStockEntry(event.request);
      emit(CreateStockEntrySuccess(response));
    } catch (e) {
      emit(CreateStockEntryError(e.toString()));
    }
  }

  FutureOr<void> _getStockSummary(
    GetStockSummary event,
    Emitter<InventoryState> emit,
  ) async {
    emit(StockSummaryLoading());

    try {
      final response = await inventoryRepo.getStockSummary(
        company: event.company,
        limit: event.limit,
        offset: event.offset,
        warehouse: event.warehouse,
        itemGroup: event.itemGroup,
        search: event.search,
      );

      emit(StockSummaryLoaded(response));
    } catch (e) {
      emit(StockSummaryError(e.toString()));
    }
  }

  FutureOr<void> _createMaterialTransfer(
    CreateMaterialTransfer event,
    Emitter<InventoryState> emit,
  ) async {
    emit(CreateMaterialTransferLoading());
    debugPrint("Creating material transfer...");

    try {
      final response = await inventoryRepo.createMaterialTransfer(
        event.request,
      );
      emit(CreateMaterialTransferSuccess(response));
      debugPrint("Material transfer created: ${response.data.name}");
    } catch (e) {
      debugPrint("Error creating material transfer: $e");
      emit(CreateMaterialTransferError(e.toString()));
    }
  }

  FutureOr<void> _getStockLedger(
    GetStockLedger event,
    Emitter<InventoryState> emit,
  ) async {
    emit(StockLedgerLoading());

    try {
      final response = await inventoryRepo.getStockLedger(
        company: event.company,
        warehouse: event.warehouse,
        voucherType: event.voucherType,
        limit: event.limit,
        offset: event.offset,
      );

      emit(StockLedgerLoaded(response));
    } catch (e) {
      emit(StockLedgerError(e.toString()));
    }
  }
}
