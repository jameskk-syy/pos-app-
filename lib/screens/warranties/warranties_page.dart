import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/presentation/warranties/bloc/warranties_bloc.dart';
import 'package:pos/presentation/warranties/bloc/warranties_event.dart';
import 'package:pos/presentation/warranties/bloc/warranties_state.dart';
import 'package:pos/widgets/warranties_list.dart';
import 'package:pos/widgets/warranty_form_dialog.dart';
import 'dart:async';

class WarrantiesPage extends StatefulWidget {
  const WarrantiesPage({super.key});

  @override
  State<WarrantiesPage> createState() => _WarrantiesPageState();
}

class _WarrantiesPageState extends State<WarrantiesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<WarrantiesBloc>().add(const LoadWarranties(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<WarrantiesBloc>().add(const LoadWarranties());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<WarrantiesBloc>().add(SearchWarranties(query));
    });
  }

  void _showWarrantyDialog(ProductItem product) {
    showDialog(
      context: context,
      builder: (context) => WarrantyFormDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Warranties',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocListener<WarrantiesBloc, WarrantiesState>(
        listener: (context, state) {
          if (state is WarrantiesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is WarrantiesActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<WarrantiesBloc, WarrantiesState>(
                builder: (context, state) {
                  if (state is WarrantiesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is WarrantiesError &&
                      state.message.contains("Could not determine company")) {
                    return Center(child: Text(state.message));
                  }

                  if (state is WarrantiesLoaded) {
                    if (state.filteredProducts.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<WarrantiesBloc>().add(
                          const LoadWarranties(isRefresh: true),
                        );
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
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
                              child: WarrantiesList(
                                products: state.filteredProducts,
                                onSetWarranty: _showWarrantyDialog,
                              ),
                            ),
                            if (!state.hasReachedMax)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search products by name or code...',
          prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
          filled: true,
          fillColor: const Color(0xFFF1F4F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
