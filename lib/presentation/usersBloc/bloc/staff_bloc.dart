import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/users_repo.dart';
import 'package:pos/domain/requests/assign_staff_to_store.dart';
import 'package:pos/domain/requests/create_staff.dart';
import 'package:pos/domain/requests/update_staff_roles.dart';
import 'package:pos/domain/requests/update_staff_user_request.dart';
import 'package:pos/domain/responses/assign_roles_response.dart';
import 'package:pos/domain/responses/role_response.dart';
import 'package:pos/domain/responses/update_staff_user_response.dart';
import 'package:pos/domain/responses/users_list.dart';

part 'staff_event.dart';
part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final UserListRepo userListRepo;
  StaffBloc({required this.userListRepo}) : super(StaffInitial()) {
    on<StaffEvent>((event, emit) {});
    on<GetUserListEvent>(_getUserList);
    on<GetUserRoles>(_getUserRole);
    on<CreateStaff>(_createStaff);
    on<AssignStaffToStore>(_assignStaffToStore);
    on<UpdateStaffUser>(_updateStaffUser);
    on<AssignRolesToStaff>(_assignRolesToStaff);
  }
  Future<void> _assignRolesToStaff(
    AssignRolesToStaff event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffStateLoading());
    try {
      final response = await userListRepo.assignRolesToStaff(
        event.assignRolesRequest,
      );
      emit(StaffRolesAssignSuccess(response: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(StaffStateFailure(error: e.toString()));
    }
  }

  Future<void> _updateStaffUser(
    UpdateStaffUser event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffStateLoading());
    debugPrint(event.updateRequest.toJson().toString());
    try {
      final response = await userListRepo.updateStaffUser(event.updateRequest);
      emit(StaffUpdateSuccess(response: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(StaffStateFailure(error: e.toString()));
    }
  }

  Future<void> _getUserList(
    GetUserListEvent event,
    Emitter<StaffState> emit,
  ) async {
    try {
      final response = await userListRepo.getAllUsers(
        limit: event.limit,
        offset: event.offset,
      );
      emit(StaffStateSuccess(staffUser: response));
    } catch (e) {
      debugPrint(e.toString());
      emit(StaffStateFailure(error: e.toString()));
    }
  }

  Future<void> _getUserRole(
    GetUserRoles event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffStateLoading());
    try {
      final response = await userListRepo.getRoleResponse();
      emit(StaffRoleList(response: response));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _createStaff(CreateStaff event, Emitter<StaffState> emit) async {
    emit(StaffStateLoading());
    try {
      await userListRepo.createStaff(event.staffCreateRequest);
      emit(StaffCreateUser());
    } catch (e) {
      emit(StaffStateFailure(error: e.toString()));
    }
  }

  FutureOr<void> _assignStaffToStore(
    AssignStaffToStore event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffStateLoading());
    try {
      await userListRepo.assignStaff(event.assignWarehousesRequest);
      emit(StaffAssignedSuccessful());
    } catch (e) {
      debugPrint(e.toString());
      emit(StaffStateFailure(error: e.toString()));
    }
  }
}
