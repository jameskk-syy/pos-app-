class PosOpeningEntryResponse {
  final bool success;
  final List<PosOpeningEntry> data;
  final int count;

  PosOpeningEntryResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  factory PosOpeningEntryResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    return PosOpeningEntryResponse(
      success: message['success'] ?? false,
      data: (message['data'] as List? ?? [])
          .map((e) => PosOpeningEntry.fromJson(e))
          .toList(),
      count: message['count'] ?? 0,
    );
  }
}

class PosOpeningEntry {
  final String name;
  final String posProfile;
  final String company;
  final String user;
  final String status;
  final String postingDate;
  final String? periodStartDate;
  final String? periodEndDate;
  final String? posClosingEntry;
  final int docstatus;
  final String creation;
  final String modified;
  final List<BalanceDetail> balanceDetails;

  PosOpeningEntry({
    required this.name,
    required this.posProfile,
    required this.company,
    required this.user,
    required this.status,
    required this.postingDate,
    this.periodStartDate,
    this.periodEndDate,
    this.posClosingEntry,
    required this.docstatus,
    required this.creation,
    required this.modified,
    required this.balanceDetails,
  });

  factory PosOpeningEntry.fromJson(Map<String, dynamic> json) {
    return PosOpeningEntry(
      name: json['name'] ?? '',
      posProfile: json['pos_profile'] ?? '',
      company: json['company'] ?? '',
      user: json['user'] ?? '',
      status: json['status'] ?? '',
      postingDate: json['posting_date'] ?? '',
      periodStartDate: json['period_start_date'],
      periodEndDate: json['period_end_date'],
      posClosingEntry: json['pos_closing_entry'],
      docstatus: json['docstatus'] ?? 0,
      creation: json['creation'] ?? '',
      modified: json['modified'] ?? '',
      balanceDetails: (json['balance_details'] as List? ?? [])
          .map((e) => BalanceDetail.fromJson(e))
          .toList(),
    );
  }
}

class BalanceDetail {
  final String modeOfPayment;
  final double openingAmount;

  BalanceDetail({required this.modeOfPayment, required this.openingAmount});

  factory BalanceDetail.fromJson(Map<String, dynamic> json) {
    return BalanceDetail(
      modeOfPayment: json['mode_of_payment'] ?? '',
      openingAmount: (json['opening_amount'] as num? ?? 0.0).toDouble(),
    );
  }
}

class ClosePosOpeningEntryResponse {
  final bool success;
  final String? message;
  final String? errorType;

  ClosePosOpeningEntryResponse({
    required this.success,
    this.message,
    this.errorType,
  });

  factory ClosePosOpeningEntryResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>;
    return ClosePosOpeningEntryResponse(
      success: message['success'] ?? false,
      message: message['message'],
      errorType: message['error_type'],
    );
  }
}
