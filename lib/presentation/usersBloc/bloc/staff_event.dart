part of 'staff_bloc.dart';

@immutable
sealed class StaffEvent {}

class GetUserListEvent extends StaffEvent {
  final int limit;
  final int offset;

  GetUserListEvent({this.limit = 20, this.offset = 0});
}

class GetUserRoles extends StaffEvent {}

class CreateStaff extends StaffEvent {
  final StaffUserRequest staffCreateRequest;

  CreateStaff({required this.staffCreateRequest});
}

class AssignStaffToStore extends StaffEvent {
  final AssignWarehousesRequest assignWarehousesRequest;

  AssignStaffToStore({required this.assignWarehousesRequest});
}

class UpdateStaffUser extends StaffEvent {
  final UpdateStaffUserRequest updateRequest;

  UpdateStaffUser({required this.updateRequest});
}

class AssignRolesToStaff extends StaffEvent {
  final AssignRolesRequest assignRolesRequest;

  AssignRolesToStaff({required this.assignRolesRequest});
}
