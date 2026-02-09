import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/responses/uom_response.dart';
import 'package:pos/presentation/units/bloc/units_bloc.dart';
import 'package:pos/widgets/products/create_unit_dialog.dart';
import 'package:pos/widgets/products/edit_unit_dialog.dart';
import 'package:pos/widgets/products/units_list.dart';
import 'package:pos/core/services/storage_service.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key});

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  late UnitsBloc _unitsBloc;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _unitsBloc = getIt<UnitsBloc>()..add(LoadUnits());
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
      _unitsBloc.add(SearchUnits(_searchController.text));
    });
  }

  void _onCreateUnit() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _unitsBloc,
        child: const CreateUnitDialog(),
      ),
    );
  }

  void _onEditUnit(UOM uom) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _unitsBloc,
        child: EditUnitDialog(uom: uom),
      ),
    );
  }

  void _onDeleteUnit(UOM uom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Unit of Measure'),
        content: Text('Are you sure you want to delete "${uom.uomName}"?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final storage = getIt<StorageService>();
              final userString = await storage.getString('current_user');
              if (userString != null) {
                final userMap = jsonDecode(userString);
                if (userMap['message'] != null &&
                    userMap['message']['company'] != null) {
                  final company = userMap['message']['company']['name'];
                  _unitsBloc.add(
                    DeleteUnit(company: company, uomName: uom.name),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _unitsBloc,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text('Units'),
          backgroundColor: const Color(0xffF6F8FB),
        ),
        body: BlocConsumer<UnitsBloc, UnitsState>(
          listener: (context, state) {
            if (state is UnitsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is UnitsError) {
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
                  // Search and Create Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search units...',
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _onCreateUnit,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            "Create",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Content
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state is UnitsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is UnitsLoaded) {
                          return UnitsList(
                            uoms: state.filteredUoms,
                            onEdit: _onEditUnit,
                            onDelete: _onDeleteUnit,
                          );
                        } else if (state is UnitsError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
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
}
