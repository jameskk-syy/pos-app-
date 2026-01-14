import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_pos_request.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/posProfile/bloc/pos_profile_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePosProfilePage extends StatefulWidget {
  const CreatePosProfilePage({super.key});

  @override
  State<CreatePosProfilePage> createState() => CreatePosProfilePageState();
}

class CreatePosProfilePageState extends State<CreatePosProfilePage> {
  final TextEditingController _profileNameController = TextEditingController();
  bool _updateStock = true;
  bool _allowDiscountChange = true;
  bool _allowRateChange = true;
  bool _allowPartialPayment = true;
  CurrentUserResponse? currentUserResponse;

  String? _company;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;

    setState(() {
      currentUserResponse = savedUser;
      _company = savedUser.message.company.name;
    });
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              'Success!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile created successfully',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Profile', _profileNameController.text),
                  _buildDetailRow('Update Stock', _updateStock ? 'Yes' : 'No'),
                  _buildDetailRow(
                    'Discount Change',
                    _allowDiscountChange ? 'Yes' : 'No',
                  ),
                  _buildDetailRow(
                    'Rate Change',
                    _allowRateChange ? 'Yes' : 'No',
                  ),
                  _buildDetailRow(
                    'Partial Payment',
                    _allowPartialPayment ? 'Yes' : 'No',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue[700])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _profileNameController.clear();
              setState(() {
                _updateStock = true;
                _allowDiscountChange = true;
                _allowRateChange = true;
                _allowPartialPayment = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Create Another',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(
              'Error',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.blue[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCheckbox({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 30,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.blue[100]! : Colors.grey[200]!,
          width: value ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(value ? 10 : 5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: value ? Colors.blue[800] : Colors.grey[800],
                  ),
                  maxLines: 2,
                ),
              ),
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  activeColor: Colors.blue[700],
                  checkColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: value ? Colors.blue[600] : Colors.grey[600],
              height: 1.3,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PosProfileBloc, PosProfileState>(
      listener: (context, state) {
        if (state is PosProfileStateSuccess) {
          _showSuccessDialog(context);
        }
        if (state is PosProfileStateFailure) {
          _showErrorDialog(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Create POS Profile',
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.grey[600]),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Help'),
                    content: const Text(
                      'Create a new POS profile with specific permissions. '
                      'Enter profile name and configure settings.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<PosProfileBloc, PosProfileState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create a new POS profile',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_company != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Company: $_company',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Name
                    Text(
                      'Profile Name *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _profileNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter profile name',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue[700]!,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Settings Header
                    Row(
                      children: [
                        Icon(Icons.settings, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Profile Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure the permissions and features for this profile',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // Compact Checkboxes Section (2 per row)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                      children: [
                        _buildCompactCheckbox(
                          title: 'Update Stock',
                          subtitle: 'Automatically update inventory levels',
                          value: _updateStock,
                          onChanged: (value) =>
                              setState(() => _updateStock = value ?? false),
                        ),
                        _buildCompactCheckbox(
                          title: 'Discount Change',
                          subtitle: 'Enable discount modification',
                          value: _allowDiscountChange,
                          onChanged: (value) => setState(
                            () => _allowDiscountChange = value ?? false,
                          ),
                        ),
                        _buildCompactCheckbox(
                          title: 'Rate Change',
                          subtitle: 'Allow price adjustments',
                          value: _allowRateChange,
                          onChanged: (value) =>
                              setState(() => _allowRateChange = value ?? false),
                        ),
                        _buildCompactCheckbox(
                          title: 'Partial Payment',
                          subtitle: 'Enable partial payments',
                          value: _allowPartialPayment,
                          onChanged: (value) => setState(
                            () => _allowPartialPayment = value ?? false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue[700]!.withAlpha(30),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed:
                            state is PosProfileStateLoading || _company == null
                            ? null
                            : () {
                                // if (_profileNameController.text.isEmpty) {
                                //   _showErrorDialog(
                                //     context,
                                //     'Please enter a profile name',
                                //   );
                                //   return;
                                // }

                                final request = CompanyProfileRequest(
                                  company: _company!,
                                  profileName: _profileNameController.text,
                                  updateStock: _updateStock,
                                  allowDiscountChange: _allowDiscountChange,
                                  allowRateChange: _allowRateChange,
                                  allowPartialPayment: _allowPartialPayment,
                                );

                                context.read<PosProfileBloc>().add(
                                  CreateProfilePos(
                                    companyProfileRequest: request,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: state is PosProfileStateLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Create Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reset Button
                    Center(
                      child: TextButton(
                        onPressed: state is PosProfileStateLoading
                            ? null
                            : () {
                                _profileNameController.clear();
                                setState(() {
                                  _updateStock = true;
                                  _allowDiscountChange = true;
                                  _allowRateChange = true;
                                  _allowPartialPayment = true;
                                });
                              },
                        child: Text(
                          'Reset Form',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
