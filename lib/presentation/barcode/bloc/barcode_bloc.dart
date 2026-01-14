import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/repository/products_repo.dart';

part 'barcode_event.dart';
part 'barcode_state.dart';

class BarcodeBloc extends Bloc<BarcodeEvent, BarcodeState> {
  final ProductsRepo productsRepo;

  BarcodeBloc({required this.productsRepo}) : super(BarcodeInitial()) {
    on<AddBarcodeEvent>(_onAddBarcode);
  }

  Future<void> _onAddBarcode(
    AddBarcodeEvent event,
    Emitter<BarcodeState> emit,
  ) async {
    emit(BarcodeLoading());
    try {
      await productsRepo.addBarcode(event.itemCode, event.barcode);
      emit(BarcodeSuccess('Barcode added successfully'));
    } catch (e) {
      emit(BarcodeFailure(e.toString()));
    }
  }
}
