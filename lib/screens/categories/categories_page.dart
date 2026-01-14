import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/responses/item_group.dart';
import 'package:pos/presentation/categories/bloc/categories_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_event.dart';
import 'package:pos/presentation/categories/bloc/categories_state.dart';
import 'package:pos/widgets/categories_list.dart';
import 'package:pos/widgets/category_form_dialog.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late CategoriesBloc _categoriesBloc;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _categoriesBloc = getIt<CategoriesBloc>()..add(LoadCategories());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _categoriesBloc.add(SearchCategories(_searchController.text));
    });
  }

  void _onCreateCategory() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _categoriesBloc,
        child: const CategoryFormDialog(),
      ),
    );
  }

  void _onEditCategory(ItemGroup category) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _categoriesBloc,
        child: CategoryFormDialog(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _categoriesBloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text('Categories'),
          backgroundColor: const Color(0xffF6F8FB),
        ),
        body: BlocConsumer<CategoriesBloc, CategoriesState>(
          listener: (context, state) {
            if (state is CategoriesActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is CategoriesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search categories...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _onCreateCategory,
                        icon: const Icon(Icons.add),
                        label: const Text('Create'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildContent(state),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(CategoriesState state) {
    if (state is CategoriesLoading && state is! CategoriesLoaded) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is CategoriesError && state is! CategoriesLoaded) {
      return Center(child: Text(state.message));
    } else if (state is CategoriesLoaded) {
      return CategoriesList(
        categories: state.filteredCategories,
        onEdit: _onEditCategory,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
