import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/create_loyalty_program_request.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  State<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _programNameController = TextEditingController();
  final _pointsPerUnitController = TextEditingController();
  final _tierNameController = TextEditingController(text: 'Bronze');
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  
  String _selectedProgramType = 'Single Tier Program';

  @override
  void dispose() {
    _programNameController.dispose();
    _pointsPerUnitController.dispose();
    _tierNameController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1E88E5),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _createLoyaltyProgram() {
    if (_formKey.currentState!.validate()) {
      final pointsPerUnit = double.tryParse(_pointsPerUnitController.text);
      if (pointsPerUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Please enter a valid number for Points Per Unit'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      final request = CreateLoyaltyProgramRequest(
        loyaltyProgramName: _programNameController.text.trim(),
        pointsPerUnit: pointsPerUnit,
        programType: _selectedProgramType,
        tierName: _tierNameController.text.trim(),
        fromDate: _fromDateController.text.trim(),
        toDate: _toDateController.text.trim(),
      );
      context.read<InventoryBloc>().add(
        CreateLoyaltyProgram(request: request),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1E88E5)),
        title: Text(
          'Create Loyalty Program',
          style: TextStyle(
            color: const Color(0xFF1E40AF),
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocListener<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is CreateLoyaltyProgramLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Creating Program...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is CreateLoyaltyProgramSuccess) {
            Navigator.of(context).pop();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(state.response.message.message),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            _programNameController.clear();
            _pointsPerUnitController.clear();
            _tierNameController.text = 'Bronze';
            _fromDateController.clear();
            _toDateController.clear();
            setState(() {
              _selectedProgramType = 'Single Tier Program';
            });

            Navigator.of(context).pop();
          } else if (state is CreateLoyaltyProgramError) {
            Navigator.of(context).pop();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints(
                maxWidth: isTablet ? 700 : double.infinity,
              ),
              margin: EdgeInsets.all(isMobile ? 12 : 16),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Program Name
                        _buildTextField(
                          controller: _programNameController,
                          label: 'Program Name',
                          icon: Icons.card_giftcard,
                          required: true,
                          isMobile: isMobile,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        
                        // Points Per Unit and Program Type
                        if (isMobile) ...[
                          _buildTextField(
                            controller: _pointsPerUnitController,
                            label: 'Points Per Unit',
                            icon: Icons.trending_up,
                            helperText: 'e.g., 10 = 1 point per 10 units',
                            required: true,
                            keyboardType: TextInputType.number,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          _buildDropdown(isMobile),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _pointsPerUnitController,
                                  label: 'Points Per Unit',
                                  icon: Icons.trending_up,
                                  helperText: 'e.g., 10 = 1 point per 10 units',
                                  required: true,
                                  keyboardType: TextInputType.number,
                                  isMobile: isMobile,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdown(isMobile),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: isMobile ? 16 : 20),
                        
                        // Tier Name
                        _buildTextField(
                          controller: _tierNameController,
                          label: 'Tier Name',
                          icon: Icons.workspace_premium,
                          helperText: 'e.g., Bronze, Silver, Gold',
                          isMobile: isMobile,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        
                        // Date Range Section
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Color(0xFF1E88E5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Program Duration (Optional)',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E40AF),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isMobile ? 12 : 16),
                              if (isMobile) ...[
                                _buildDateField(
                                  controller: _fromDateController,
                                  label: 'From Date',
                                  isMobile: isMobile,
                                ),
                                const SizedBox(height: 12),
                                _buildDateField(
                                  controller: _toDateController,
                                  label: 'To Date',
                                  isMobile: isMobile,
                                ),
                              ] else ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateField(
                                        controller: _fromDateController,
                                        label: 'From Date',
                                        isMobile: isMobile,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDateField(
                                        controller: _toDateController,
                                        label: 'To Date',
                                        isMobile: isMobile,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                'Leave empty for unlimited duration',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 24),
                      
                        if (isMobile) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _createLoyaltyProgram,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Create Program',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _createLoyaltyProgram,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Create Program',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helperText,
    bool required = false,
    TextInputType? keyboardType,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1E88E5)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 14,
              vertical: isMobile ? 12 : 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          style: TextStyle(fontSize: isMobile ? 14 : 15),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 10 : 12,
            ),
            hintText: 'yyyy-mm-dd',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 18,
              color: Color(0xFF1E88E5),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
            ),
          ),
          style: TextStyle(fontSize: isMobile ? 13 : 14),
        ),
      ],
    );
  }

  Widget _buildDropdown(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category, size: 18, color: Color(0xFF1E88E5)),
            const SizedBox(width: 8),
            Text(
              'Program Type',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (String value) {
              setState(() {
                _selectedProgramType = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              _buildPopupMenuItem('Single Tier Program', Icons.layers, isMobile),
              _buildPopupMenuItem('Multiple Tier Program', Icons.stairs, isMobile),
              _buildPopupMenuItem('Points Only', Icons.stars, isMobile),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 14,
                vertical: isMobile ? 12 : 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedProgramType,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more, color: Color(0xFF1E88E5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, bool isMobile) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E88E5)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: isMobile ? 13 : 14),
            ),
          ),
        ],
      ),
    );
  }
}