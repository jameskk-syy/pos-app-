class UpdateSupplierRequest {
  final String name;
  final String company;
  final String supplierName;
  final String supplierType;
  final String supplierGroup;
  final String? taxId;
  final String? country;
  final String? defaultCurrency;
  final bool isInternalSupplier;

  UpdateSupplierRequest({
    required this.name,
    required this.company,
    required this.supplierName,
    required this.supplierType,
    required this.supplierGroup,
    this.taxId,
    this.country,
    this.defaultCurrency,
    this.isInternalSupplier = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'supplier_name': supplierName,
      'supplier_type': supplierType,
      'supplier_group': supplierGroup,
      if (taxId != null && taxId!.isNotEmpty) 'tax_id': taxId,
      if (country != null && country!.isNotEmpty) 'country': country,
      if (defaultCurrency != null && defaultCurrency!.isNotEmpty)
        'default_currency': defaultCurrency,
      'is_internal_supplier': isInternalSupplier,
    };
  }
}
