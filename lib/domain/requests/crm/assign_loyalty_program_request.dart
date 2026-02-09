import 'dart:convert';

class AssignLoyaltyProgramRequest {
  final String customerId;
  final String loyaltyProgramName;

  AssignLoyaltyProgramRequest({
    required this.customerId,
    required this.loyaltyProgramName,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'loyalty_program_name': loyaltyProgramName,
    };
  }

  String toRawJson() => json.encode(toJson());
}