class LoyaltyBalanceResponse {
  final String status;
  final String customer;
  final bool hasLoyaltyProgram;
  final String? loyaltyProgram;
  final String? loyaltyProgramName;
  final double pointsBalance; // Map to loyalty_points from new API
  final double conversionFactor;
  final double maxRedeemableAmount;
  final int maxRedeemablePoints;
  final String? expenseAccount;
  final String? costCenter;
  final String? tierName;
  final double totalSpent;
  final List<LoyaltyTransaction> recentTransactions;
  final List<String> debug;

  LoyaltyBalanceResponse({
    required this.status,
    required this.customer,
    required this.hasLoyaltyProgram,
    this.loyaltyProgram,
    this.loyaltyProgramName,
    required this.pointsBalance,
    required this.conversionFactor,
    required this.maxRedeemableAmount,
    required this.maxRedeemablePoints,
    this.expenseAccount,
    this.costCenter,
    this.tierName,
    required this.totalSpent,
    this.recentTransactions = const [],
    this.debug = const [],
  });

  factory LoyaltyBalanceResponse.fromJson(Map<String, dynamic> json) {
    return LoyaltyBalanceResponse(
      status: json['status']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
      hasLoyaltyProgram: json['has_loyalty_program'] ?? false,
      loyaltyProgram: json['loyalty_program']?.toString(),
      loyaltyProgramName: json['loyalty_program_name']?.toString(),
      pointsBalance: (json['loyalty_points'] ?? json['points_balance'] ?? 0)
          .toDouble(),
      conversionFactor: (json['conversion_factor'] ?? 0.0).toDouble(),
      maxRedeemableAmount: (json['max_redeemable_amount'] ?? 0.0).toDouble(),
      maxRedeemablePoints: (json['max_redeemable_points'] ?? 0).toInt(),
      expenseAccount: json['expense_account']?.toString(),
      costCenter: json['cost_center']?.toString(),
      tierName: json['tier_name']?.toString(),
      totalSpent: (json['total_spent'] ?? 0.0).toDouble(),
      recentTransactions:
          (json['recent_transactions'] as List?)
              ?.map((transaction) => LoyaltyTransaction.fromJson(transaction))
              .toList() ??
          [],
      debug: List<String>.from(json['debug'] ?? []),
    );
  }
}

class LoyaltyTransaction {
  final int pointsEarned;
  final String transactionType;
  final double purchaseAmount;
  final String date;
  final String? referenceDocument;

  LoyaltyTransaction({
    required this.pointsEarned,
    required this.transactionType,
    required this.purchaseAmount,
    required this.date,
    this.referenceDocument,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      pointsEarned: (json['points_earned'] ?? 0).toInt(),
      transactionType: json['transaction_type']?.toString() ?? '',
      purchaseAmount: (json['purchase_amount'] ?? 0.0).toDouble(),
      date: json['date']?.toString() ?? '',
      referenceDocument: json['reference_document']?.toString(),
    );
  }
}

class RedeemPointsRequest {
  final String customerId;
  final double pointsToRedeem;

  RedeemPointsRequest({required this.customerId, required this.pointsToRedeem});

  Map<String, dynamic> toJson() {
    return {'customer_id': customerId, 'points_to_redeem': pointsToRedeem};
  }
}

class RedeemPointsResponse {
  final String status;
  final String message;
  final double redeemedPoints;
  final double remainingPoints;
  final String? referenceDocument;
  final List<String> debug;

  RedeemPointsResponse({
    required this.status,
    required this.message,
    required this.redeemedPoints,
    required this.remainingPoints,
    this.referenceDocument,
    required this.debug,
  });

  factory RedeemPointsResponse.fromJson(Map<String, dynamic> json) {
    return RedeemPointsResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      redeemedPoints: (json['redeemed_points'] ?? 0.0).toDouble(),
      remainingPoints: (json['remaining_points'] ?? 0.0).toDouble(),
      referenceDocument: json['reference_document']?.toString(),
      debug: List<String>.from(json['debug'] ?? []),
    );
  }
}

class EarnLoyaltyPointsRequest {
  final String customerId;
  final double purchaseAmount;

  EarnLoyaltyPointsRequest({
    required this.customerId,
    required this.purchaseAmount,
  });

  Map<String, dynamic> toJson() {
    return {'customer_id': customerId, 'purchase_amount': purchaseAmount};
  }
}

class EarnLoyaltyPointsResponse {
  final String status;
  final String message;
  final int pointsEarned;
  final int totalPoints;
  final List<String> debug;

  EarnLoyaltyPointsResponse({
    required this.status,
    required this.message,
    required this.pointsEarned,
    required this.totalPoints,
    required this.debug,
  });

  factory EarnLoyaltyPointsResponse.fromJson(Map<String, dynamic> json) {
    return EarnLoyaltyPointsResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      pointsEarned: (json['points_earned'] ?? 0).toInt(),
      totalPoints: (json['total_points'] ?? 0).toInt(),
      debug: List<String>.from(json['debug'] ?? []),
    );
  }
}
