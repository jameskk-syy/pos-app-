import 'package:flutter/material.dart';

class FiltersCard extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final int filteredProductsCount;
  final VoidCallback onClearFilters;

  const FiltersCard({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.filteredProductsCount,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name, code or group",
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                searchController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear, color: Colors.red),
                  label: const Text(
                    "Clear Filters",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            if (searchQuery.isNotEmpty && filteredProductsCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Found $filteredProductsCount product${filteredProductsCount == 1 ? '' : 's'} matching '$searchQuery'",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
