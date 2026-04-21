import 'package:flutter/material.dart';
import 'package:pos/domain/responses/crm/loyalty_response.dart';
import 'checkout_common_widgets.dart';

class CheckoutSummarySection extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double commission;
  final double total;

  const CheckoutSummarySection({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.commission,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckoutRow(label: 'Subtotal', value: 'KES ${subtotal.toStringAsFixed(2)}'),
        CheckoutRow(label: 'Product Discount', value: 'KES ${discount.toStringAsFixed(2)}'),
        CheckoutRow(label: 'Product Commission', value: 'KES ${commission.toStringAsFixed(2)}'),
        CheckoutRow(label: 'Sales Amount', value: 'KES ${total.toStringAsFixed(2)}'),
      ],
    );
  }
}

class CheckoutLoyaltySection extends StatelessWidget {
  final LoyaltyBalanceResponse? loyaltyDetails;

  const CheckoutLoyaltySection({super.key, this.loyaltyDetails});

  @override
  Widget build(BuildContext context) {
    if (loyaltyDetails == null || !loyaltyDetails!.hasLoyaltyProgram) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        CheckoutRow(
          label: 'Loyalty Program',
          value: loyaltyDetails!.loyaltyProgramName ?? 'No Program',
          textColor: Colors.blue.shade700,
        ),
        CheckoutRow(
          label: 'Available Points',
          value: '${loyaltyDetails!.pointsBalance.toStringAsFixed(0)} pts',
          textColor: Colors.blue.shade700,
        ),
        if (loyaltyDetails!.maxRedeemableAmount > 0)
          CheckoutRow(
            label: 'Max Redeemable',
            value: 'KES ${loyaltyDetails!.maxRedeemableAmount.toStringAsFixed(2)}',
            textColor: Colors.green.shade700,
          ),
      ],
    );
  }
}
