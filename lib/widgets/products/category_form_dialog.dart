import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/products/item_group.dart';
import 'package:pos/presentation/categories/bloc/categories_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_event.dart';
import 'package:pos/presentation/categories/bloc/categories_state.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

class CategoryFormDialog extends StatefulWidget {
  final ItemGroup? category;
  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedParent;
  List<ItemGroup> _allGroups = [];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.itemGroupName;
      _selectedParent = widget.category!.parentItemGroup.isEmpty
          ? null
          : widget.category!.parentItemGroup;
    }
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

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final company = await _getCompany();
      if (!mounted) return;

      if (company != null) {
        if (widget.category == null) {
          context.read<CategoriesBloc>().add(
            CreateCategory(
              company: company,
              itemGroupName: _nameController.text.trim(),
              parentItemGroup: _selectedParent,
            ),
          );
        } else {
          context.read<CategoriesBloc>().add(
            UpdateCategory(
              company: company,
              name: widget.category!.name,
              itemGroupName: _nameController.text.trim(),
              parentItemGroup: _selectedParent,
            ),
          );
        }
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not determine company')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoaded) {
          _allGroups = state.allCategories;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = MediaQuery.of(context).size.width >= 600;
            final width = isTablet
                ? 500.0
                : MediaQuery.of(context).size.width * 0.9;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                widget.category == null ? 'Create Category' : 'Edit Category',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: width,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Category Name',
                            hintText: 'Enter category name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedParent,
                          decoration: InputDecoration(
                            labelText: 'Parent Category',
                            hintText: 'Select parent category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('No Parent'),
                            ),
                            ..._allGroups
                                .where(
                                  (g) =>
                                      widget.category == null ||
                                      g.name != widget.category!.name,
                                )
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g.name,
                                    child: Text(g.itemGroupName),
                                  ),
                                ),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedParent = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(widget.category == null ? 'Submit' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
