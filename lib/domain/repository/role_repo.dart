import 'package:pos/domain/requests/create_role_request.dart';
import 'package:pos/domain/responses/create_role_response.dart';
import 'package:pos/domain/responses/roles.dart';
import 'package:pos/domain/requests/role_permissions_request.dart';
import 'package:pos/domain/responses/role_permissions_response.dart';
import 'package:pos/domain/requests/assign_permissions_request.dart';
import 'package:pos/domain/responses/assign_permissions_response.dart';
import 'package:pos/domain/responses/get_role_details_response.dart';
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
