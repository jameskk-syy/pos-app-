import 'dart:convert';

AssignLoyaltyProgramResponse assignLoyaltyProgramResponseFromJson(String str) =>
    AssignLoyaltyProgramResponse.fromJson(json.decode(str));

String assignLoyaltyProgramResponseToJson(AssignLoyaltyProgramResponse data) =>
    json.encode(data.toJson());

class AssignLoyaltyProgramResponse {
  final AssignLoyaltyProgramMessage message;

  AssignLoyaltyProgramResponse({required this.message});

  factory AssignLoyaltyProgramResponse.fromJson(Map<String, dynamic> json) =>
      AssignLoyaltyProgramResponse(
        message: AssignLoyaltyProgramMessage.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {"message": message.toJson()};
}

class AssignLoyaltyProgramMessage {
  final String status;
  final String message;
  final Customer customer;

  AssignLoyaltyProgramMessage({
    required this.status,
    required this.message,
    required this.customer,
  });

  factory AssignLoyaltyProgramMessage.fromJson(Map<String, dynamic> json) =>
      AssignLoyaltyProgramMessage(
        status: json["status"],
        message: json["message"],
        customer: Customer.fromJson(json["customer"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "customer": customer.toJson(),
  };
}

class Customer {
  final String name;
  final String owner;
  final String creation;
  final String modified;
  final String modifiedBy;
  final int docstatus;
  final int idx;
  final String namingSeries;
  final dynamic salutation;
  final String customerName;
  final String customerType;
  final String customerGroup;
  final String territory;
  final dynamic gender;
  final dynamic leadName;
  final dynamic opportunityName;
  final dynamic prospectName;
  final dynamic accountManager;
  final dynamic image;
  final String defaultCurrency;
  final dynamic defaultBankAccount;
  final dynamic defaultPriceList;
  final int isInternalCustomer;
  final dynamic representsCompany;
  final dynamic marketSegment;
  final dynamic industry;
  final dynamic customerPosId;
  final dynamic website;
  final String language;
  final dynamic customerDetails;
  final dynamic customerPrimaryAddress;
  final dynamic primaryAddress;
  final String customerPrimaryContact;
  final String mobileNo;
  final String emailId;
  final int requireTaxId;
  final String taxId;
  final dynamic taxCategory;
  final dynamic taxWithholdingCategory;
  final int customDetailsSubmittedSuccessfully;
  final dynamic sladeId;
  final int customPreventEtimsRegistration;
  final dynamic paymentTerms;
  final String loyaltyProgram;
  final dynamic loyaltyProgramTier;
  final dynamic defaultSalesPartner;
  final double defaultCommissionRate;
  final int soRequired;
  final int dnRequired;
  final int isFrozen;
  final int disabled;
  final String doctype;
  final List<dynamic> creditLimits;
  final List<dynamic> salesTeam;
  final List<dynamic> etimsSetupMapping;
  final List<dynamic> companies;
  final List<dynamic> portalUsers;
  final List<dynamic> accounts;

  Customer({
    required this.name,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
    required this.docstatus,
    required this.idx,
    required this.namingSeries,
    required this.salutation,
    required this.customerName,
    required this.customerType,
    required this.customerGroup,
    required this.territory,
    required this.gender,
    required this.leadName,
    required this.opportunityName,
    required this.prospectName,
    required this.accountManager,
    required this.image,
    required this.defaultCurrency,
    required this.defaultBankAccount,
    required this.defaultPriceList,
    required this.isInternalCustomer,
    required this.representsCompany,
    required this.marketSegment,
    required this.industry,
    required this.customerPosId,
    required this.website,
    required this.language,
    required this.customerDetails,
    required this.customerPrimaryAddress,
    required this.primaryAddress,
    required this.customerPrimaryContact,
    required this.mobileNo,
    required this.emailId,
    required this.requireTaxId,
    required this.taxId,
    required this.taxCategory,
    required this.taxWithholdingCategory,
    required this.customDetailsSubmittedSuccessfully,
    required this.sladeId,
    required this.customPreventEtimsRegistration,
    required this.paymentTerms,
    required this.loyaltyProgram,
    required this.loyaltyProgramTier,
    required this.defaultSalesPartner,
    required this.defaultCommissionRate,
    required this.soRequired,
    required this.dnRequired,
    required this.isFrozen,
    required this.disabled,
    required this.doctype,
    required this.creditLimits,
    required this.salesTeam,
    required this.etimsSetupMapping,
    required this.companies,
    required this.portalUsers,
    required this.accounts,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    name: json["name"],
    owner: json["owner"],
    creation: json["creation"],
    modified: json["modified"],
    modifiedBy: json["modified_by"],
    docstatus: json["docstatus"] ?? 0,
    idx: json["idx"] ?? 0,
    namingSeries: json["naming_series"],
    salutation: json["salutation"],
    customerName: json["customer_name"],
    customerType: json["customer_type"],
    customerGroup: json["customer_group"],
    territory: json["territory"],
    gender: json["gender"],
    leadName: json["lead_name"],
    opportunityName: json["opportunity_name"],
    prospectName: json["prospect_name"],
    accountManager: json["account_manager"],
    image: json["image"],
    defaultCurrency: json["default_currency"],
    defaultBankAccount: json["default_bank_account"],
    defaultPriceList: json["default_price_list"],
    isInternalCustomer: json["is_internal_customer"] ?? 0,
    representsCompany: json["represents_company"],
    marketSegment: json["market_segment"],
    industry: json["industry"],
    customerPosId: json["customer_pos_id"],
    website: json["website"],
    language: json["language"],
    customerDetails: json["customer_details"],
    customerPrimaryAddress: json["customer_primary_address"],
    primaryAddress: json["primary_address"],
    customerPrimaryContact: json["customer_primary_contact"] ?? "",
    mobileNo: json["mobile_no"],
    emailId: json["email_id"],
    requireTaxId: json["require_tax_id"] ?? 0,
    taxId: json["tax_id"],
    taxCategory: json["tax_category"],
    taxWithholdingCategory: json["tax_withholding_category"],
    customDetailsSubmittedSuccessfully:
        json["custom_details_submitted_successfully"] ?? 0,
    sladeId: json["slade_id"],
    customPreventEtimsRegistration:
        json["custom_prevent_etims_registration"] ?? 0,
    paymentTerms: json["payment_terms"],
    loyaltyProgram: json["loyalty_program"],
    loyaltyProgramTier: json["loyalty_program_tier"],
    defaultSalesPartner: json["default_sales_partner"],
    defaultCommissionRate: (json["default_commission_rate"] ?? 0.0).toDouble(),
    soRequired: json["so_required"] ?? 0,
    dnRequired: json["dn_required"] ?? 0,
    isFrozen: json["is_frozen"] ?? 0,
    disabled: json["disabled"] ?? 0,
    doctype: json["doctype"],
    creditLimits: json["credit_limits"] ?? [],
    salesTeam: json["sales_team"] ?? [],
    etimsSetupMapping: json["etims_setup_mapping"] ?? [],
    companies: json["companies"] ?? [],
    portalUsers: json["portal_users"] ?? [],
    accounts: json["accounts"] ?? [],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner,
    "creation": creation,
    "modified": modified,
    "modified_by": modifiedBy,
    "docstatus": docstatus,
    "idx": idx,
    "naming_series": namingSeries,
    "salutation": salutation,
    "customer_name": customerName,
    "customer_type": customerType,
    "customer_group": customerGroup,
    "territory": territory,
    "gender": gender,
    "lead_name": leadName,
    "opportunity_name": opportunityName,
    "prospect_name": prospectName,
    "account_manager": accountManager,
    "image": image,
    "default_currency": defaultCurrency,
    "default_bank_account": defaultBankAccount,
    "default_price_list": defaultPriceList,
    "is_internal_customer": isInternalCustomer,
    "represents_company": representsCompany,
    "market_segment": marketSegment,
    "industry": industry,
    "customer_pos_id": customerPosId,
    "website": website,
    "language": language,
    "customer_details": customerDetails,
    "customer_primary_address": customerPrimaryAddress,
    "primary_address": primaryAddress,
    "customer_primary_contact": customerPrimaryContact,
    "mobile_no": mobileNo,
    "email_id": emailId,
    "require_tax_id": requireTaxId,
    "tax_id": taxId,
    "tax_category": taxCategory,
    "tax_withholding_category": taxWithholdingCategory,
    "custom_details_submitted_successfully": customDetailsSubmittedSuccessfully,
    "slade_id": sladeId,
    "custom_prevent_etims_registration": customPreventEtimsRegistration,
    "payment_terms": paymentTerms,
    "loyalty_program": loyaltyProgram,
    "loyalty_program_tier": loyaltyProgramTier,
    "default_sales_partner": defaultSalesPartner,
    "default_commission_rate": defaultCommissionRate,
    "so_required": soRequired,
    "dn_required": dnRequired,
    "is_frozen": isFrozen,
    "disabled": disabled,
    "doctype": doctype,
    "credit_limits": creditLimits,
    "sales_team": salesTeam,
    "etims_setup_mapping": etimsSetupMapping,
    "companies": companies,
    "portal_users": portalUsers,
    "accounts": accounts,
  };
}
