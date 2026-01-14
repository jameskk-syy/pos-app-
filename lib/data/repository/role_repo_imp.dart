import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/role_repo.dart';
import 'package:pos/domain/requests/create_role_request.dart';
import 'package:pos/domain/responses/create_role_response.dart';
import 'package:pos/domain/responses/roles.dart';
import 'package:pos/domain/requests/role_permissions_request.dart';
import 'package:pos/domain/responses/role_permissions_response.dart';
import 'package:pos/domain/responses/system_responses.dart';
import 'package:pos/domain/requests/assign_permissions_request.dart';
import 'package:pos/domain/responses/assign_permissions_response.dart';
import 'package:pos/domain/responses/get_role_details_response.dart';

class RoleRepoImpl implements RoleRepo {
  final RemoteDataSource remoteDataSource;

  RoleRepoImpl({required this.remoteDataSource});
  @override
  Future<RoleResponse> getAllRoles({
    int page = 1,
    int size = 20,
    String? searchTerm,
  }) async {
    return await remoteDataSource.getAllRole(
      page: page,
      size: size,
      search: searchTerm,
    );
  }

  @override
  Future<CreateRoleResponse> createRoles(CreateRoleRequest request) async {
    return await remoteDataSource.createRole(request);
  }

  @override
  Future<CreateRoleResponse> updateRole(CreateRoleRequest request) async {
    return await remoteDataSource.updateRole(request);
  }

  @override
  Future<RolePermissionsResponse> getRolePermissions(
    RolePermissionsRequest request,
  ) async {
    return await remoteDataSource.getRolePermissions(request);
  }

  @override
  Future<ModuleResponse> getModules() async {
    return await remoteDataSource.getModules();
  }

  @override
  Future<DoctypeResponse> getDoctypes(String module) async {
    return await remoteDataSource.getDoctypes(module);
  }

  @override
  Future<AssignPermissionsResponse> assignPermissions(
    AssignPermissionsRequest request,
  ) async {
    return await remoteDataSource.assignPermissions(request);
  }

  @override
  Future<GetRoleDetailsResponse> getRoleDetails(String roleName) async {
    return await remoteDataSource.getRoleDetails(roleName);
  }

  @override
  Future<CreateRoleResponse> disableRole(String roleName) async {
    return await remoteDataSource.disableRole(roleName);
  }

  @override
  Future<CreateRoleResponse> enableRole(String roleName) async {
    return await remoteDataSource.enableRole(roleName);
  }
}
