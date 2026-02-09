import 'package:pos/data/datasource/purchase_remote_datasource.dart';
import 'package:pos/domain/repository/suppliers_repo.dart';
import 'package:pos/domain/requests/suppliers/create_supplier_group_request.dart';
import 'package:pos/domain/requests/suppliers/create_supplier_request.dart';
import 'package:pos/domain/requests/suppliers/update_supplier_request.dart';
import 'package:pos/domain/responses/suppliers/create_supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers/create_supplier_response.dart';
import 'package:pos/domain/responses/suppliers/supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers/suppliers_response.dart';

class SuppliersRepoImpl implements SuppliersRepo {
  final PurchaseRemoteDataSource purchaseRemoteDataSource;

  SuppliersRepoImpl({required this.purchaseRemoteDataSource});

  @override
  Future<SupplierGroupResponse> getSupplierGroups() async {
    try {
      final response = await purchaseRemoteDataSource.getSupplierGroups();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreateSupplierResponse> createSupplier(
    CreateSupplierRequest request,
  ) async {
    try {
      final response = await purchaseRemoteDataSource.createSupplier(request);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreateSupplierResponse> updateSupplier(
    UpdateSupplierRequest request,
  ) async {
    try {
      final response = await purchaseRemoteDataSource.updateSupplier(request);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SuppliersResponse> getSuppliers({
    String? searchTerm,
    String? supplierGroup,
    required String company,
    required int limit,
    required int offset,
    String? supplierType,
    String? country,
    bool? disabled,
  }) async {
    try {
      final response = await purchaseRemoteDataSource.getSuppliers(
        searchTerm: searchTerm,
        supplierGroup: supplierGroup,
        company: company,
        limit: limit,
        offset: offset,
        supplierType: supplierType,
        country: country,
        disabled: disabled,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreateSupplierGroupResponse> createSupplierGroup(
    CreateSupplierGroupRequest request,
  ) async {
    try {
      final response = await purchaseRemoteDataSource.createSupplierGroup(
        request,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
