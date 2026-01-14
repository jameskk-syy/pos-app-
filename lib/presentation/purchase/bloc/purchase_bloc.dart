import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pos/domain/repository/purchase_repo.dart';
import 'package:pos/domain/requests/create_grn_request.dart';
import 'package:pos/domain/requests/create_purchase_order_request.dart';
import 'package:pos/domain/requests/submit_purchase_order_request.dart';
import 'package:pos/domain/responses/create_grn_response.dart';
import 'package:pos/domain/responses/create_purchase_order_response.dart' hide PurchaseOrderData;
import 'package:pos/domain/responses/purchase_order_detail_response.dart';
import 'package:pos/domain/responses/purchase_order_response.dart';
import 'package:pos/domain/responses/submit_purchase_order_response.dart';

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
    emit(PurchaseOrderDetailError(
      message: e.toString(),
      poName: event.poName,
    ));
  }
}
  Future<void> _onCreateGrn(
  CreateGrnEvent event,
  Emitter<PurchaseState> emit,
) async {
  emit(GrnCreating());

  try {
    final response = await purchaseRepo.createGrn(
      request: event.request,
    );
    
    emit(GrnCreated(
      response: response,
      message: response.message,
    ));
  } catch (e) {
    emit(GrnCreateError(
      message: e.toString(),
      lpoNo: event.request.lpoNo,
    ));
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
      
      emit(PurchaseOrderSubmitted(
        response: response,
        message: 'Purchase order submitted successfully',
      ));
    } catch (e) {
      emit(PurchaseOrderSubmitError(
        message: e.toString(),
        lpoNo: event.lpoNo,
      ));
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
      
      emit(PurchaseOrderSubmitted(
        response: response,
        message: 'Purchase order resubmitted successfully',
      ));
    } catch (e) {
      emit(PurchaseOrderSubmitError(
        message: e.toString(),
        lpoNo: event.lpoNo,
      ));
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
        filters: event.filters,
      );

      if (response.purchaseOrders.isEmpty) {
        emit(PurchaseEmpty());
      } else {
        emit(PurchaseLoaded(
          purchaseOrders: response.purchaseOrders,
          totalCount: response.totalCount,
        ));
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
        emit(PurchaseLoaded(
          purchaseOrders: response.purchaseOrders,
          totalCount: response.totalCount,
        ));
      }
    } catch (e) {
      emit(PurchaseError(message: e.toString()));
    }
  }
}