class CreateLoyaltyProgramRequest {
  final String loyaltyProgramName;
  final double pointsPerUnit;
  final String programType;
  final String tierName;
  final String fromDate;
  final String toDate;

  CreateLoyaltyProgramRequest({
    required this.loyaltyProgramName,
    required this.pointsPerUnit,
    required this.programType,
    required this.tierName,
    required this.fromDate,
    required this.toDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'loyalty_program_name': loyaltyProgramName,
      'points_per_unit': pointsPerUnit,
      'program_type': programType,
      'tier_name': tierName,
      'from_date': fromDate,
      'to_date': toDate,
    };
  }
}