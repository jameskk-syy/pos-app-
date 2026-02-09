import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:pos/presentation/price_list/bloc/price_list_bloc.dart';
import 'package:pos/presentation/price_list/bloc/price_list_event.dart';
import 'package:pos/presentation/price_list/bloc/price_list_state.dart';
import 'package:pos/widgets/products/price_lists_list.dart';
import 'package:pos/widgets/products/price_list_form_dialog.dart';

class PriceListsPage extends StatefulWidget {
  const PriceListsPage({super.key});

  @override
  State<PriceListsPage> createState() => _PriceListsPageState();
}

class _PriceListsPageState extends State<PriceListsPage> {
  late PriceListBloc _priceListBloc;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _priceListBloc = getIt<PriceListBloc>()..add(LoadPriceLists());
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
      _priceListBloc.add(SearchPriceLists(_searchController.text));
    });
  }

  void _onCreatePriceList() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _priceListBloc,
        child: const PriceListFormDialog(),
      ),
    );
  }

  void _onEditPriceList(PriceList priceList) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _priceListBloc,
        child: PriceListFormDialog(priceList: priceList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _priceListBloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text('Price Lists'),
          backgroundColor: const Color(0xffF6F8FB),
        ),
        body: BlocConsumer<PriceListBloc, PriceListState>(
          listener: (context, state) {
            if (state is PriceListActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is PriceListError) {
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
                            hintText: 'Search price lists...',
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
                        onPressed: _onCreatePriceList,
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

  Widget _buildContent(PriceListState state) {
    if (state is PriceListLoading && state is! PriceListLoaded) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PriceListError && state is! PriceListLoaded) {
      return Center(child: Text(state.message));
    } else if (state is PriceListLoaded) {
      return PriceListsList(
        priceLists: state.filteredPriceLists,
        onEdit: _onEditPriceList,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
