import 'package:flutter/material.dart';

class StaffMultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> availableItems;
  final List<String> initialSelectedItems;
  final String searchHint;

  const StaffMultiSelectDialog({
    super.key,
    required this.title,
    required this.availableItems,
    required this.initialSelectedItems,
    this.searchHint = 'Search...',
  });

  @override
  State<StaffMultiSelectDialog> createState() => _StaffMultiSelectDialogState();
}

class _StaffMultiSelectDialogState extends State<StaffMultiSelectDialog> {
  late List<String> _tempSelectedItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    final query = _searchController.text.toLowerCase();
    final filteredItems = query.isEmpty
        ? widget.availableItems
        : widget.availableItems
              .where((item) => item.toLowerCase().contains(query))
              .toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? screenWidth : 520,
          maxHeight: screenHeight * (isMobile ? 0.75 : 0.65),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
              child: Row(
                children: [
                   Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            // ── Items list ───────────────────────────────────────────
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No matches found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredItems.length,
                      itemBuilder: (_, index) {
                        final item = filteredItems[index];
                        final isChecked = _tempSelectedItems.contains(item);
                        return CheckboxListTile(
                          value: isChecked,
                          title: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isChecked
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          activeColor: Colors.blue,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _tempSelectedItems.add(item);
                              } else {
                                _tempSelectedItems.remove(item);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            // ── Actions ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_tempSelectedItems);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
