part of 'role_bloc.dart';

@immutable
sealed class RoleState {}

final class RoleInitial extends RoleState {}

final class RoleStateLoading extends RoleState {}

final class RoleStateCreateRoleSuccess extends RoleState {}

final class RoleStateUpdateRoleSuccess extends RoleState {}

final class RoleStateSuccess extends RoleState {
  final RoleResponse roleResponse;

  RoleStateSuccess({required this.roleResponse});
}

final class RoleStateFailure extends RoleState {
  final String error;

  RoleStateFailure({required this.error});
}

final class RolePermissionsLoaded extends RoleState {
  final RolePermissionsResponse response;

  RolePermissionsLoaded({required this.response});
}

final class ModulesLoaded extends RoleState {
  final ModuleResponse response;
  ModulesLoaded({required this.response});
}

final class DoctypesLoaded extends RoleState {
  final DoctypeResponse response;
  DoctypesLoaded({required this.response});
}

final class RolePermissionsAssigned extends RoleState {
  final AssignPermissionsResponse response;
  RolePermissionsAssigned({required this.response});
}

final class RoleDetailsLoaded extends RoleState {
  final RoleData role;
  RoleDetailsLoaded({required this.role});
}

final class RoleActionSuccess extends RoleState {
  final String message;
  RoleActionSuccess({required this.message});
}
