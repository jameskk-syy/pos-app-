import 'package:equatable/equatable.dart';

abstract class BrandsEvent extends Equatable {
  const BrandsEvent();

  @override
  List<Object?> get props => [];
}

class LoadBrands extends BrandsEvent {}

class SearchBrands extends BrandsEvent {
  final String query;
  const SearchBrands(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateBrand extends BrandsEvent {
  final String company;
  final String brandName;

  const CreateBrand({required this.company, required this.brandName});

  @override
  List<Object?> get props => [company, brandName];
}

class UpdateBrand extends BrandsEvent {
  final String oldBrandName;
  final String newBrandName;

  const UpdateBrand({required this.oldBrandName, required this.newBrandName});

  @override
  List<Object?> get props => [oldBrandName, newBrandName];
}
