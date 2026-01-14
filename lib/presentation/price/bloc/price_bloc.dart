import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/presentation/price/bloc/price_event.dart';
import 'package:pos/presentation/price/bloc/price_state.dart';

class PriceBloc extends Bloc<PriceEvent, PriceState> {
  final ProductsRepo productsRepo;

  PriceBloc({required this.productsRepo}) : super(PriceInitial()) {
    on<SetProductPriceEvent>(_onSetProductPrice);
  }

  Future<void> _onSetProductPrice(
    SetProductPriceEvent event,
    Emitter<PriceState> emit,
  ) async {
    emit(PriceLoading());
    try {
      await productsRepo.setProductPrice(
        itemCode: event.itemCode,
        price: event.price,
        priceList: event.priceList,
        currency: event.currency,
      );
      emit(PriceSuccess('Product price set successfully'));
    } catch (e) {
      emit(PriceFailure(e.toString()));
    }
  }
}
