import 'package:pos/data/datasource/auth_remote_datasource.dart';
import 'package:pos/domain/repository/role_repo.dart';
import 'package:pos/domain/requests/users/create_role_request.dart';
import 'package:pos/domain/responses/users/create_role_response.dart';
import 'package:pos/domain/responses/users/roles.dart';
import 'package:pos/domain/requests/users/role_permissions_request.dart';
import 'package:pos/domain/responses/users/role_permissions_response.dart';
import 'package:pos/domain/responses/system_responses.dart';
import 'package:pos/domain/requests/users/assign_permissions_request.dart';
import 'package:pos/domain/responses/users/assign_permissions_response.dart';
import 'package:pos/domain/responses/users/get_role_details_response.dart';

class RoleRepoImpl implements RoleRepo {
  final AuthRemoteDataSource remoteDataSource;

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
