import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/crm/create_loyalty_program_request.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:pos/screens/crm/widgets/loyalty_text_field.dart';
import 'package:pos/screens/crm/widgets/loyalty_date_field.dart';
import 'package:pos/screens/crm/widgets/loyalty_dropdown_field.dart';

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
  final _conversionFactorController = TextEditingController();
  final _expenseAccountController = TextEditingController();
  final _costCenterController = TextEditingController();
  final _expiryDurationController = TextEditingController();

  String _selectedProgramType = 'Single Tier Program';

  @override
  void dispose() {
    _programNameController.dispose();
    _pointsPerUnitController.dispose();
    _tierNameController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _conversionFactorController.dispose();
    _expenseAccountController.dispose();
    _costCenterController.dispose();
    _expiryDurationController.dispose();
    super.dispose();
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

      DateTime? fromDate = DateTime.tryParse(_fromDateController.text);
      DateTime? toDate = DateTime.tryParse(_toDateController.text);

      if (fromDate == null || toDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select valid From and To dates'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final conversionFactor =
          double.tryParse(_conversionFactorController.text) ?? 0.0;
      final expiryDuration = toDate.difference(fromDate).inDays;

      final request = CreateLoyaltyProgramRequest(
        loyaltyProgramName: _programNameController.text.trim(),
        pointsPerUnit: pointsPerUnit,
        programType: _selectedProgramType,
        tierName: _tierNameController.text.trim(),
        fromDate: _fromDateController.text.trim(),
        toDate: _toDateController.text.trim(),
        conversionFactor: conversionFactor,
        expenseAccount: "",
        costCenter: "",
        expiryDuration: expiryDuration,
      );
      context.read<InventoryBloc>().add(CreateLoyaltyProgram(request: request));
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1E88E5),
                        ),
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
                    Expanded(child: Text(state.response.message.message)),
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
            _conversionFactorController.clear();
            _expenseAccountController.clear();
            _costCenterController.clear();
            _expiryDurationController.clear();
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
                        LoyaltyTextField(
                          controller: _programNameController,
                          label: 'Program Name',
                          icon: Icons.card_giftcard,
                          required: true,
                          isMobile: isMobile,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),

                        // Points Per Unit and Program Type
                        if (isMobile) ...[
                          LoyaltyTextField(
                            controller: _pointsPerUnitController,
                            label: 'Points Per Unit',
                            icon: Icons.trending_up,
                            helperText: 'e.g., 10 = 1 point per 10 units',
                            required: true,
                            keyboardType: TextInputType.number,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          LoyaltyDropdownField(
                            label: 'Program Type',
                            value: _selectedProgramType,
                            items: const [
                              'Single Tier Program',
                              'Multiple Tier Program',
                              'Points Only',
                            ],
                            isMobile: isMobile,
                            onChanged: (v) =>
                                setState(() => _selectedProgramType = v),
                          ),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: LoyaltyTextField(
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
                                child: LoyaltyDropdownField(
                                  label: 'Program Type',
                                  value: _selectedProgramType,
                                  items: const [
                                    'Single Tier Program',
                                    'Multiple Tier Program',
                                    'Points Only',
                                  ],
                                  isMobile: isMobile,
                                  onChanged: (v) =>
                                      setState(() => _selectedProgramType = v),
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: isMobile ? 16 : 20),

                        // Tier Name
                        LoyaltyTextField(
                          controller: _tierNameController,
                          label: 'Tier Name',
                          icon: Icons.workspace_premium,
                          helperText: 'e.g., Bronze, Silver, Gold',
                          isMobile: isMobile,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),

                        // Conversion Factor
                        LoyaltyTextField(
                          controller: _conversionFactorController,
                          label: 'Conversion Factor',
                          icon: Icons.sync_alt,
                          helperText: 'e.g., 0.001',
                          keyboardType: TextInputType.number,
                          isMobile: isMobile,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),

                        // Expense Account and Cost Center - HIDDEN
                        /*
                        if (isMobile) ...[
                          _buildTextField( ... )
                        ]
                        */

                        // Expiry Duration - HIDDEN
                        /*
                        _buildTextField(
                          controller: _expiryDurationController,
                          label: 'Expiry Duration (Days)',
                          icon: Icons.timer,
                          helperText: 'e.g., 20',
                          keyboardType: TextInputType.number,
                          isMobile: isMobile,
                        ),
                        */
                        SizedBox(height: isMobile ? 16 : 20),

                        // Date Range Section
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(color: Colors.white),
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
                                    'Program Duration',
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
                                LoyaltyDateField(
                                  controller: _fromDateController,
                                  label: 'From Date',
                                  required: true,
                                  isMobile: isMobile,
                                ),
                                const SizedBox(height: 12),
                                LoyaltyDateField(
                                  controller: _toDateController,
                                  label: 'To Date',
                                  required: true,
                                  isMobile: isMobile,
                                ),
                              ] else ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: LoyaltyDateField(
                                        controller: _fromDateController,
                                        label: 'From Date',
                                        required: true,
                                        isMobile: isMobile,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: LoyaltyDateField(
                                        controller: _toDateController,
                                        label: 'To Date',
                                        required: true,
                                        isMobile: isMobile,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              // Text(
                              //   'Leave empty for unlimited duration',
                              //   style: TextStyle(
                              //     fontSize: 11,
                              //     color: Colors.grey[600],
                              //     fontStyle: FontStyle.italic,
                              //   ),
                              // ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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

}
