import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/domain/requests/products/create_product.dart';
import 'package:pos/domain/requests/inventory/stock_request.dart';
import 'package:pos/domain/responses/products/item_group.dart';
import 'package:pos/domain/responses/products/item_list.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/inventory/stock_reco.dart';
import 'package:pos/domain/responses/products/item_brand.dart';
import 'package:pos/domain/responses/uom_response.dart';
part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepo productsRepo;
  ProductsBloc({required this.productsRepo}) : super(ProductsInitial()) {
    on<ProductsEvent>((event, emit) {});
    on<GetAllProducts>(_getAllProducts);
    on<GetItemGroup>(_getAllProductsGroups);
    on<GetUnitOfMeasure>(_getAllProductsUom);
    on<CreateProduct>(_creteProduct);
    on<GetProductItems>(_getProductEvents);
    on<AddItemToStock>(_addItemToStock);
    on<GetBrand>(_getAllProductsBrands);
    on<UpdateProduct>(_updateProduct);
    on<DisableProductEvent>(_disableProduct);
    on<EnableProductEvent>(_enableProduct);
    on<SearchProductByBarcode>(_onSearchProductByBarcode);
  }

  Future<void> _onSearchProductByBarcode(
    SearchProductByBarcode event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      final product = await productsRepo.searchProductByBarcode(
        barcode: event.barcode,
        posProfile: event.posProfile,
      );
      emit(BarcodeSearchSuccess(product: product));
    } catch (e) {
      debugPrint("Barcode search error: ${e.toString()}");
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _getAllProducts(
    GetAllProducts event,
    Emitter<ProductsState> emit,
  ) async {
    if (event.page == 1) {
      emit(ProductsStateLoading());
    }
    try {
      final response = await productsRepo.getAllProducts(
        event.company,
        searchTerm: event.searchTerm,
        itemGroup: event.itemGroup,
        brand: event.brand,
        warehouse: event.warehouse,
        page: event.page ?? 1,
        pageSize: event.pageSize ?? 20,
      );
      emit(ProductsStateSuccess(productResponse: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _addItemToStock(
    AddItemToStock event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      final response = await productsRepo.addItemToStock(event.stockRequest);
      emit(AddItemToStockSuccess(stockResponse: response));
    } catch (e) {
      debugPrint('Add item to stock error: ${e.toString()}');
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _getAllProductsGroups(
    GetItemGroup event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      final response = await productsRepo.getItemGroup();
      emit(ProductsItemGroupsStateSuccess(itemGroupResponse: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _getAllProductsUom(
    GetUnitOfMeasure event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      final response = await productsRepo.getUnitOfmeasure();
      emit(ProductsUomStateSuccess(uomResponse: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _creteProduct(
    CreateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    debugPrint(event.createProductRequest.itemCode);
    try {
      await productsRepo.createProduct(event.createProductRequest);
      emit(ProductsCreateStateSuccess());
    } catch (e) {
      debugPrint("dsjghfh ${e.toString()}");
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _getProductEvents(
    GetProductItems event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      final response = await productsRepo.getProductItems(event.company);
      emit(ItemsStateSuccess(stockItemResponse: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _getAllProductsBrands(
    GetBrand event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      final response = await productsRepo.getBrand();
      emit(ProductsBrandStateSuccess(brandResponse: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _updateProduct(
    UpdateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      await productsRepo.updateProduct(event.updateProductRequest);
      emit(ProductsUpdateStateSuccess());
    } catch (e) {
      debugPrint("Update product error: ${e.toString()}");
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _disableProduct(
    DisableProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      final message = await productsRepo.disableProduct(event.itemCode);
      emit(ProductsUpdateStateSuccess(message: message));
    } catch (e) {
      debugPrint("Disable product error: ${e.toString()}");
      emit(ProductsStateFailure(error: e.toString()));
    }
  }

  Future<void> _enableProduct(
    EnableProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsStateLoading());
    try {
      await productsRepo.enableProduct(event.itemCode);
      emit(ProductsUpdateStateSuccess());
    } catch (e) {
      debugPrint("Enable product error: ${e.toString()}");
      emit(ProductsStateFailure(error: e.toString()));
    }
  }
}
