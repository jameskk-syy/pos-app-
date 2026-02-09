import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/crm/get_loyalty_programs_request.dart';
import 'package:pos/domain/responses/crm/create_loyalty_program_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';

class AssignLoyaltyDialog extends StatefulWidget {
  final String customerName;
  final String companyName;
  final Function(String) onAssign;
  final VoidCallback onCancel;

  const AssignLoyaltyDialog({
    super.key,
    required this.customerName,
    required this.companyName,
    required this.onAssign,
    required this.onCancel,
  });

  @override
  State<AssignLoyaltyDialog> createState() => _AssignLoyaltyDialogState();
}

class _AssignLoyaltyDialogState extends State<AssignLoyaltyDialog> {
  dynamic _selectedProgram;
  List<dynamic> _allPrograms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchLoyaltyPrograms();
      }
    });
  }

  void _fetchLoyaltyPrograms() {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = GetLoyaltyProgramsRequest(activeOnly: true);
      final bloc = context.read<InventoryBloc>();
      bloc.add(GetLoyaltyPrograms(request: request));
    } catch (e) {
      debugPrint('Error dispatching GetLoyaltyPrograms: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to dispatch request: $e';
        });
      }
    }
  }

  double _calculatePointsRequired(dynamic program) {
    if (program is LoyaltyProgram) {
      if (program.collectionRules.isEmpty) return 0.0;
      final minSpent = program.collectionRules
          .map((rule) => rule.minSpent)
          .reduce((a, b) => a < b ? a : b);
      return minSpent * program.conversionFactor;
    }
    return 0.0;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No expiry';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  bool _isProgramActive(dynamic program) {
    final fromDateStr = (program is LoyaltyProgram)
        ? program.fromDate
        : (program.fromDate ?? '');
    final toDateStr = (program is LoyaltyProgram)
        ? program.toDate
        : (program.toDate ?? '');

    if (toDateStr.isEmpty) {
      return true; // If no end date, assume active if started
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final to = DateTime.parse(toDateStr);
      final toDate = DateTime(to.year, to.month, to.day);

      // Check if expired
      if (today.isAfter(toDate)) return false;

      // Check if started
      if (fromDateStr.isNotEmpty) {
        final from = DateTime.parse(fromDateStr);
        final fromDate = DateTime(from.year, from.month, from.day);
        if (today.isBefore(fromDate)) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  String _getProgramName(dynamic program) {
    return (program is LoyaltyProgram)
        ? program.loyaltyProgramName
        : program.loyaltyProgramName ?? '';
  }

  String _getProgramType(dynamic program) {
    return (program is LoyaltyProgram)
        ? program.loyaltyProgramType
        : program.loyaltyProgramType ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is GetLoyaltyProgramsLoaded) {
          if (!mounted) return;

          final programs = state.response.message.programs
              .where((program) => _isProgramActive(program))
              .toList();

          setState(() {
            _isLoading = false;
            _allPrograms = programs;
          });
        } else if (state is GetLoyaltyProgramsError) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        }
      },
      child: _buildDialog(),
    );
  }

  Widget _buildDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    final double dialogWidth;
    final double dialogHeight;

    if (isMobile) {
      dialogWidth = screenWidth - 32;
      dialogHeight = 450;
    } else if (isTablet) {
      dialogWidth = 500;
      dialogHeight = 500;
    } else {
      dialogWidth = 600;
      dialogHeight = 500;
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : (screenWidth - dialogWidth) / 2,
        vertical: isMobile ? 16.0 : 40.0,
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isMobile),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(isMobile)
                  : _errorMessage != null
                  ? _buildErrorState(isMobile)
                  : _buildContent(isMobile),
            ),
            _buildFooter(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Assign Loyalty Program',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: isMobile ? 20 : 22,
              color: Colors.grey[600],
            ),
            onPressed: widget.onCancel,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? 40 : 48,
            height: isMobile ? 40 : 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            'Loading loyalty programs...',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isMobile ? 48 : 56,
              color: Colors.red[400],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Text(
              'Failed to load programs',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 20 : 24),
            ElevatedButton.icon(
              onPressed: _fetchLoyaltyPrograms,
              icon: Icon(Icons.refresh, size: isMobile ? 18 : 20),
              label: Text(
                'Retry',
                style: TextStyle(fontSize: isMobile ? 14 : 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 24,
                  vertical: isMobile ? 12 : 14,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: isMobile ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomerInfo(isMobile),
          SizedBox(height: isMobile ? 24 : 32),
          _buildDropdownField(isMobile),
          SizedBox(height: isMobile ? 16 : 20),
          if (_selectedProgram != null) _buildProgramDetails(isMobile),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: Colors.blue[700],
            size: isMobile ? 20 : 22,
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigning to:',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  widget.customerName,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(bool isMobile) {
    if (_allPrograms.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Loyalty Program*',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 10),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                'No loyalty programs available',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Loyalty Program*',
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: _selectedProgram,
              hint: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 14 : 16,
                ),
                child: Text(
                  'Choose a loyalty program...',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsets.only(right: isMobile ? 12 : 16),
                child: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
              ),
              items: _allPrograms.map((program) {
                final programName = _getProgramName(program);
                final programType = _getProgramType(program);

                return DropdownMenuItem<dynamic>(
                  value: program,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: 8,
                    ),
                    child: Text(
                      '$programName ($programType)',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProgram = value;
                });
              },
            ),
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Text(
          '${_allPrograms.length} program${_allPrograms.length == 1 ? '' : 's'} available',
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgramDetails(bool isMobile) {
    final programName = _getProgramName(_selectedProgram);
    final programType = _getProgramType(_selectedProgram);
    final points = _calculatePointsRequired(_selectedProgram);

    final toDate = (_selectedProgram is LoyaltyProgram)
        ? _selectedProgram.toDate
        : (_selectedProgram?.toDate ?? '');

    // Safely get customerGroup with null checking
    String? customerGroup;
    try {
      if (_selectedProgram is LoyaltyProgram) {
        customerGroup = _selectedProgram.customerGroup;
      } else {
        customerGroup = _selectedProgram?.customerGroup;
      }
    } catch (e) {
      customerGroup = null;
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: isMobile ? 20 : 22,
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Expanded(
                child: Text(
                  'Program Selected',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[900],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 14),
          Divider(color: Colors.green[200], height: 1),
          SizedBox(height: isMobile ? 12 : 14),
          _buildDetailRow('Program Name', programName, isMobile),
          SizedBox(height: isMobile ? 8 : 10),
          _buildDetailRow('Program Type', programType, isMobile),
          if (points > 0) ...[
            SizedBox(height: isMobile ? 8 : 10),
            _buildDetailRow(
              'Points Required',
              '${points.toStringAsFixed(0)} pts',
              isMobile,
            ),
          ],
          if (customerGroup != null && customerGroup.isNotEmpty) ...[
            SizedBox(height: isMobile ? 8 : 10),
            _buildDetailRow('Customer Group', customerGroup, isMobile),
          ],
          SizedBox(height: isMobile ? 8 : 10),
          _buildDetailRow('Expires', _formatDate(toDate), isMobile),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isMobile ? 120 : 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _selectedProgram != null &&
                      !_isLoading &&
                      _errorMessage == null
                  ? () {
                      final programName = (_selectedProgram is LoyaltyProgram)
                          ? _selectedProgram!.name
                          : _selectedProgram?.name ?? '';
                      widget.onAssign(programName);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Text(
                'Assign Program',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
