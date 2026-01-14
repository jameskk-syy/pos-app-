import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'brands_event.dart';
import 'brands_state.dart';

class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  final ProductsRepo productsRepo;

  BrandsBloc({required this.productsRepo}) : super(BrandsInitial()) {
    on<LoadBrands>(_onLoadBrands);
    on<SearchBrands>(_onSearchBrands);
    on<CreateBrand>(_onCreateBrand);
    on<UpdateBrand>(_onUpdateBrand);
  }

  Future<void> _onLoadBrands(
    LoadBrands event,
    Emitter<BrandsState> emit,
  ) async {
    emit(BrandsLoading());
    try {
      final response = await productsRepo.getBrand();
      emit(
        BrandsLoaded(
          allBrands: response.brands,
          filteredBrands: response.brands,
        ),
      );
    } catch (e) {
      emit(BrandsError(e.toString()));
    }
  }

  void _onSearchBrands(SearchBrands event, Emitter<BrandsState> emit) {
    if (state is BrandsLoaded) {
      final currentState = state as BrandsLoaded;
      if (event.query.isEmpty) {
        emit(
          BrandsLoaded(
            allBrands: currentState.allBrands,
            filteredBrands: currentState.allBrands,
          ),
        );
      } else {
        final filtered = currentState.allBrands
            .where(
              (brand) => brand.brandName.toLowerCase().contains(
                event.query.toLowerCase(),
              ),
            )
            .toList();
        emit(
          BrandsLoaded(
            allBrands: currentState.allBrands,
            filteredBrands: filtered,
          ),
        );
      }
    }
  }

  Future<void> _onCreateBrand(
    CreateBrand event,
    Emitter<BrandsState> emit,
  ) async {
    emit(BrandsLoading());
    try {
      await productsRepo.createBrand(event.company, event.brandName);
      emit(const BrandsActionSuccess("Brand created successfully"));
      add(LoadBrands());
    } catch (e) {
      emit(BrandsError(e.toString()));
      add(LoadBrands());
    }
  }

  Future<void> _onUpdateBrand(
    UpdateBrand event,
    Emitter<BrandsState> emit,
  ) async {
    emit(BrandsLoading());
    try {
      await productsRepo.updateBrand(event.oldBrandName, event.newBrandName);
      emit(const BrandsActionSuccess("Brand updated successfully"));
      add(LoadBrands());
    } catch (e) {
      emit(BrandsError(e.toString()));
      add(LoadBrands());
    }
  }
}
