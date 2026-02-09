import 'package:equatable/equatable.dart';
import 'package:pos/domain/responses/products/item_brand.dart';

abstract class BrandsState extends Equatable {
  const BrandsState();

  @override
  List<Object?> get props => [];
}

class BrandsInitial extends BrandsState {}

class BrandsLoading extends BrandsState {}

class BrandsLoaded extends BrandsState {
  final List<Brand> allBrands;
  final List<Brand> filteredBrands;

  const BrandsLoaded({required this.allBrands, required this.filteredBrands});

  @override
  List<Object?> get props => [allBrands, filteredBrands];
}

class BrandsActionSuccess extends BrandsState {
  final String message;
  const BrandsActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BrandsError extends BrandsState {
  final String message;
  const BrandsError(this.message);

  @override
  List<Object?> get props => [message];
}
