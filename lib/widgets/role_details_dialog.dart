// lib/presentation/roles/widgets/role_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:pos/domain/responses/roles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/presentation/roles/bloc/role_bloc.dart';

class RoleDetailsDialog extends StatefulWidget {
  final RoleData role;

  const RoleDetailsDialog({super.key, required this.role});

  @override
  State<RoleDetailsDialog> createState() => _RoleDetailsDialogState();
}

class _RoleDetailsDialogState extends State<RoleDetailsDialog> {
  late RoleData _displayRole;

  @override
  void initState() {
    super.initState();
    _displayRole = widget.role;
    context.read<RoleBloc>().add(GetRoleDetails(roleName: widget.role.name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoleBloc, RoleState>(
      listener: (context, state) {
        if (state is RoleDetailsLoaded) {
          setState(() {
            _displayRole = state.role;
          });
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            // Added scroll view for safety
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Role Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                BlocBuilder<RoleBloc, RoleState>(
                  builder: (context, state) {
                    if (state is RoleStateLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Display _displayRole data
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Name', _displayRole.name),
                        _buildDetailRow('Role Name', _displayRole.roleName),
                        _buildDetailRow(
                          'Desk Access',
                          _displayRole.hasDeskAccess ? 'Yes' : 'No',
                        ),
                        _buildDetailRow(
                          'Two Factor Auth',
                          _displayRole.requiresTwoFactor ? 'Yes' : 'No',
                        ),
                        _buildDetailRow(
                          'Custom Role',
                          _displayRole.isCustomRole ? 'Yes' : 'No',
                        ),
                        _buildDetailRow(
                          'Status',
                          _displayRole.isDisabled ? 'Disabled' : 'Active',
                        ),
                        _buildDetailRow(
                          'User Count',
                          _displayRole.userCount.toString(),
                        ),
                        if (_displayRole.permissionCount != null)
                          _buildDetailRow(
                            'Permission Count',
                            _displayRole.permissionCount.toString(),
                          ),
                        if (_displayRole.isAutomatic != null)
                          _buildDetailRow(
                            'Automatic',
                            _displayRole.isAutomatic! ? 'Yes' : 'No',
                          ),
                        if (_displayRole.restrictToDomain != null)
                          _buildDetailRow(
                            'Restrict to Domain',
                            _displayRole.restrictToDomain!,
                          ),
                        if (_displayRole.homePage != null)
                          _buildDetailRow('Home Page', _displayRole.homePage!),
                        const SizedBox(height: 16),
                        const Text(
                          'Doctypes with Permissions:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        (_displayRole.doctypesWithPermissions == null ||
                                _displayRole.doctypesWithPermissions!.isEmpty)
                            ? Text(
                                'No permissions assigned',
                                style: TextStyle(color: Colors.grey[600]),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _displayRole.doctypesWithPermissions!
                                    .map((doctype) {
                                      return Chip(
                                        label: Text(doctype),
                                        backgroundColor: Colors.blue[50],
                                      );
                                    })
                                    .toList(),
                              ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
