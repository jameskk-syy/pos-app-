import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/users_repo.dart';
import 'package:pos/domain/requests/users/assign_staff_to_store.dart';
import 'package:pos/domain/requests/users/create_staff.dart';
import 'package:pos/domain/requests/users/update_staff_roles.dart';
import 'package:pos/domain/requests/users/update_staff_user_request.dart';
import 'package:pos/domain/responses/users/assign_roles_response.dart';
import 'package:pos/domain/responses/users/role_response.dart';
import 'package:pos/domain/responses/users/update_staff_user_response.dart';
import 'package:pos/domain/responses/users/users_list.dart';
import 'package:pos/domain/responses/users/get_warehouse_staff_response.dart';

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
    on<GetWarehouseStaff>(_getWarehouseStaff);
    on<RemoveStaffFromWarehouse>(_removeStaffFromWarehouse);
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
      emit(
        StaffAssignedSuccessful(
          userEmail: event.assignWarehousesRequest.userEmail,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      emit(StaffStateFailure(error: e.toString()));
    }
  }

  Future<void> _getWarehouseStaff(
    GetWarehouseStaff event,
    Emitter<StaffState> emit,
  ) async {
    debugPrint(
      'StaffBloc: Fetching warehouse staff for ${event.warehouseName}',
    );
    emit(StaffStateLoading());
    try {
      final response = await userListRepo.getWarehouseStaff(
        event.warehouseName,
      );
      debugPrint(
        'StaffBloc: Successfully loaded ${response.message.data.length} staff members',
      );
      emit(WarehouseStaffLoaded(response: response));
    } catch (e) {
      debugPrint('StaffBloc ERROR in _getWarehouseStaff: $e');
      emit(StaffStateFailure(error: e.toString()));
    }
  }

  Future<void> _removeStaffFromWarehouse(
    RemoveStaffFromWarehouse event,
    Emitter<StaffState> emit,
  ) async {
    // emit(StaffStateLoading()); // Optional: loading state if you want to show a spinner during removal
    try {
      final response = await userListRepo.removeStaffFromWarehouse(
        event.email,
        event.warehouseName,
      );
      if (response.message.success) {
        emit(StaffRemovalSuccess(message: response.message.message));
        // Refresh the list after successful removal
        add(GetWarehouseStaff(warehouseName: event.warehouseName));
      } else {
        emit(StaffStateFailure(error: "Failed to remove staff"));
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(StaffStateFailure(error: e.toString()));
    }
  }
}
