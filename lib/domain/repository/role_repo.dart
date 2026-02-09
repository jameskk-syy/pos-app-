import 'package:pos/domain/requests/users/create_role_request.dart';
import 'package:pos/domain/responses/users/create_role_response.dart';
import 'package:pos/domain/responses/users/roles.dart';
import 'package:pos/domain/requests/users/role_permissions_request.dart';
import 'package:pos/domain/responses/users/role_permissions_response.dart';
import 'package:pos/domain/requests/users/assign_permissions_request.dart';
import 'package:pos/domain/responses/users/assign_permissions_response.dart';
import 'package:pos/domain/responses/users/get_role_details_response.dart';
import 'package:pos/domain/responses/system_responses.dart';

abstract class RoleRepo {
  Future<RoleResponse> getAllRoles({
    int page = 1,
    int size = 20,
    String? searchTerm,
  });
  Future<CreateRoleResponse> createRoles(CreateRoleRequest request);
  Future<CreateRoleResponse> updateRole(CreateRoleRequest request);
  Future<RolePermissionsResponse> getRolePermissions(
    RolePermissionsRequest request,
  );
  Future<ModuleResponse> getModules();
  Future<DoctypeResponse> getDoctypes(String module);
  Future<AssignPermissionsResponse> assignPermissions(
    AssignPermissionsRequest request,
  );
  Future<GetRoleDetailsResponse> getRoleDetails(String roleName);
  Future<CreateRoleResponse> disableRole(String roleName);
  Future<CreateRoleResponse> enableRole(String roleName);
}
