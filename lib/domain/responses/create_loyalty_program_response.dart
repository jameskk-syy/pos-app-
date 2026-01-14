class CreateLoyaltyProgramResponse {
  final LoyaltyProgramMessage message;

  CreateLoyaltyProgramResponse({required this.message});

  factory CreateLoyaltyProgramResponse.fromJson(Map<String, dynamic> json) {
    return CreateLoyaltyProgramResponse(
      message: LoyaltyProgramMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class LoyaltyProgramMessage {
  final String status;
  final String message;
  final LoyaltyProgram loyaltyProgram;

  LoyaltyProgramMessage({
    required this.status,
    required this.message,
    required this.loyaltyProgram,
  });

  factory LoyaltyProgramMessage.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramMessage(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      loyaltyProgram: LoyaltyProgram.fromJson(json['loyalty_program']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'loyalty_program': loyaltyProgram.toJson(),
    };
  }
}

class LoyaltyProgram {
  final String name;
  final String owner;
  final String creation;
  final String modified;
  final String modifiedBy;
  final int docstatus;
  final int idx;
  final String loyaltyProgramName;
  final String loyaltyProgramType;
  final String fromDate;
  final String toDate;
  final String? customerGroup;
  final String? customerTerritory;
  final int autoOptIn;
  final double conversionFactor;
  final int expiryDuration;
  final String? expenseAccount;
  final String company;
  final String? costCenter;
  final String doctype;
  final List<CollectionRule> collectionRules;

  LoyaltyProgram({
    required this.name,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
    required this.docstatus,
    required this.idx,
    required this.loyaltyProgramName,
    required this.loyaltyProgramType,
    required this.fromDate,
    required this.toDate,
    this.customerGroup,
    this.customerTerritory,
    required this.autoOptIn,
    required this.conversionFactor,
    required this.expiryDuration,
    this.expenseAccount,
    required this.company,
    this.costCenter,
    required this.doctype,
    required this.collectionRules,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      name: json['name'] ?? '',
      owner: json['owner'] ?? '',
      creation: json['creation'] ?? '',
      modified: json['modified'] ?? '',
      modifiedBy: json['modified_by'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      idx: json['idx'] ?? 0,
      loyaltyProgramName: json['loyalty_program_name'] ?? '',
      loyaltyProgramType: json['loyalty_program_type'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      customerGroup: json['customer_group'],
      customerTerritory: json['customer_territory'],
      autoOptIn: json['auto_opt_in'] ?? 0,
      conversionFactor: (json['conversion_factor'] ?? 0.0).toDouble(),
      expiryDuration: json['expiry_duration'] ?? 0,
      expenseAccount: json['expense_account'],
      company: json['company'] ?? '',
      costCenter: json['cost_center'],
      doctype: json['doctype'] ?? '',
      collectionRules: (json['collection_rules'] as List?)
              ?.map((rule) => CollectionRule.fromJson(rule))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner': owner,
      'creation': creation,
      'modified': modified,
      'modified_by': modifiedBy,
      'docstatus': docstatus,
      'idx': idx,
      'loyalty_program_name': loyaltyProgramName,
      'loyalty_program_type': loyaltyProgramType,
      'from_date': fromDate,
      'to_date': toDate,
      'customer_group': customerGroup,
      'customer_territory': customerTerritory,
      'auto_opt_in': autoOptIn,
      'conversion_factor': conversionFactor,
      'expiry_duration': expiryDuration,
      'expense_account': expenseAccount,
      'company': company,
      'cost_center': costCenter,
      'doctype': doctype,
      'collection_rules': collectionRules.map((rule) => rule.toJson()).toList(),
    };
  }
}

class CollectionRule {
  final String name;
  final String owner;
  final String creation;
  final String modified;
  final String modifiedBy;
  final int docstatus;
  final int idx;
  final String tierName;
  final double minSpent;
  final double collectionFactor;
  final String parent;
  final String parentfield;
  final String parenttype;
  final String doctype;
  final int? unsaved;

  CollectionRule({
    required this.name,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
    required this.docstatus,
    required this.idx,
    required this.tierName,
    required this.minSpent,
    required this.collectionFactor,
    required this.parent,
    required this.parentfield,
    required this.parenttype,
    required this.doctype,
    this.unsaved,
  });

  factory CollectionRule.fromJson(Map<String, dynamic> json) {
    return CollectionRule(
      name: json['name'] ?? '',
      owner: json['owner'] ?? '',
      creation: json['creation'] ?? '',
      modified: json['modified'] ?? '',
      modifiedBy: json['modified_by'] ?? '',
      docstatus: json['docstatus'] ?? 0,
      idx: json['idx'] ?? 0,
      tierName: json['tier_name'] ?? '',
      minSpent: (json['min_spent'] ?? 0.0).toDouble(),
      collectionFactor: (json['collection_factor'] ?? 0.0).toDouble(),
      parent: json['parent'] ?? '',
      parentfield: json['parentfield'] ?? '',
      parenttype: json['parenttype'] ?? '',
      doctype: json['doctype'] ?? '',
      unsaved: json['__unsaved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner': owner,
      'creation': creation,
      'modified': modified,
      'modified_by': modifiedBy,
      'docstatus': docstatus,
      'idx': idx,
      'tier_name': tierName,
      'min_spent': minSpent,
      'collection_factor': collectionFactor,
      'parent': parent,
      'parentfield': parentfield,
      'parenttype': parenttype,
      'doctype': doctype,
      if (unsaved != null) '__unsaved': unsaved,
    };
  }
}