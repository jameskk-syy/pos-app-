import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_role_request.dart';
import 'package:pos/domain/responses/roles.dart';
import 'package:pos/presentation/roles/bloc/role_bloc.dart';

class CreateRolePage extends StatefulWidget {
  final RoleData? role;

  const CreateRolePage({super.key, this.role});

  @override
  State<CreateRolePage> createState() => _CreateRolePageState();
}

class _CreateRolePageState extends State<CreateRolePage> {
  final _formKey = GlobalKey<FormState>();
  final _roleNameController = TextEditingController();
  final _domainController = TextEditingController();
  final _homePageController = TextEditingController();

  bool _deskAccess = true;
  bool _twoFactorAuth = false;
  bool _isCustom = true;

  @override
  void initState() {
    super.initState();
    if (widget.role != null) {
      _roleNameController.text = widget.role!.roleName;
      _domainController.text = widget.role!.restrictToDomain ?? '';
      _homePageController.text = widget.role!.homePage ?? '';
      _deskAccess = widget.role!.hasDeskAccess;
      _twoFactorAuth = widget.role!.requiresTwoFactor;
      _isCustom = widget.role!.isCustomRole;
    }
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    _domainController.dispose();
    _homePageController.dispose();
    super.dispose();
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoleBloc, RoleState>(
      listener: (context, state) {
        if (state is RoleStateCreateRoleSuccess ||
            state is RoleStateUpdateRoleSuccess) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is RoleStateCreateRoleSuccess
                    ? 'Role created successfully'
                    : 'Role updated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is RoleStateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is RoleStateLoading;

        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            if (_roleNameController.text.isNotEmpty ||
                _domainController.text.isNotEmpty ||
                _homePageController.text.isNotEmpty) {
              _showCancelConfirmation();
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Center(
                child: Text(
                  widget.role != null ? 'Update Role' : 'Create Role',
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              foregroundColor: Colors.black,
            ),
            backgroundColor: Colors.grey[50],
            body: LayoutBuilder(
              builder: (context, constraints) {
                final bool isTablet = constraints.maxWidth >= 600;

                return SingleChildScrollView(
                  padding: isTablet
                      ? const EdgeInsets.symmetric(horizontal: 48, vertical: 24)
                      : const EdgeInsets.all(0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 800 : double.infinity,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      widget.role != null
                                          ? 'Update Role'
                                          : 'Create Role',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                    ),
                                    const SizedBox(height: 24),
                                    TextFormField(
                                      controller: _roleNameController,
                                      enabled: !isLoading,
                                      decoration: const InputDecoration(
                                        labelText: 'Role Name *',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a role name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    SwitchListTile(
                                      title: const Text('Desk Access'),
                                      subtitle: const Text(
                                        'Allow access to the desk interface',
                                      ),
                                      value: _deskAccess,
                                      activeThumbColor: Colors.blue[600],
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _deskAccess = value;
                                              });
                                            },
                                    ),
                                    SwitchListTile(
                                      title: const Text('Is Custom'),
                                      subtitle: const Text(
                                        'Mark this as a custom role',
                                      ),
                                      value: _isCustom,
                                      activeThumbColor: Colors.blue[600],
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _isCustom = value;
                                              });
                                            },
                                    ),
                                    SwitchListTile(
                                      title: const Text(
                                        'Two Factor Authentication',
                                      ),
                                      subtitle: const Text(
                                        'Require 2FA for this role',
                                      ),
                                      value: _twoFactorAuth,
                                      activeThumbColor: Colors.blue[600],
                                      onChanged: isLoading
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _twoFactorAuth = value;
                                              });
                                            },
                                    ),
                                    const SizedBox(height: 20),
                                    // Two Fields per row on tablet
                                    if (isTablet)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _domainController,
                                              enabled: !isLoading,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Restrict to Domain (Optional)',
                                                border: OutlineInputBorder(),
                                                hintText: 'Optional domain',
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _homePageController,
                                              enabled: !isLoading,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Home Page (Optional)',
                                                border: OutlineInputBorder(),
                                                hintText: '/app',
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Column(
                                        children: [
                                          TextFormField(
                                            controller: _domainController,
                                            enabled: !isLoading,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'Restrict to Domain (Optional)',
                                              border: OutlineInputBorder(),
                                              hintText:
                                                  'Optional: Restrict this role to a specific domain',
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          TextFormField(
                                            controller: _homePageController,
                                            enabled: !isLoading,
                                            decoration: const InputDecoration(
                                              labelText: 'Home Page (Optional)',
                                              border: OutlineInputBorder(),
                                              hintText:
                                                  "Optional: Default home page route (e.g., '/app')",
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.grey[600],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Fields marked with * are required',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            bottomNavigationBar: isLoading
                ? const LinearProgressIndicator()
                : Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_roleNameController.text.isNotEmpty ||
                                      _domainController.text.isNotEmpty ||
                                      _homePageController.text.isNotEmpty) {
                                    _showCancelConfirmation();
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final request = CreateRoleRequest(
                                name: widget.role?.name,
                                roleName: _roleNameController.text,
                                deskAccess: _deskAccess ? 1 : 0,
                                twoFactorAuth: _twoFactorAuth ? 1 : 0,
                                isCustom: _isCustom ? 1 : 0,
                                restrictToDomain:
                                    _domainController.text.isNotEmpty
                                    ? _domainController.text
                                    : null,
                                homePage: _homePageController.text.isNotEmpty
                                    ? _homePageController.text
                                    : null,
                              );
                              if (widget.role != null) {
                                context.read<RoleBloc>().add(
                                  UpdateRole(updateRoleRequest: request),
                                );
                              } else {
                                context.read<RoleBloc>().add(
                                  CreateRole(createRoleRequest: request),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.role != null ? 'Update' : 'Create',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
