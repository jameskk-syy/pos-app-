class POSSessionRequest {
  final String posProfile;
  final String company;
  final String user;
  final List<BalanceDetail> balanceDetails;

  POSSessionRequest({
    required this.posProfile,
    required this.company,
    required this.user,
    required this.balanceDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'pos_profile': posProfile,
      'company': company,
      'user': user,
      'balance_details': balanceDetails.map((e) => e.toJson()).toList(),
    };
  }

  factory POSSessionRequest.fromJson(Map<String, dynamic> json) {
    return POSSessionRequest(
      posProfile: json['pos_profile'],
      company: json['company'],
      user: json['user'],
      balanceDetails: (json['balance_details'] as List)
          .map((e) => BalanceDetail.fromJson(e))
          .toList(),
    );
  }
}

class BalanceDetail {
  final String modeOfPayment;
  final double openingAmount;

  BalanceDetail({required this.modeOfPayment, required this.openingAmount});

  Map<String, dynamic> toJson() {
    return {'mode_of_payment': modeOfPayment, 'opening_amount': openingAmount};
  }

  factory BalanceDetail.fromJson(Map<String, dynamic> json) {
    return BalanceDetail(
      modeOfPayment: json['mode_of_payment'],
      openingAmount: (json['opening_amount'] as num).toDouble(),
    );
  }
}

class POSSessionResponse {
  final String name;
  final String posProfile;
  final String company;
  final String user;
  final String status;
  final String postingDate;
  final String periodStartDate;
  final List<BalanceDetail> balanceDetails;

  POSSessionResponse({
    required this.name,
    required this.posProfile,
    required this.company,
    required this.user,
    required this.status,
    required this.postingDate,
    required this.periodStartDate,
    required this.balanceDetails,
  });

  factory POSSessionResponse.fromJson(Map<String, dynamic> json) {
    return POSSessionResponse(
      name: json['name'] ?? '',
      posProfile: json['pos_profile'] ?? '',
      company: json['company'] ?? '',
      user: json['user'] ?? '',
      status: json['status'] ?? '',
      postingDate: json['posting_date'] ?? '',
      periodStartDate: json['period_start_date'] ?? '',
      balanceDetails:
          (json['balance_details'] as List<dynamic>?)
              ?.map(
                (e) => BalanceDetail(
                  modeOfPayment: e['mode_of_payment'] ?? '',
                  openingAmount:
                      (e['opening_amount'] as num?)?.toDouble() ?? 0.0,
                ),
              )
              .toList() ??
          [],
    );
  }
}

class ClosePOSSessionRequest {
  final String posOpeningEntry;

  ClosePOSSessionRequest({required this.posOpeningEntry});

  Map<String, dynamic> toJson() {
    return {'pos_opening_entry': posOpeningEntry};
  }

  factory ClosePOSSessionRequest.fromJson(Map<String, dynamic> json) {
    return ClosePOSSessionRequest(posOpeningEntry: json['pos_opening_entry']);
  }
}

class ClosePOSSessionResponse {
  final bool success;
  final String message;
  final ClosePOSSessionData? data;

  ClosePOSSessionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ClosePOSSessionResponse.fromJson(Map<String, dynamic> json) {
    return ClosePOSSessionResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? ClosePOSSessionData.fromJson(json['data'])
          : null,
    );
  }
}

class ClosePOSSessionData {
  final String name;
  final String status;
  final int docstatus;

  ClosePOSSessionData({
    required this.name,
    required this.status,
    required this.docstatus,
  });

  factory ClosePOSSessionData.fromJson(Map<String, dynamic> json) {
    return ClosePOSSessionData(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      docstatus: json['docstatus'] ?? 0,
    );
  }
}
