import 'package:flutter/material.dart';
import 'package:pos/domain/responses/users/users_list.dart';
import 'package:pos/utils/themes/app_colors.dart';
import 'package:pos/core/utils/permission_helper.dart';

enum StaffMenuAction { viewDetails, edit, manange }

class StaffListHeader extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onAddStaff;

  const StaffListHeader({
    super.key,
    required this.searchController,
    required this.onAddStaff,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search staff...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        if (PermissionHelper.hasPermission('manage_users:create'))
          SizedBox(
            width: 150,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAddStaff,
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text('Add Staff', style: TextStyle(color: AppColors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
      ],
    );
  }
}

class StaffTable extends StatelessWidget {
  final int totalStaff;
  final Widget child;

  const StaffTable({super.key, required this.totalStaff, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Users List ($totalStaff)',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StaffTableHeader(),
                const Divider(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StaffTableHeader extends StatelessWidget {
  const StaffTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)))),
      ],
    );
  }
}

class StaffRow extends StatelessWidget {
  final StaffUser staff;
  final Function(StaffMenuAction, StaffUser) onAction;

  const StaffRow({super.key, required this.staff, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(staff.fullName, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: staff.enabled == 1 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  staff.enabled == 1 ? 'Active' : 'Inactive',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<StaffMenuAction>(
                color: Colors.white,
                onSelected: (action) => onAction(action, staff),
                itemBuilder: (_) => [
                  _menuItem(Icons.visibility, 'View Details', StaffMenuAction.viewDetails),
                  if (PermissionHelper.hasPermission('manage_users:edit'))
                    _menuItem(Icons.edit, 'Edit', StaffMenuAction.edit),
                  if (PermissionHelper.hasPermission('manage_users:edit'))
                    _menuItem(Icons.assignment, 'Manage Roles', StaffMenuAction.manange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<StaffMenuAction> _menuItem(IconData icon, String text, StaffMenuAction value) {
    return PopupMenuItem<StaffMenuAction>(
      value: value,
      child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text)]),
    );
  }
}

class StaffEmptyState extends StatelessWidget {
  final String? searchQuery;

  const StaffEmptyState({super.key, this.searchQuery});

  @override
  Widget build(BuildContext context) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No users found matching "$searchQuery"', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.people_outline, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('No users found', style: TextStyle(fontSize: 16, color: Colors.grey)),
        Text('Click "Add Staff" to create new users', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
