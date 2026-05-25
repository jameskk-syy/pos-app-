import 'package:flutter/material.dart';
import 'package:pos/utils/themes/app_colors.dart';

class DashboardFilter extends StatelessWidget {
  final Widget periodDropdown;
  final Widget warehouseDropdown;
  final Widget staffDropdown;
  final Widget? clearButton;

  const DashboardFilter({
    super.key,
    required this.periodDropdown,
    required this.warehouseDropdown,
    required this.staffDropdown,
    this.clearButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: periodDropdown),
            const SizedBox(width: 12),
            Expanded(child: warehouseDropdown),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: staffDropdown),
            const SizedBox(width: 12),
            if (clearButton != null) Expanded(child: clearButton!),
          ],
        ),
      ],
    );
  }
}

class DashboardFilterDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const DashboardFilterDropdown({
    super.key,
    required this.label,
    this.icon = Icons.keyboard_arrow_down,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.blue, width: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isLoading)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}

class DashboardClearButton extends StatelessWidget {
  final VoidCallback onTap;

  const DashboardClearButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.clear, size: 16, color: Colors.red),
            SizedBox(width: 6),
            Text('Clear', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class DashboardSelectionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final Function(String) onSelected;

  const DashboardSelectionSheet({
    super.key,
    required this.title,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedValue == option;
                    return ListTile(
                      title: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.blue : Colors.grey.shade800,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue, size: 22) : null,
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
