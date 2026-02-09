class CreateLoyaltyProgramRequest {
  final String loyaltyProgramName;
  final double pointsPerUnit;
  final String programType;
  final String tierName;
  final String fromDate;
  final String toDate;
  final double conversionFactor;
  final String expenseAccount;
  final String costCenter;
  final int expiryDuration;

  CreateLoyaltyProgramRequest({
    required this.loyaltyProgramName,
    required this.pointsPerUnit,
    required this.programType,
    required this.tierName,
    required this.fromDate,
    required this.toDate,
    required this.conversionFactor,
    required this.expenseAccount,
    required this.costCenter,
    required this.expiryDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'loyalty_program_name': loyaltyProgramName,
      'points_per_unit': pointsPerUnit,
      'program_type': programType,
      'tier_name': tierName,
      'from_date': fromDate,
      'to_date': toDate,
      'conversion_factor': conversionFactor,
      'expense_account': expenseAccount,
      'cost_center': costCenter,
      'expiry_duration': expiryDuration,
    };
  }
}
