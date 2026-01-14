import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'price_list_event.dart';
import 'price_list_state.dart';

class PriceListBloc extends Bloc<PriceListEvent, PriceListState> {
  final ProductsRepo productsRepo;

  PriceListBloc({required this.productsRepo}) : super(PriceListInitial()) {
    on<LoadPriceLists>(_onLoadPriceLists);
    on<SearchPriceLists>(_onSearchPriceLists);
    on<CreatePriceList>(_onCreatePriceList);
    on<UpdatePriceListEvent>(_onUpdatePriceList);
  }

  Future<String?> _getCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
    if (userString == null) return null;
    final userMap = jsonDecode(userString);
    if (userMap['message'] != null && userMap['message']['company'] != null) {
      return userMap['message']['company']['name'];
    }
    return null;
  }

  Future<void> _onLoadPriceLists(
    LoadPriceLists event,
    Emitter<PriceListState> emit,
  ) async {
    emit(PriceListLoading());
    try {
      final company = await _getCompany();
      if (company == null) {
        emit(const PriceListError("Could not determine company"));
        return;
      }
      final response = await productsRepo.getPriceLists(company);
      emit(
        PriceListLoaded(
          allPriceLists: response.priceLists,
          filteredPriceLists: response.priceLists,
        ),
      );
    } catch (e) {
      emit(PriceListError(e.toString()));
    }
  }

  void _onSearchPriceLists(
    SearchPriceLists event,
    Emitter<PriceListState> emit,
  ) {
    if (state is PriceListLoaded) {
      final currentState = state as PriceListLoaded;
      if (event.query.isEmpty) {
        emit(
          PriceListLoaded(
            allPriceLists: currentState.allPriceLists,
            filteredPriceLists: currentState.allPriceLists,
          ),
        );
      } else {
        final filtered = currentState.allPriceLists
            .where(
              (pl) => pl.priceListName.toLowerCase().contains(
                event.query.toLowerCase(),
              ),
            )
            .toList();
        emit(
          PriceListLoaded(
            allPriceLists: currentState.allPriceLists,
            filteredPriceLists: filtered,
          ),
        );
      }
    }
  }

  Future<void> _onCreatePriceList(
    CreatePriceList event,
    Emitter<PriceListState> emit,
  ) async {
    emit(PriceListLoading());
    try {
      await productsRepo.createPriceList(
        company: event.company,
        priceListName: event.priceListName,
        currency: event.currency,
        enabled: event.enabled,
        buying: event.buying,
        selling: event.selling,
      );
      emit(const PriceListActionSuccess("Price list created successfully"));
      add(LoadPriceLists());
    } catch (e) {
      emit(PriceListError(e.toString()));
      add(LoadPriceLists());
    }
  }

  Future<void> _onUpdatePriceList(
    UpdatePriceListEvent event,
    Emitter<PriceListState> emit,
  ) async {
    emit(PriceListLoading());
    try {
      await productsRepo.updatePriceList(
        name: event.name,
        newPriceListName: event.newPriceListName,
        currency: event.currency,
        enabled: event.enabled,
        buying: event.buying,
        selling: event.selling,
      );
      emit(const PriceListActionSuccess("Price list updated successfully"));
      add(LoadPriceLists());
    } catch (e) {
      emit(PriceListError(e.toString()));
      add(LoadPriceLists());
    }
  }
}
