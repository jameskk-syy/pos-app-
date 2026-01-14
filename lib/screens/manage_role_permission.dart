import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/presentation/roles/bloc/role_bloc.dart';
import 'package:pos/domain/requests/role_permissions_request.dart';
import 'package:pos/domain/responses/system_responses.dart';
import 'package:pos/domain/requests/assign_permissions_request.dart';
import 'dart:convert';

class RolePermissionsPage extends StatefulWidget {
  final String roleName;
  const RolePermissionsPage({super.key, required this.roleName});

  @override
  State<RolePermissionsPage> createState() => _RolePermissionsPageState();
}

class _RolePermissionsPageState extends State<RolePermissionsPage> {
  final TextEditingController _docTypeController = TextEditingController();
  final Map<String, List<Permission>> _permissions = {};

  final List<String> _permissionTypes = [
    'Read',
    'Write',
    'Create',
    'Delete',
    'Submit',
    'Cancel',
    'Amend',
    'Print',
    'Email',
    'Export',
    'Import',
    'Report',
    'Share',
    'Select',
  ];

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
  }

  void _fetchPermissions() {
    context.read<RoleBloc>().add(
      GetRolePermissions(
        request: RolePermissionsRequest(roleName: widget.roleName),
      ),
    );
  }

  void _addPermission(String docType) {
    if (docType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a DocType'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _permissions[docType] = [];
    });
  }

  void _togglePermission(String docType, String permission) {
    setState(() {
      final permissions = _permissions[docType]!;
      final existingIndex = permissions.indexWhere((p) => p.name == permission);

      if (existingIndex >= 0) {
        permissions.removeAt(existingIndex);
      } else {
        permissions.add(Permission(name: permission, isEnabled: true));
      }
    });
  }

  void _removeDocType(String docType) {
    setState(() {
      _permissions.remove(docType);
    });
  }

  void _saveChanges() {
    if (_permissions.isEmpty) return;

    for (var entry in _permissions.entries) {
      final docType = entry.key;
      final enabledPerms = entry.value;

      final Map<String, int> permsMap = {};
      for (var type in _permissionTypes) {
        // Check if this type is in the enabled list (by name case-insensitive or exact?)
        // existing logic uses exact match on name
        permsMap[type.toLowerCase()] = enabledPerms.any((p) => p.name == type)
            ? 1
            : 0;
      }

      final request = AssignPermissionsRequest(
        roleName: widget.roleName,
        docType: docType,
        permissions: jsonEncode(permsMap),
      );

      context.read<RoleBloc>().add(AssignRolePermissions(request: request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Permissions: ${widget.roleName}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<RoleBloc, RoleState>(
        listener: (context, state) {
          if (state is RolePermissionsLoaded) {
            setState(() {
              _permissions.clear();
              for (var docPerm in state.response.message) {
                _permissions[docPerm.docType] = docPerm.enabledPermissions
                    .map((pName) => Permission(name: pName, isEnabled: true))
                    .toList();
              }
            });
          } else if (state is RolePermissionsAssigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permissions assigned successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is RoleStateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<RoleBloc, RoleState>(
          builder: (context, state) {
            if (state is RoleStateLoading && _permissions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isTablet = constraints.maxWidth >= 600;
                final double hPadding = isTablet ? 64.0 : 16.0;

                return Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: hPadding,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DocType Permissions',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    _AddPermissionDialog(onAdd: _addPermission),
                              );
                            },
                            icon: Icon(Icons.add, size: isTablet ? 22 : 20),
                            label: Text(
                              'Add DocType',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 24 : 16,
                                vertical: isTablet ? 16 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _permissions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: isTablet ? 120 : 80,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No permissions configured',
                                    style: TextStyle(
                                      fontSize: isTablet ? 20 : 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: hPadding,
                                vertical: 20,
                              ),
                              itemCount: _permissions.length,
                              itemBuilder: (context, index) {
                                final docType = _permissions.keys.elementAt(
                                  index,
                                );
                                final permissions = _permissions[docType]!;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.description_outlined,
                                                    color: Colors.blue[700],
                                                    size: isTablet ? 24 : 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  docType,
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 20
                                                        : 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  _removeDocType(docType),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _permissionTypes.map((
                                            permission,
                                          ) {
                                            final isEnabled = permissions.any(
                                              (p) => p.name == permission,
                                            );
                                            return FilterChip(
                                              label: Text(
                                                permission,
                                                style: TextStyle(
                                                  fontSize: isTablet ? 14 : 13,
                                                  color: isEnabled
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              selected: isEnabled,
                                              onSelected: (_) =>
                                                  _togglePermission(
                                                    docType,
                                                    permission,
                                                  ),
                                              backgroundColor: Colors.grey[100],
                                              selectedColor: Colors.blue[600],
                                              checkmarkColor: Colors.white,
                                              showCheckmark: false,
                                              side: BorderSide.none,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _permissions.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: BlocBuilder<RoleBloc, RoleState>(
                builder: (context, state) {
                  final isLoading = state is RoleStateLoading;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.blue[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _docTypeController.dispose();
    super.dispose();
  }
}

class _AddPermissionDialog extends StatefulWidget {
  final Function(String) onAdd;

  const _AddPermissionDialog({required this.onAdd});

  @override
  State<_AddPermissionDialog> createState() => _AddPermissionDialogState();
}

class _AddPermissionDialogState extends State<_AddPermissionDialog> {
  String? _selectedModule;
  String? _selectedDocType;
  List<Module> _modules = [];
  List<Doctype> _doctypes = [];
  bool _isLoadingModules = true;
  bool _isLoadingDoctypes = false;

  @override
  void initState() {
    super.initState();
    context.read<RoleBloc>().add(FetchModules());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoleBloc, RoleState>(
      listener: (context, state) {
        if (state is ModulesLoaded) {
          setState(() {
            _modules = state.response.data.modules;
            _isLoadingModules = false;
          });
        } else if (state is DoctypesLoaded) {
          setState(() {
            _doctypes = state.response.data.doctypes;
            _isLoadingDoctypes = false;
            _selectedDocType = null;
          });
        } else if (state is RoleStateLoading) {
          // Check if we are loading modules or doctypes based on current state
          // but since state is emitted, we might just use the booleans
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New DocType Permissions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              // Module Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedModule,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select Module',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.apps),
                ),
                items: _modules.map((m) {
                  return DropdownMenuItem(
                    value: m.name,
                    child: Text(m.moduleName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedModule = value;
                    _doctypes = [];
                    _selectedDocType = null;
                    _isLoadingDoctypes = true;
                  });
                  if (value != null) {
                    context.read<RoleBloc>().add(FetchDoctypes(module: value));
                  }
                },
                hint: Text(
                  _isLoadingModules ? 'Loading modules...' : 'Select Module',
                ),
              ),
              const SizedBox(height: 20),
              // DocType Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedDocType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select DocType',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                items: _doctypes.map((d) {
                  return DropdownMenuItem(value: d.name, child: Text(d.name));
                }).toList(),
                onChanged: _selectedModule == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedDocType = value;
                        });
                      },
                disabledHint: const Text('Select a module first'),
                hint: Text(
                  _isLoadingDoctypes ? 'Loading doctypes...' : 'Select DocType',
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: (_selectedDocType == null)
                        ? null
                        : () {
                            widget.onAdd(_selectedDocType!);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Permission {
  final String name;
  final bool isEnabled;

  Permission({required this.name, required this.isEnabled});
}
