part of 'products_bloc.dart';

@immutable
sealed class ProductsState {}

final class ProductsInitial extends ProductsState {}

final class ProductsStateLoading extends ProductsState {}

final class ProductsCreateStateSuccess extends ProductsState {}

final class ProductsStateSuccess extends ProductsState {
  final ProductResponseSimple productResponseSimple;

  ProductsStateSuccess({required this.productResponseSimple});
}

final class ItemsStateSuccess extends ProductsState {
  final StockItemResponse stockItemResponse;

  ItemsStateSuccess({required this.stockItemResponse});
}

final class ProductsItemGroupsStateSuccess extends ProductsState {
  final ItemGroupResponse itemGroupResponse;

  ProductsItemGroupsStateSuccess({required this.itemGroupResponse});
}

final class ProductsUomStateSuccess extends ProductsState {
  final UOMResponse uomResponse;

  ProductsUomStateSuccess({required this.uomResponse});
}

final class ProductsBrandStateSuccess extends ProductsState {
  final BrandResponse brandResponse;

  ProductsBrandStateSuccess({required this.brandResponse});
}

final class ProductsStateFailure extends ProductsState {
  final String error;

  ProductsStateFailure({required this.error});
}

final class AddItemToStockSuccess extends ProductsState {
  final StockResponse stockResponse;

  AddItemToStockSuccess({required this.stockResponse});
}

final class ProductsUpdateStateSuccess extends ProductsState {}
