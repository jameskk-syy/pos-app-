import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/suppliers_repo.dart';
import 'package:pos/domain/requests/create_supplier_group_request.dart';
import 'package:pos/domain/requests/create_supplier_request.dart';
import 'package:pos/domain/requests/update_supplier_request.dart';
import 'package:pos/domain/responses/create_supplier_group_response.dart';
import 'package:pos/domain/responses/create_supplier_response.dart';
import 'package:pos/domain/responses/supplier_group_response.dart';
import 'package:pos/domain/responses/suppliers_response.dart';

class SuppliersRepoImpl implements SuppliersRepo {
  final RemoteDataSource remoteDataSource;

  SuppliersRepoImpl({required this.remoteDataSource});

  @override
  Future<SupplierGroupResponse> getSupplierGroups() async {
    try {
      final response = await remoteDataSource.getSupplierGroups();
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
      final response = await remoteDataSource.createSupplier(request);
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
      final response = await remoteDataSource.updateSupplier(request);
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
      final response = await remoteDataSource.getSuppliers(
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
      final response = await remoteDataSource.createSupplierGroup(request);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
