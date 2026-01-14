class PriceListResponse {
  final List<PriceList> priceLists;
  final Pagination pagination;
  final int count;

  PriceListResponse({
    required this.priceLists,
    required this.pagination,
    required this.count,
  });

  factory PriceListResponse.fromJson(Map<String, dynamic> json) {
    return PriceListResponse(
      priceLists: (json['price_lists'] as List)
          .map((item) => PriceList.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
      count: json['count'] as int,
    );
  }
}

class PriceList {
  final String name;
  final String priceListName;
  final String currency;
  final int selling;
  final int buying;
  final int enabled;

  PriceList({
    required this.name,
    required this.priceListName,
    required this.currency,
    required this.selling,
    required this.buying,
    required this.enabled,
  });

  factory PriceList.fromJson(Map<String, dynamic> json) {
    return PriceList(
      name: json['name'] as String,
      priceListName: json['price_list_name'] as String,
      currency: json['currency'] as String,
      selling: json['selling'] as int,
      buying: json['buying'] as int,
      enabled: json['enabled'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price_list_name': priceListName,
      'currency': currency,
      'selling': selling,
      'buying': buying,
      'enabled': enabled,
    };
  }

  bool get isSelling => selling == 1;
  bool get isBuying => buying == 1;
  bool get isEnabled => enabled == 1;
}

class Pagination {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
    );
  }
}
