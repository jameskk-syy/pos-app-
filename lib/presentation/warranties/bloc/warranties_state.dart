import 'package:equatable/equatable.dart';
import 'package:pos/domain/responses/product_response.dart';

abstract class WarrantiesState extends Equatable {
  const WarrantiesState();

  @override
  List<Object?> get props => [];
}

class WarrantiesInitial extends WarrantiesState {}

class WarrantiesLoading extends WarrantiesState {}

class WarrantiesLoaded extends WarrantiesState {
  final List<ProductItem> allProducts;
  final List<ProductItem> filteredProducts;
  final bool hasReachedMax;
  final int currentPage;

  const WarrantiesLoaded({
    required this.allProducts,
    required this.filteredProducts,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [
    allProducts,
    filteredProducts,
    hasReachedMax,
    currentPage,
  ];

  WarrantiesLoaded copyWith({
    List<ProductItem>? allProducts,
    List<ProductItem>? filteredProducts,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return WarrantiesLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class WarrantiesError extends WarrantiesState {
  final String message;
  const WarrantiesError(this.message);

  @override
  List<Object?> get props => [message];
}

class WarrantiesActionSuccess extends WarrantiesState {
  final String message;
  const WarrantiesActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
