import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/presentation/biller/bloc/biller_bloc.dart';
import 'package:pos/presentation/widgets/custom_text_field.dart';
import 'package:pos/presentation/industries/bloc/industries_bloc.dart';
import 'package:pos/domain/responses/industries_list_response.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/core/dependency.dart';

class CreateBillerPage extends StatefulWidget {
  const CreateBillerPage({super.key});

  @override
  State<CreateBillerPage> createState() => _CreateBillerPageState();
}

class _CreateBillerPageState extends State<CreateBillerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  String? _selectedIndustry;
  String? _selectedIndustryId;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    context.read<IndustriesBloc>().add(GetIndustriesList());
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final storage = getIt<StorageService>();
      final userString = await storage.getString('current_user');
      if (userString != null && mounted) {
        final user = CurrentUserResponse.fromJson(jsonDecode(userString));
        setState(() {
          _companyController.text = user.message.company.name;
        });
      }
    } catch (e) {
      debugPrint('Error loading current user company: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<T?> _showSearchableBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) displayLabel,
    required T? currentValue,
  }) async {
    final searchController = TextEditingController();
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: isTablet
                ? const BoxConstraints(maxWidth: 550)
                : const BoxConstraints(maxWidth: double.infinity),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                final query = searchController.text.toLowerCase();
                final displayItems = items
                    .where((item) => displayLabel(item).toLowerCase().contains(query))
                    .toList();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => setModalState(() {}),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                      ),
                      child: displayItems.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text('No results found', style: TextStyle(color: Colors.grey)),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: displayItems.length,
                              padding: const EdgeInsets.only(bottom: 20),
                              itemBuilder: (context, index) {
                                final item = displayItems[index];
                                final isSelected = item == currentValue;
                                return ListTile(
                                  title: Text(
                                    displayLabel(item),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.blue[700] : Colors.black87,
                                    ),
                                  ),
                                  trailing: isSelected ? Icon(Icons.check_circle, color: Colors.blue[700]) : null,
                                  onTap: () => Navigator.pop(ctx, item),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedIndustry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an industry'), backgroundColor: Colors.red),
        );
        return;
      }
      context.read<BillerBloc>().add(
            CreateBiller(
              CreateBillerRequest(
                billerName: _nameController.text.trim(),
                industry: _selectedIndustryId ?? '',
                company: _companyController.text.trim(),
                isDefault: _isDefault,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Branch'),
      ),
      body: BlocConsumer<BillerBloc, BillerState>(
        listener: (context, state) {
          if (state is CreateBillerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Branch created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // return true to trigger refresh
          } else if (state is CreateBillerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateBillerLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Branch Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Branch / Biller Name',
                    hint: 'e.g. Downtown Pharmacy',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<IndustriesBloc, IndustriesState>(
                    builder: (context, state) {
                      final isLoading = state is IndustriesLoading;
                      final isSuccess = state is IndustriesSuccess;

                      List<Industry> activeIndustries = [];
                      if (isSuccess) {
                        final all = state.message.message.industries;
                        activeIndustries = all.where((ind) => ind.isActive == 1).toList();
                      }

                      return InkWell(
                        onTap: (isLoading || activeIndustries.isEmpty)
                            ? null
                            : () async {
                                final selected = await _showSearchableBottomSheet<Industry>(
                                  context: context,
                                  title: 'Select Industry',
                                  items: activeIndustries,
                                  displayLabel: (i) => i.industryName,
                                  currentValue: _selectedIndustry == null
                                      ? null
                                      : activeIndustries
                                          .where((i) => i.industryName == _selectedIndustry)
                                          .firstOrNull,
                                );
                                  if (selected != null) {
                                    setState(() {
                                      _selectedIndustry = selected.industryName;
                                      _selectedIndustryId = selected.name;
                                    });
                                  }
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedIndustry ?? (isLoading ? 'Loading industries...' : 'Select Industry'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedIndustry == null ? Colors.grey.shade600 : Colors.black87,
                                ),
                              ),
                              if (isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _companyController,
                    label: 'Company',
                    hint: 'Loading company...',
                    readOnly: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Set as Default Branch'),
                    subtitle: const Text('This branch will be selected by default upon login.'),
                    value: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Branch',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
