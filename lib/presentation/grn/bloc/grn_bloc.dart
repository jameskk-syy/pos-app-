import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/repository/purchase_repo.dart';
import 'package:pos/domain/responses/purchase/grn_response.dart';
import 'package:pos/domain/responses/purchase/grn_detail_response.dart';

part 'grn_event.dart';
part 'grn_state.dart';

class GrnBloc extends Bloc<GrnEvent, GrnState> {
  final PurchaseRepo purchaseRepo;

  GrnBloc({required this.purchaseRepo}) : super(GrnInitial()) {
    on<FetchGrnListEvent>(_onFetchGrnList);
    on<FetchGrnDetailEvent>(_onFetchGrnDetail);
  }

  Future<void> _onFetchGrnList(
    FetchGrnListEvent event,
    Emitter<GrnState> emit,
  ) async {
    emit(GrnListLoading());
    try {
      final response = await purchaseRepo.getGrnList(
        page: event.page,
        pageSize: event.pageSize,
        company: event.company,
        supplier: event.supplier,
        searchTerm: event.searchTerm,
      );
      if (response.data.isEmpty) {
        emit(GrnListEmpty());
      } else {
        emit(GrnListLoaded(response: response));
      }
    } catch (e) {
      emit(GrnListError(message: e.toString()));
    }
  }

  Future<void> _onFetchGrnDetail(
    FetchGrnDetailEvent event,
    Emitter<GrnState> emit,
  ) async {
    emit(GrnDetailLoading());
    try {
      final response = await purchaseRepo.getGrnDetails(event.grnNo);
      emit(GrnDetailLoaded(response: response));
    } catch (e) {
      emit(GrnDetailError(message: e.toString()));
    }
  }
}
