// lib/domain/requests/create_supplier_group_request.dart
class CreateSupplierGroupRequest {
  final String supplierGroupName;
  final bool isGroup;
  final String? paymentTerms;

  CreateSupplierGroupRequest({
    required this.supplierGroupName,
    this.isGroup = false,
    this.paymentTerms,
  });

  Map<String, dynamic> toJson() => {
    'supplier_group_name': supplierGroupName,
    'is_group': isGroup,
    if (paymentTerms != null && paymentTerms != 'None (Root Group)') 
      'payment_terms': paymentTerms,
  };
}