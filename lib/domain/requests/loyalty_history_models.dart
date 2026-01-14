class LoyaltyHistoryRequest {
  final String customerId;
  final int limit;
  final int page;
  final String? transactionType;

  LoyaltyHistoryRequest({
    required this.customerId,
    this.limit = 50,
    this.page = 1,
    this.transactionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'limit': limit,
      'page': page,
      'transaction_type': transactionType,
    };
  }
}

class LoyaltyHistoryResponse {
  final String status;
  final String customer;
  final Pagination pagination;
  final Filters filters;
  final List<LoyaltyHistoryTransaction> transactions;
  final List<String> debug;

  LoyaltyHistoryResponse({
    required this.status,
    required this.customer,
    required this.pagination,
    required this.filters,
    required this.transactions,
    required this.debug,
  });

  factory LoyaltyHistoryResponse.fromJson(Map<String, dynamic> json) {
    return LoyaltyHistoryResponse(
      status: json['status'],
      customer: json['customer'],
      pagination: Pagination.fromJson(json['pagination']),
      filters: Filters.fromJson(json['filters']),
      transactions: (json['transactions'] as List)
          .map((transaction) => LoyaltyHistoryTransaction.fromJson(transaction))
          .toList(),
      debug: List<String>.from(json['debug'] ?? []),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int totalRecords;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.totalRecords,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      limit: json['limit'],
      totalRecords: json['total_records'],
      totalPages: json['total_pages'],
    );
  }
}

class Filters {
  final String? startDate;
  final String? endDate;
  final String? transactionType;

  Filters({
    this.startDate,
    this.endDate,
    this.transactionType,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      startDate: json['start_date'],
      endDate: json['end_date'],
      transactionType: json['transaction_type'],
    );
  }
}

class LoyaltyHistoryTransaction {
  final String name;
  final String date;
  final String transactionType;
  final int pointsEarned;
  final double purchaseAmount;
  final String? referenceDocument;

  LoyaltyHistoryTransaction({
    required this.name,
    required this.date,
    required this.transactionType,
    required this.pointsEarned,
    required this.purchaseAmount,
    required this.referenceDocument,
  });

  factory LoyaltyHistoryTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyHistoryTransaction(
      name: json['name'],
      date: json['date'],
      transactionType: json['transaction_type'],
      pointsEarned: json['points_earned'],
      purchaseAmount: (json['purchase_amount'] as num).toDouble(),
      referenceDocument: json['reference_document'],
    );
  }
}