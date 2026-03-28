import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pos/domain/repository/purchase_repo.dart';
import 'package:pos/domain/requests/purchase/create_grn_request.dart';
import 'package:pos/domain/requests/purchase/create_purchase_order_request.dart';
import 'package:pos/domain/requests/purchase/submit_purchase_order_request.dart';
import 'package:pos/domain/responses/purchase/create_grn_response.dart';
import 'package:pos/domain/responses/purchase/create_purchase_order_response.dart'
    hide PurchaseOrderData;
import 'package:pos/domain/responses/purchase/purchase_order_detail_response.dart';
import 'package:pos/domain/responses/purchase/purchase_order_response.dart';
import 'package:pos/domain/responses/purchase/submit_purchase_order_response.dart';
import 'package:pos/domain/requests/purchase/create_purchase_return_request.dart';
import 'package:pos/domain/responses/purchase/create_purchase_return_response.dart';
import 'package:pos/domain/responses/purchase/list_purchase_returns_response.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRepo purchaseRepo;

  PurchaseBloc({required this.purchaseRepo}) : super(PurchaseInitial()) {
    on<FetchPurchaseOrdersEvent>(_onFetchPurchaseOrders);
    on<RefreshPurchaseOrdersEvent>(_onRefreshPurchaseOrders);
    on<CreatePurchaseOrderEvent>(_onCreatePurchaseOrder);
    on<SubmitPurchaseOrderEvent>(_onSubmitPurchaseOrder);
    on<ResubmitPurchaseOrderEvent>(_onResubmitPurchaseOrder);
    on<CreateGrnEvent>(_onCreateGrn);
    on<FetchPurchaseOrderDetailEvent>(_onFetchPurchaseOrderDetail);
    on<CreatePurchaseReturnEvent>(_onCreatePurchaseReturn);
    on<FetchPurchaseReturnsEvent>(_onFetchPurchaseReturns);
  }
  Future<void> _onFetchPurchaseOrderDetail(
    FetchPurchaseOrderDetailEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseOrderDetailLoading());

    try {
      final response = await purchaseRepo.getPurchaseOrderDetail(
        poName: event.poName,
      );

      emit(PurchaseOrderDetailLoaded(response: response));
    } catch (e) {
      emit(
        PurchaseOrderDetailError(message: e.toString(), poName: event.poName),
      );
    }
  }

  Future<void> _onCreateGrn(
    CreateGrnEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(GrnCreating());

    try {
      final response = await purchaseRepo.createGrn(request: event.request);

      emit(GrnCreated(response: response, message: response.message));
    } catch (e) {
      emit(GrnCreateError(message: e.toString(), lpoNo: event.request.lpoNo));
    }
  }

  Future<void> _onSubmitPurchaseOrder(
    SubmitPurchaseOrderEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseOrderSubmitting(lpoNo: event.lpoNo));

    try {
      final request = SubmitPurchaseOrderRequest(lpoNo: event.lpoNo);
      final response = await purchaseRepo.submitPurchaseOrder(request: request);

      emit(
        PurchaseOrderSubmitted(
          response: response,
          message: 'Purchase order submitted successfully',
        ),
      );
    } catch (e) {
      emit(PurchaseOrderSubmitError(message: e.toString(), lpoNo: event.lpoNo));
    }
  }

  Future<void> _onResubmitPurchaseOrder(
    ResubmitPurchaseOrderEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseOrderSubmitting(lpoNo: event.lpoNo));

    try {
      final request = SubmitPurchaseOrderRequest(lpoNo: event.lpoNo);
      final response = await purchaseRepo.submitPurchaseOrder(request: request);

      emit(
        PurchaseOrderSubmitted(
          response: response,
          message: 'Purchase order resubmitted successfully',
        ),
      );
    } catch (e) {
      emit(PurchaseOrderSubmitError(message: e.toString(), lpoNo: event.lpoNo));
    }
  }

  Future<void> _onCreatePurchaseOrder(
    CreatePurchaseOrderEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseOrderCreating());

    try {
      final response = await purchaseRepo.createPurchaseOrder(
        request: event.request,
      );

      emit(PurchaseOrderCreated(response: response));
    } catch (e) {
      emit(PurchaseOrderCreateError(message: e.toString()));
    }
  }

  Future<void> _onFetchPurchaseOrders(
    FetchPurchaseOrdersEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());

    try {
      final response = await purchaseRepo.getPurchaseOrders(
        company: event.company,
        limit: event.limit,
        offset: event.offset,
        status: event.status,
        searchTerm: event.searchTerm,
        filters: event.filters,
      );

      if (response.purchaseOrders.isEmpty) {
        emit(PurchaseEmpty());
      } else {
        emit(
          PurchaseLoaded(
            purchaseOrders: response.purchaseOrders,
            totalCount: response.totalCount,
          ),
        );
      }
    } catch (e) {
      emit(PurchaseError(message: e.toString()));
    }
  }

  Future<void> _onRefreshPurchaseOrders(
    RefreshPurchaseOrdersEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    // Don't show loading for refresh
    try {
      final response = await purchaseRepo.getPurchaseOrders(
        company: event.company,
        limit: 20,
        offset: 0,
      );

      if (response.purchaseOrders.isEmpty) {
        emit(PurchaseEmpty());
      } else {
        emit(
          PurchaseLoaded(
            purchaseOrders: response.purchaseOrders,
            totalCount: response.totalCount,
          ),
        );
      }
    } catch (e) {
      emit(PurchaseError(message: e.toString()));
    }
  }

  Future<void> _onCreatePurchaseReturn(
    CreatePurchaseReturnEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseReturnCreating());
    try {
      final response = await purchaseRepo.createPurchaseReturn(event.request);
      emit(PurchaseReturnCreated(response: response));
    } catch (e) {
      emit(PurchaseReturnError(message: e.toString()));
    }
  }

  Future<void> _onFetchPurchaseReturns(
    FetchPurchaseReturnsEvent event,
    Emitter<PurchaseState> emit,
  ) async {
    if (event.isRefresh) {
      emit(PurchaseReturnsLoading());
    }

    try {
      final response = await purchaseRepo.listPurchaseReturns(
        company: event.company,
        page: event.page,
        pageSize: event.pageSize,
        searchTerm: event.searchTerm,
      );

      final hasReachedMax = response.data.returns.length < event.pageSize;

      if (state is PurchaseReturnsLoaded && !event.isRefresh) {
        final currentState = state as PurchaseReturnsLoaded;
        final allReturns = List<PurchaseReturnListItem>.from(currentState.response.data.returns)
          ..addAll(response.data.returns);
        
        // This is a bit tricky because the ListPurchaseReturnsResponse structure
        // We'll just emit a new response with merged data
        final mergedResponse = ListPurchaseReturnsResponse(
          status: response.status,
          message: response.message,
          data: PurchaseReturnsData(
            returns: allReturns,
            meta: response.data.meta,
          ),
        );
        emit(PurchaseReturnsLoaded(response: mergedResponse, hasReachedMax: hasReachedMax));
      } else {
        emit(PurchaseReturnsLoaded(response: response, hasReachedMax: hasReachedMax));
      }
    } catch (e) {
      emit(PurchaseReturnsError(message: e.toString()));
    }
  }
}
