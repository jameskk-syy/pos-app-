part of 'role_bloc.dart';

@immutable
sealed class RoleEvent {}

class GetAllRoles extends RoleEvent {
  final int page;
  final int size;
  final String? searchTerm;

  GetAllRoles({this.page = 1, this.size = 20, this.searchTerm});
}

class CreateRole extends RoleEvent {
  final CreateRoleRequest createRoleRequest;

  CreateRole({required this.createRoleRequest});
}

class UpdateRole extends RoleEvent {
  final CreateRoleRequest updateRoleRequest;

  UpdateRole({required this.updateRoleRequest});
}

class GetRolePermissions extends RoleEvent {
  final RolePermissionsRequest request;

  GetRolePermissions({required this.request});
}

class FetchModules extends RoleEvent {}

class FetchDoctypes extends RoleEvent {
  final String module;
  FetchDoctypes({required this.module});
}

class AssignRolePermissions extends RoleEvent {
  final AssignPermissionsRequest request;
  AssignRolePermissions({required this.request});
}

class GetRoleDetails extends RoleEvent {
  final String roleName;
  GetRoleDetails({required this.roleName});
}

class DisableRole extends RoleEvent {
  final String roleName;
  DisableRole({required this.roleName});
}

class EnableRole extends RoleEvent {
  final String roleName;
  EnableRole({required this.roleName});
}
