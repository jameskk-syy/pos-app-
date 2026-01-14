// suppliers_response.dart
class SuppliersResponse {
  final bool success;
  final SuppliersData data;

  SuppliersResponse({required this.success, required this.data});

  factory SuppliersResponse.fromJson(Map<String, dynamic> json) {
    return SuppliersResponse(
      success: json['success'] ?? false,
      data: SuppliersData.fromJson(json),
    );
  }
}

class SuppliersData {
  final List<Supplier> suppliers;
  final int count;

  SuppliersData({required this.suppliers, required this.count});

  factory SuppliersData.fromJson(Map<String, dynamic> json) {
    // The data is directly a list in the response
    final dataList = json['data'] as List?;

    return SuppliersData(
      suppliers: (dataList ?? [])
          .map((item) => Supplier.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] ?? 0,
    );
  }
}

class Supplier {
  final String name;
  final String supplierName;
  final String supplierType;
  final String? supplierGroup;
  final String? taxId;
  final int disabled;
  final int isInternalSupplier;
  final String country;
  final String? defaultCurrency;

  Supplier({
    required this.name,
    required this.supplierName,
    required this.supplierType,
    this.supplierGroup,
    this.taxId,
    required this.disabled,
    required this.isInternalSupplier,
    required this.country,
    this.defaultCurrency,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      name: json['name'] ?? '',
      supplierName: json['supplier_name'] ?? '',
      supplierType: json['supplier_type'] ?? '',
      supplierGroup: json['supplier_group'],
      taxId: json['tax_id'],
      disabled: json['disabled'] ?? 0,
      isInternalSupplier: json['is_internal_supplier'] ?? 0,
      country: json['country'] ?? '',
      defaultCurrency: json['default_currency'],
    );
  }
}
