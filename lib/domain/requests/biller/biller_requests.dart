class SetActiveBillerRequest {
  final String billerName;

  SetActiveBillerRequest({required this.billerName});

  Map<String, dynamic> toJson() => {'biller_name': billerName};
}

class GetBillerDetailsRequest {
  final String billerName;

  GetBillerDetailsRequest({required this.billerName});

  Map<String, dynamic> toQueryParams() => {'biller_name': billerName};
}

class ListBillersRequest {
  final String searchTerm;
  final int limit;
  final int offset;

  ListBillersRequest({
    this.searchTerm = '',
    this.limit = 50,
    this.offset = 0,
  });

  Map<String, dynamic> toQueryParams() => {
        'search_term': searchTerm,
        'limit': limit,
        'offset': offset,
      };
}

class CreateBillerRequest {
  final String billerName;
  final String industry;
  final String company;
  final String? defaultCostCenter;
  final String? defaultPriceList;
  final String? defaultTaxTemplate;
  final bool isDefault;

  CreateBillerRequest({
    required this.billerName,
    required this.industry,
    required this.company,
    this.defaultCostCenter,
    this.defaultPriceList,
    this.defaultTaxTemplate,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'biller_name': billerName,
        'industry': industry,
        'company': company,
        if (defaultCostCenter != null) 'default_cost_center': defaultCostCenter,
        if (defaultPriceList != null) 'default_price_list': defaultPriceList,
        if (defaultTaxTemplate != null)
          'default_tax_template': defaultTaxTemplate,
        'is_default': isDefault ? 1 : 0,
      };
}
