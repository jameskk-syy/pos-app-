import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/domain/responses/uom_response.dart';

part 'units_event.dart';
part 'units_state.dart';

class UnitsBloc extends Bloc<UnitsEvent, UnitsState> {
  final ProductsRepo productsRepo;
  List<UOM> _allUoms = [];

  UnitsBloc({required this.productsRepo}) : super(UnitsInitial()) {
    on<LoadUnits>(_onLoadUnits);
    on<SearchUnits>(_onSearchUnits);
    on<CreateUnit>(_onCreateUnit);
    on<UpdateUnit>(_onUpdateUnit);
    on<DeleteUnit>(_onDeleteUnit);
  }

  Future<void> _onLoadUnits(LoadUnits event, Emitter<UnitsState> emit) async {
    emit(UnitsLoading());
    try {
      final response = await productsRepo.getUnitOfmeasure();
      _allUoms = response.uoms;
      emit(UnitsLoaded(uoms: _allUoms, filteredUoms: _allUoms));
    } catch (e) {
      emit(UnitsError(e.toString()));
    }
  }

  void _onSearchUnits(SearchUnits event, Emitter<UnitsState> emit) {
    if (state is UnitsLoaded) {
      final query = event.query.toLowerCase();
      final filtered = _allUoms.where((uom) {
        return uom.name.toLowerCase().contains(query) ||
            uom.uomName.toLowerCase().contains(query);
      }).toList();
      emit(UnitsLoaded(uoms: _allUoms, filteredUoms: filtered));
    }
  }

  Future<void> _onCreateUnit(CreateUnit event, Emitter<UnitsState> emit) async {
    emit(UnitsLoading());
    try {
      await productsRepo.createUom(event.company, event.uomName);
      emit(UnitsActionSuccess("Unit created successfully"));
      add(LoadUnits());
    } catch (e) {
      emit(UnitsError(e.toString()));
      add(LoadUnits()); // Reload list even on error to restore state
    }
  }

  Future<void> _onUpdateUnit(UpdateUnit event, Emitter<UnitsState> emit) async {
    emit(UnitsLoading());
    try {
      await productsRepo.updateUom(
        event.name,
        event.uomName,
        event.mustBeWholeNumber,
      );
      emit(UnitsActionSuccess("Unit updated successfully"));
      add(LoadUnits());
    } catch (e) {
      emit(UnitsError(e.toString()));
      add(LoadUnits());
    }
  }

  Future<void> _onDeleteUnit(DeleteUnit event, Emitter<UnitsState> emit) async {
    emit(UnitsLoading());
    try {
      await productsRepo.deleteUom(event.company, event.uomName);
      emit(UnitsActionSuccess("Unit deleted successfully"));
      add(LoadUnits());
    } catch (e) {
      emit(UnitsError(e.toString()));
      add(LoadUnits());
    }
  }
}
