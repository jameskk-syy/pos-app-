import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/utils/themes/app_colors.dart';

class AuditFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedActivityType;
  final String? selectedStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> activityTypes;
  final List<String> statuses;
  final VoidCallback onFetchLogs;
  final VoidCallback onClearFilters;
  final Future<void> Function(BuildContext) onSelectDateRange;
  final Function(String?) onActivityTypeChanged;
  final Function(String?) onStatusChanged;
  final Function(String) onSearchQueryChanged;

  const AuditFilters({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedActivityType,
    required this.selectedStatus,
    required this.startDate,
    required this.endDate,
    required this.activityTypes,
    required this.statuses,
    required this.onFetchLogs,
    required this.onClearFilters,
    required this.onSelectDateRange,
    required this.onActivityTypeChanged,
    required this.onStatusChanged,
    required this.onSearchQueryChanged,
  });

  bool get _hasActiveFilters =>
      selectedActivityType != null ||
      selectedStatus != null ||
      startDate != null ||
      searchQuery.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──
          TextField(
            controller: searchController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search logs...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearchQueryChanged('');
                        onFetchLogs();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.blue),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          // ── Dropdown row ──
          Row(
            children: [
              // Activity type
              Expanded(
                child: _buildDropdown<String>(
                  hint: 'Activity Type',
                  value: selectedActivityType,
                  items: activityTypes,
                  onChanged: onActivityTypeChanged,
                ),
              ),
              const SizedBox(width: 8),
              // Status
              Expanded(
                child: _buildDropdown<String>(
                  hint: 'Status',
                  value: selectedStatus,
                  items: statuses,
                  onChanged: onStatusChanged,
                ),
              ),
              const SizedBox(width: 8),
              // Date range picker
              GestureDetector(
                onTap: () => onSelectDateRange(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: startDate != null
                        ? AppColors.blue.withAlpha(20)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: startDate != null
                          ? AppColors.blue
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: startDate != null
                            ? AppColors.blue
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        startDate == null
                            ? 'Dates'
                            : '${DateFormat('MMM d').format(startDate!)} – ${DateFormat('MMM d').format(endDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: startDate != null
                              ? AppColors.blue
                              : Colors.grey[700],
                          fontWeight: startDate != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Active filter chips ──
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                children: [
                  if (selectedActivityType != null)
                    _filterChip(selectedActivityType!, () {
                      onActivityTypeChanged(null);
                    }),
                  if (selectedStatus != null)
                    _filterChip(selectedStatus!, () {
                      onStatusChanged(null);
                    }),
                  if (startDate != null)
                    _filterChip(
                      '${DateFormat('MMM d').format(startDate!)} – ${DateFormat('MMM d').format(endDate!)}',
                      () {
                        onClearFilters(); // Or a specific date clear if implemented
                      },
                    ),
                  if (searchQuery.isNotEmpty)
                    _filterChip('" $searchQuery"', () {
                      searchController.clear();
                      onSearchQueryChanged('');
                      onFetchLogs();
                    }),
                  const Spacer(),
                  TextButton(
                    onPressed: onClearFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: value != null ? AppColors.blue.withAlpha(15) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value != null ? AppColors.blue : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: value != null ? AppColors.blue : Colors.grey,
          ),
          isDense: true,
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text(
                'All $hint',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blue.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.blue),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: AppColors.blue),
          ),
        ],
      ),
    );
  }
}
