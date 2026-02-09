import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'dart:convert';
import 'warranties_event.dart';
import 'warranties_state.dart';

class WarrantiesBloc extends Bloc<WarrantiesEvent, WarrantiesState> {
  final ProductsRepo productsRepo;
  static const int pageSize = 20;

  WarrantiesBloc({required this.productsRepo}) : super(WarrantiesInitial()) {
    on<LoadWarranties>(_onLoadWarranties);
    on<SearchWarranties>(_onSearchWarranties);
    on<SetWarrantyEvent>(_onSetWarranty);
  }

  Future<Map<String, String>?> _getCompanyAndWarehouse() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    final userMap = jsonDecode(userString);
    if (userMap['message'] != null && userMap['message']['company'] != null) {
      return {
        'company': userMap['message']['company']['name'],
        'warehouse': userMap['message']['warehouse'] ?? '',
      };
    }
    return null;
  }

  Future<void> _onLoadWarranties(
    LoadWarranties event,
    Emitter<WarrantiesState> emit,
  ) async {
    if (event.isRefresh) {
      emit(WarrantiesLoading());
    }

    final currentState = state;
    int pageToFetch = 1;
    if (currentState is WarrantiesLoaded && !event.isRefresh) {
      if (currentState.hasReachedMax) return;
      pageToFetch = currentState.currentPage + 1;
    }

    try {
      final info = await _getCompanyAndWarehouse();
      if (info == null) {
        emit(const WarrantiesError("Could not determine company"));
        return;
      }

      final response = await productsRepo.getAllProducts(
        info['company']!,
        page: pageToFetch,
        pageSize: pageSize,
      );

      final products = response.products;
      if (currentState is WarrantiesLoaded && !event.isRefresh) {
        emit(
          currentState.copyWith(
            allProducts: List.of(currentState.allProducts)..addAll(products),
            filteredProducts: List.of(currentState.filteredProducts)
              ..addAll(products),
            hasReachedMax: products.length < pageSize,
            currentPage: pageToFetch,
          ),
        );
      } else {
        emit(
          WarrantiesLoaded(
            allProducts: products,
            filteredProducts: products,
            hasReachedMax: products.length < pageSize,
            currentPage: 1,
          ),
        );
      }
    } catch (e) {
      emit(WarrantiesError(e.toString()));
    }
  }

  void _onSearchWarranties(
    SearchWarranties event,
    Emitter<WarrantiesState> emit,
  ) {
    if (state is WarrantiesLoaded) {
      final currentState = state as WarrantiesLoaded;
      if (event.query.isEmpty) {
        emit(currentState.copyWith(filteredProducts: currentState.allProducts));
      } else {
        final filtered = currentState.allProducts
            .where(
              (p) =>
                  p.itemName.toLowerCase().contains(
                    event.query.toLowerCase(),
                  ) ||
                  p.itemCode.toLowerCase().contains(event.query.toLowerCase()),
            )
            .toList();
        emit(currentState.copyWith(filteredProducts: filtered));
      }
    }
  }

  Future<void> _onSetWarranty(
    SetWarrantyEvent event,
    Emitter<WarrantiesState> emit,
  ) async {
    // We don't want to emit a full loading state as it would hide the table
    // UI components should handle their own local loading if needed, or we can use a different state
    try {
      await productsRepo.setProductWarranty(
        company: event.company,
        itemCode: event.itemCode,
        warrantyPeriod: event.warrantyPeriod,
        warrantyPeriodUnit: event.warrantyPeriodUnit,
      );
      emit(const WarrantiesActionSuccess("Warranty set successfully"));
      add(const LoadWarranties(isRefresh: true));
    } catch (e) {
      emit(WarrantiesError(e.toString()));
    }
  }
}
