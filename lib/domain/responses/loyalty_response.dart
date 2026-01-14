class LoyaltyBalanceResponse {
  final String status;
  final String customer;
  final double pointsBalance;
  final List<LoyaltyTransaction> recentTransactions;
  final List<String> debug;

  LoyaltyBalanceResponse({
    required this.status,
    required this.customer,
    required this.pointsBalance,
    required this.recentTransactions,
    required this.debug,
  });

  factory LoyaltyBalanceResponse.fromJson(Map<String, dynamic> json) {
    return LoyaltyBalanceResponse(
      status: json['status'],
      customer: json['customer'],
      pointsBalance: (json['points_balance'] as num).toDouble(),
      recentTransactions: (json['recent_transactions'] as List)
          .map((transaction) => LoyaltyTransaction.fromJson(transaction))
          .toList(),
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
      pointsEarned: json['points_earned'],
      transactionType: json['transaction_type'],
      purchaseAmount: (json['purchase_amount'] as num).toDouble(),
      date: json['date'],
      referenceDocument: json['reference_document'],
    );
  }
}

class RedeemPointsRequest {
  final String customerId;
  final double pointsToRedeem;

  RedeemPointsRequest({
    required this.customerId,
    required this.pointsToRedeem,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'points_to_redeem': pointsToRedeem,
    };
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
      status: json['status'],
      message: json['message'],
      redeemedPoints: (json['redeemed_points'] as num).toDouble(),
      remainingPoints: (json['remaining_points'] as num).toDouble(),
      referenceDocument: json['reference_document'],
      debug: List<String>.from(json['debug'] ?? []),
    );
  }
}