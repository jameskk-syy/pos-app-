import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoriesEvent {}

class SearchCategories extends CategoriesEvent {
  final String query;
  const SearchCategories(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateCategory extends CategoriesEvent {
  final String company;
  final String itemGroupName;
  final String? parentItemGroup;

  const CreateCategory({
    required this.company,
    required this.itemGroupName,
    this.parentItemGroup,
  });

  @override
  List<Object?> get props => [company, itemGroupName, parentItemGroup];
}

class UpdateCategory extends CategoriesEvent {
  final String company;
  final String name;
  final String itemGroupName;
  final String? parentItemGroup;

  const UpdateCategory({
    required this.company,
    required this.name,
    required this.itemGroupName,
    this.parentItemGroup,
  });

  @override
  List<Object?> get props => [company, name, itemGroupName, parentItemGroup];
}
