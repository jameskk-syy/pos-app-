import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';

class RedeemPointsDialog extends StatefulWidget {
  final String customerId;
  final String customerName;
  final double? invoiceAmount;
  final String? company;

  const RedeemPointsDialog({
    super.key,
    required this.customerId,
    required this.customerName,
    this.invoiceAmount,
    this.company,
  });

  @override
  State<RedeemPointsDialog> createState() => _RedeemPointsDialogState();
}

class _RedeemPointsDialogState extends State<RedeemPointsDialog> {
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  double? _availablePoints;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrmBloc>().add(
        GetLoyaltyBalance(
          customerId: widget.customerId,
          invoiceAmount: widget.invoiceAmount,
          company: widget.company,
        ),
      );
    });
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrmBloc, CrmState>(
      listener: (context, state) {
        if (state is LoyaltyBalanceLoaded) {
          setState(() {
            _availablePoints = state.balanceResponse.pointsBalance;
          });
        } else if (state is PointsRedeemSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully redeemed ${state.redeemResponse.redeemedPoints.toStringAsFixed(0)} points',
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is LoyaltyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            // Remove dialog border radius
            borderRadius: BorderRadius.zero,
          ),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 800, // Increased width
              maxHeight: 700, // Reduced max height
            ),
            padding: const EdgeInsets.all(24), // Reduced padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.redeem,
                        color: Color(0xFF3B82F6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Redeem Loyalty Points',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.customerName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Available Points Section (Simplified, no blue card)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.zero, // No rounded corners
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_availablePoints != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _availablePoints!.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'points',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (state is LoyaltyBalanceLoaded &&
                                state.balanceResponse.maxRedeemableAmount >
                                    0) ...[
                              const SizedBox(width: 40),
                              Container(
                                height: 40,
                                width: 1,
                                color: const Color(0xFFE2E8F0),
                              ),
                              const SizedBox(width: 40),
                              Column(
                                children: [
                                  Text(
                                    state.balanceResponse.maxRedeemableAmount
                                        .toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'max redeemable (KES)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        )
                      else if (state is LoyaltyLoading)
                        const SizedBox(
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF3B82F6),
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      else
                        const Text(
                          '0',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Points to Redeem Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Points to Redeem',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter points amount',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: _availablePoints != null
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.stars,
                                    size: 16,
                                    color: Color(0xFF3B82F6),
                                  ),
                                  label: const Text(
                                    'Use all',
                                    style: TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    _pointsController.text = _availablePoints!
                                        .toStringAsFixed(0);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        if (_availablePoints != null && value.isNotEmpty) {
                          final enteredPoints = double.tryParse(value) ?? 0;
                          if (enteredPoints > _availablePoints!) {
                            _pointsController.text = _availablePoints!
                                .toStringAsFixed(0);
                          }
                        }
                      },
                    ),
                    if (_availablePoints != null &&
                        _pointsController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Maximum ${_availablePoints!.toStringAsFixed(0)} points available',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reference Document Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reference Document',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Optional - e.g., Invoice or receipt number',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _referenceController,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter reference number',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.zero, // No rounded corners
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: state is LoyaltyLoading
                            ? null
                            : () {
                                final pointsText = _pointsController.text
                                    .trim();
                                if (pointsText.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Please enter points to redeem',
                                      ),
                                      backgroundColor: const Color(0xFFF59E0B),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final points = double.tryParse(pointsText);
                                if (points == null || points <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Please enter valid points amount',
                                      ),
                                      backgroundColor: const Color(0xFFF59E0B),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final maxRedeemablePoints =
                                    (state is LoyaltyBalanceLoaded)
                                    ? state.balanceResponse.maxRedeemablePoints
                                    : _availablePoints?.toInt() ?? 0;

                                if (maxRedeemablePoints > 0 &&
                                    points > maxRedeemablePoints) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cannot redeem more than $maxRedeemablePoints points for this invoice',
                                      ),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (_availablePoints != null &&
                                    points > _availablePoints!) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cannot redeem more than ${_availablePoints!.toStringAsFixed(0)} points',
                                      ),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                context.read<CrmBloc>().add(
                                  RedeemPoints(
                                    customerId: widget.customerId,
                                    pointsToRedeem: points,
                                    referenceDocument:
                                        _referenceController.text.isNotEmpty
                                        ? _referenceController.text
                                        : null,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.zero, // No rounded corners
                          ),
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                        ),
                        child: state is LoyaltyLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Redeem Points',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
