part of 'staff_bloc.dart';

@immutable
sealed class StaffState {}

final class StaffInitial extends StaffState {}

final class StaffStateLoading extends StaffState {}
final  class StaffCreateUser  extends StaffState{}
final class StaffAssignedSuccessful  extends StaffState{}
final class StaffStateSuccess extends StaffState {
  final StaffUsersResponse staffUser;

  StaffStateSuccess({required this.staffUser});
}

final class StaffRoleList extends StaffState {
  final RolesResponse response;

  StaffRoleList({required this.response});
  
}

final class StaffStateFailure extends StaffState {
  final String error;

  StaffStateFailure({required this.error});
}
final class StaffUpdateSuccess extends StaffState {
  final UpdateStaffUserResponse response;

  StaffUpdateSuccess({required this.response});
}
final class StaffRolesAssignSuccess extends StaffState {
  final AssignRolesResponse response;

  StaffRolesAssignSuccess({required this.response});
}
