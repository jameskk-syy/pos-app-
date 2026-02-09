import 'package:equatable/equatable.dart';
import 'package:pos/domain/responses/products/item_group.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<ItemGroup> allCategories;
  final List<ItemGroup> filteredCategories;

  const CategoriesLoaded({
    required this.allCategories,
    required this.filteredCategories,
  });

  @override
  List<Object?> get props => [allCategories, filteredCategories];
}

class CategoriesActionSuccess extends CategoriesState {
  final String message;
  const CategoriesActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
