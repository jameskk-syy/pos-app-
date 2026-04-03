import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/responses/products/item_brand.dart';
import 'package:pos/presentation/brands/bloc/brands_bloc.dart';
import 'package:pos/presentation/brands/bloc/brands_event.dart';
import 'package:pos/presentation/brands/bloc/brands_state.dart';
import 'package:pos/widgets/products/brands_list.dart';
import 'package:pos/widgets/products/create_brand_dialog.dart';
import 'package:pos/widgets/products/edit_brand_dialog.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  late BrandsBloc _brandsBloc;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _brandsBloc = getIt<BrandsBloc>()..add(LoadBrands());
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
      _brandsBloc.add(SearchBrands(_searchController.text));
    });
  }

  void _onCreateBrand() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _brandsBloc,
        child: const CreateBrandDialog(),
      ),
    );
  }

  void _onEditBrand(Brand brand) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _brandsBloc,
        child: EditBrandDialog(brand: brand),
      ),
    );
  }

  Future<String?> _getCompany() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    final userMap = jsonDecode(userString);
    if (userMap['message'] != null && userMap['message']['company'] != null) {
      return userMap['message']['company']['name'];
    }
    return null;
  }

  void _onDeleteBrand(Brand brand) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand'),
        content: Text(
          'Are you sure you want to delete brand "${brand.brandName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final company = await _getCompany();
      if (company != null) {
        _brandsBloc.add(
          DeleteBrand(brandName: brand.brandName, company: company),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not determine company')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _brandsBloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text('Brands'),
          backgroundColor: const Color(0xffF6F8FB),
        ),
        body: BlocConsumer<BrandsBloc, BrandsState>(
          listener: (context, state) {
            if (state is BrandsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is BrandsError) {
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
                            hintText: 'Search brands...',
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
                        onPressed: _onCreateBrand,
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

  Widget _buildContent(BrandsState state) {
    if (state is BrandsLoading && state is! BrandsLoaded) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is BrandsError && state is! BrandsLoaded) {
      return Center(child: Text(state.message));
    } else if (state is BrandsLoaded) {
      return BrandsList(
        brands: state.filteredBrands,
        onEdit: _onEditBrand,
        onDelete: _onDeleteBrand,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
