import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/users/update_staff_roles.dart';
import 'package:pos/domain/responses/users/role_response.dart';
import 'package:pos/presentation/usersBloc/bloc/staff_bloc.dart';

class ManageRolesDialog extends StatefulWidget {
  final List<Role> availableRoles;
  final List<String> currentRoles;
  final String staffName;
  final String staffEmail;

  const ManageRolesDialog({
    super.key,
    required this.availableRoles,
    required this.currentRoles,
    required this.staffName,
    required this.staffEmail,
  });

  @override
  State<ManageRolesDialog> createState() => _ManageRolesDialogState();
}

class _ManageRolesDialogState extends State<ManageRolesDialog> {
  late List<String> _selectedRoles;
  bool _replaceExisting = false;
  bool _isDropdownOpen = false;
  final TextEditingController _searchController = TextEditingController();
  List<Role> _filteredRoles = [];

  @override
  void initState() {
    super.initState();
    // Initialize with current roles
    _selectedRoles = List.from(widget.currentRoles);
    _filteredRoles = List.from(widget.availableRoles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRoles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRoles = List.from(widget.availableRoles);
      } else {
        _filteredRoles = widget.availableRoles
            .where(
              (role) => role.label.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleRole(String roleName) {
    setState(() {
      if (_selectedRoles.contains(roleName)) {
        _selectedRoles.remove(roleName);
      } else {
        _selectedRoles.add(roleName);
      }
    });
  }

  String _getDisplayText() {
    if (_selectedRoles.isEmpty) {
      return 'Select roles';
    } else if (_selectedRoles.length == 1) {
      return _selectedRoles.first;
    } else {
      return '${_selectedRoles.length} roles selected';
    }
  }

  void _handleUpdate() {
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = AssignRolesRequest(
      userEmail: widget.staffEmail,
      roles: _selectedRoles,
      replaceExisting: _replaceExisting,
    );

    context.read<StaffBloc>().add(
      AssignRolesToStaff(assignRolesRequest: request),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // User requested "responsive dialog in tablet", increasing width
    final dialogWidth = width < 600 ? double.infinity : 700.0;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: width < 600
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : const EdgeInsets.all(24),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Roles - ${widget.staffName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0288D1),
              ),
            ),
            const SizedBox(height: 24),

            // Roles Label
            const Text(
              'Roles',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Multi-select Dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isDropdownOpen = !_isDropdownOpen;
                        if (_isDropdownOpen) {
                          // Reset filter when opening
                          _searchController.clear();
                          _filteredRoles = List.from(widget.availableRoles);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _getDisplayText(),
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedRoles.isEmpty
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            _isDropdownOpen
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dropdown List
                  if (_isDropdownOpen)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search Box
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _filterRoles,
                              decoration: const InputDecoration(
                                hintText: 'Search roles...',
                                prefixIcon: Icon(Icons.search, size: 20),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredRoles.length,
                              itemBuilder: (context, index) {
                                final role = _filteredRoles[index];
                                final isSelected = _selectedRoles.contains(
                                  role.name,
                                );

                                return InkWell(
                                  onTap: () => _toggleRole(role.name),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(
                                              0xFF0288D1,
                                            ).withAlpha(10)
                                          : Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) =>
                                              _toggleRole(role.name),
                                          activeColor: const Color(0xFF0288D1),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            role.label,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isSelected
                                                  ? const Color(0xFF0288D1)
                                                  : Colors.black87,
                                              fontWeight: isSelected
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Replace existing roles toggle
            Row(
              children: [
                Switch(
                  value: _replaceExisting,
                  onChanged: (value) {
                    setState(() {
                      _replaceExisting = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF0288D1),
                  activeTrackColor: const Color(0xFF0288D1).withAlpha(50),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Replace existing roles (otherwise add/remove)',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF0288D1), fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    'Update Roles',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
