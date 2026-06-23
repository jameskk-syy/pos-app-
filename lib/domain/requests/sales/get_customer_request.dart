class CustomerRequest {
  String searchTerm;
  String customerGroup;
  String territory;
  String customerType;
  bool disabled;
  bool filterByCompanyTransactions;
  String company;
  int limit;
  int offset;

  CustomerRequest({
    this.searchTerm = '',
    this.customerGroup = '',
    this.territory = '',
    this.customerType = '',
    this.disabled = false,
    this.filterByCompanyTransactions = false,
    this.company = 'CVF',
    this.limit = 20,
    this.offset = 0,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'search_term': searchTerm,
      'company': company,
      'limit': limit,
      'offset': offset,
    };

    if (customerGroup.isNotEmpty) map['customer_group'] = customerGroup;
    if (territory.isNotEmpty) map['territory'] = territory;
    if (customerType.isNotEmpty) map['customer_type'] = customerType;
    if (disabled) map['disabled'] = disabled;
    if (filterByCompanyTransactions) map['filter_by_company_transactions'] = filterByCompanyTransactions;

    return map;
  }

  factory CustomerRequest.fromJson(Map<String, dynamic> json) {
    return CustomerRequest(
      searchTerm: json['search_term'] ?? '',
      customerGroup: json['customer_group'] ?? '',
      territory: json['territory'] ?? '',
      customerType: json['customer_type'] ?? '',
      disabled: json['disabled'] ?? false,
      filterByCompanyTransactions:
          json['filter_by_company_transactions'] ?? false,
      company: json['company'] ?? 'CVF',
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
    );
  }
}
