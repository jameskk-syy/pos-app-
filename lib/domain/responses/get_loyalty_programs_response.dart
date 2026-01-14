class GetLoyaltyProgramsResponse {
  final LoyaltyProgramsMessage message;

  GetLoyaltyProgramsResponse({required this.message});

  factory GetLoyaltyProgramsResponse.fromJson(Map<String, dynamic> json) {
    return GetLoyaltyProgramsResponse(
      message: LoyaltyProgramsMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class LoyaltyProgramsMessage {
  final String status;
  final String message;
  final List<LoyaltyProgramItem> programs;
  final int totalPrograms;
  final List<String>? debug;

  LoyaltyProgramsMessage({
    required this.status,
    required this.message,
    required this.programs,
    required this.totalPrograms,
    this.debug,
  });

  factory LoyaltyProgramsMessage.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramsMessage(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      programs: (json['programs'] as List?)
              ?.map((program) => LoyaltyProgramItem.fromJson(program))
              .toList() ??
          [],
      totalPrograms: json['total_programs'] ?? 0,
      debug: json['debug'] != null
          ? List<String>.from(json['debug'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'programs': programs.map((program) => program.toJson()).toList(),
      'total_programs': totalPrograms,
      if (debug != null) 'debug': debug,
    };
  }
}

class LoyaltyProgramItem {
  final String name;
  final String loyaltyProgramName;
  final String loyaltyProgramType;
  final String fromDate;
  final String toDate;

  LoyaltyProgramItem({
    required this.name,
    required this.loyaltyProgramName,
    required this.loyaltyProgramType,
    required this.fromDate,
    required this.toDate,
  });

  factory LoyaltyProgramItem.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramItem(
      name: json['name'] ?? '',
      loyaltyProgramName: json['loyalty_program_name'] ?? '',
      loyaltyProgramType: json['loyalty_program_type'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'loyalty_program_name': loyaltyProgramName,
      'loyalty_program_type': loyaltyProgramType,
      'from_date': fromDate,
      'to_date': toDate,
    };
  }
}