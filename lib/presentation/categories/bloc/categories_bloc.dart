import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final ProductsRepo productsRepo;

  CategoriesBloc({required this.productsRepo}) : super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SearchCategories>(_onSearchCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final response = await productsRepo.getItemGroup();
      emit(
        CategoriesLoaded(
          allCategories: response.message.itemGroups,
          filteredCategories: response.message.itemGroups,
        ),
      );
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  void _onSearchCategories(
    SearchCategories event,
    Emitter<CategoriesState> emit,
  ) {
    if (state is CategoriesLoaded) {
      final currentState = state as CategoriesLoaded;
      if (event.query.isEmpty) {
        emit(
          CategoriesLoaded(
            allCategories: currentState.allCategories,
            filteredCategories: currentState.allCategories,
          ),
        );
      } else {
        final filtered = currentState.allCategories
            .where(
              (cat) => cat.itemGroupName.toLowerCase().contains(
                event.query.toLowerCase(),
              ),
            )
            .toList();
        emit(
          CategoriesLoaded(
            allCategories: currentState.allCategories,
            filteredCategories: filtered,
          ),
        );
      }
    }
  }

  // Fixing the typo in SearchCategories handler
  // (Wait, actually I should just write it correctly first time)

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      await productsRepo.createItemGroup(
        event.company,
        event.itemGroupName,
        event.parentItemGroup,
      );
      emit(const CategoriesActionSuccess("Category created successfully"));
      add(LoadCategories());
    } catch (e) {
      emit(CategoriesError(e.toString()));
      add(LoadCategories());
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      await productsRepo.updateItemGroup(
        event.company,
        event.name,
        event.itemGroupName,
        event.parentItemGroup,
      );
      emit(const CategoriesActionSuccess("Category updated successfully"));
      add(LoadCategories());
    } catch (e) {
      emit(CategoriesError(e.toString()));
      add(LoadCategories());
    }
  }
}
