part of 'products_bloc.dart';

@immutable
sealed class ProductsEvent {}

class GetAllProducts extends ProductsEvent {
  final String company;
  final String? searchTerm;
  final String? itemGroup;
  final String? brand;
  final String? warehouse;
  final bool? isSalesItem;
  final bool? disabled;
  final int? page;
  final int? pageSize;

  GetAllProducts({
    required this.company,
    this.searchTerm,
    this.itemGroup,
    this.brand,
    this.warehouse,
    this.isSalesItem,
    this.disabled,
    this.page = 1,
    this.pageSize = 20,
  });
}

class GetItemGroup extends ProductsEvent {}

class GetUnitOfMeasure extends ProductsEvent {}

class GetBrand extends ProductsEvent {}

class GetItemType extends ProductsEvent {}

class CreateProduct extends ProductsEvent {
  final CreateProductRequest createProductRequest;

  CreateProduct({required this.createProductRequest});
}

class GetProductItems extends ProductsEvent {
  final String company;

  GetProductItems({required this.company});
}

class AddItemToStock extends ProductsEvent {
  final StockRequest stockRequest;

  AddItemToStock({required this.stockRequest});
}

class UpdateProduct extends ProductsEvent {
  final CreateProductRequest updateProductRequest;

  UpdateProduct({required this.updateProductRequest});
}

class DisableProductEvent extends ProductsEvent {
  final String itemCode;

  DisableProductEvent({required this.itemCode});
}

class EnableProductEvent extends ProductsEvent {
  final String itemCode;

  EnableProductEvent({required this.itemCode});
}

class SearchProductByBarcode extends ProductsEvent {
  final String barcode;
  final String posProfile;

  SearchProductByBarcode({required this.barcode, required this.posProfile});
}
