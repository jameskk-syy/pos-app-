import 'package:flutter/material.dart';
import 'package:pos/domain/responses/products/item_group.dart';

class CategoryFilterList extends StatelessWidget {
  final List<ItemGroup> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryFilterList({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CategoryChip(
            label: 'All Items',
            selected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          ...categories.map((category) {
            return CategoryChip(
              label: category.name,
              selected: selectedCategory == category.name,
              onTap: () => onCategorySelected(category.name),
            );
          }),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: Chip(
          label: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? Colors.white : Colors.grey.shade700,
              fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          backgroundColor: selected ? Colors.blue : Colors.white,
          side: BorderSide(color: selected ? Colors.blue : Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
