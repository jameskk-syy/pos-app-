import 'package:pos/domain/requests/create_supplier_group_request.dart';
import 'package:pos/domain/requests/create_supplier_request.dart';
import 'package:pos/domain/requests/update_supplier_request.dart';
import 'package:pos/domain/responses/create_supplier_group_response.dart';
import 'package:pos/domain/responses/create_supplier_response.dart';
import 'package:pos/domain/responses/supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers_response.dart';

abstract class SuppliersRepo {
  Future<SupplierGroupResponse> getSupplierGroups();
  Future<CreateSupplierResponse> createSupplier(CreateSupplierRequest request);
  Future<CreateSupplierResponse> updateSupplier(UpdateSupplierRequest request);
  Future<SuppliersResponse> getSuppliers({
    String? searchTerm,
    String? supplierGroup,
    required String company,
    required int limit,
    required int offset,
    String? supplierType,
    String? country,
    bool? disabled,
  });
  Future<CreateSupplierGroupResponse> createSupplierGroup(
    CreateSupplierGroupRequest request,
  );
}
