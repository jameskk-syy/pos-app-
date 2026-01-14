// lib/domain/requests/get_material_requests_request.dart

class GetMaterialRequestsRequest {
  final String? status;
  final String? originWarehouse;
  final String? destinationWarehouse;
  final String? fromDate;
  final String? toDate;
  final String company;
  final int? page;
  final int? pageSize;

  GetMaterialRequestsRequest({
    this.status,
    this.originWarehouse,
    this.destinationWarehouse,
    this.fromDate,
    this.toDate,
    required this.company,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'company': company,
    };

    if (status != null && status!.isNotEmpty) {
      json['status'] = status;
    }
    if (originWarehouse != null && originWarehouse!.isNotEmpty) {
      json['origin_warehouse'] = originWarehouse;
    }
    if (destinationWarehouse != null && destinationWarehouse!.isNotEmpty) {
      json['destination_warehouse'] = destinationWarehouse;
    }
    if (fromDate != null && fromDate!.isNotEmpty) {
      json['from_date'] = fromDate;
    }
    if (toDate != null && toDate!.isNotEmpty) {
      json['to_date'] = toDate;
    }
    if (page != null) {
      json['page'] = page;
    }
    if (pageSize != null) {
      json['page_size'] = pageSize;
    }

    return json;
  }

  GetMaterialRequestsRequest copyWith({
    String? status,
    String? originWarehouse,
    String? destinationWarehouse,
    String? fromDate,
    String? toDate,
    String? company,
    int? page,
    int? pageSize,
  }) {
    return GetMaterialRequestsRequest(
      status: status ?? this.status,
      originWarehouse: originWarehouse ?? this.originWarehouse,
      destinationWarehouse: destinationWarehouse ?? this.destinationWarehouse,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      company: company ?? this.company,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}