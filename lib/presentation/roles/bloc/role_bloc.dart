import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/repository/role_repo.dart';
import 'package:pos/domain/requests/create_role_request.dart';
import 'package:pos/domain/responses/roles.dart';
import 'package:pos/domain/requests/role_permissions_request.dart';
import 'package:pos/domain/responses/role_permissions_response.dart';
import 'package:pos/domain/responses/system_responses.dart';
import 'package:pos/domain/requests/assign_permissions_request.dart';
import 'package:pos/domain/responses/assign_permissions_response.dart';

part 'role_event.dart';
part 'role_state.dart';

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final RoleRepo roleRepo;
  RoleBloc({required this.roleRepo}) : super(RoleInitial()) {
    on<GetAllRoles>(_getAllRoles);
    on<CreateRole>(_createRole);
    on<UpdateRole>(_updateRole);
    on<GetRolePermissions>(_getRolePermissions);
    on<FetchModules>(_onFetchModules);
    on<FetchDoctypes>(_onFetchDoctypes);
    on<AssignRolePermissions>(_onAssignRolePermissions);
    on<GetRoleDetails>(_onGetRoleDetails);
    on<DisableRole>(_onDisableRole);
    on<EnableRole>(_onEnableRole);
  }

  FutureOr<void> _getAllRoles(
    GetAllRoles event,
    Emitter<RoleState> emit,
  ) async {
    if (event.page == 1) {
      emit(RoleStateLoading());
    }
    try {
      final response = await roleRepo.getAllRoles(
        page: event.page,
        size: event.size,
        searchTerm: event.searchTerm,
      );
      emit(RoleStateSuccess(roleResponse: response));
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint(e.toString());
    }
  }

  Future<void> _createRole(CreateRole event, Emitter<RoleState> emit) async {
    debugPrint("calling ${event.createRoleRequest.toJson()}");
    emit(RoleStateLoading());
    try {
      await roleRepo.createRoles(event.createRoleRequest);
      emit(RoleStateCreateRoleSuccess());
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("hcdhacdh ${e.toString()}");
    }
  }

  Future<void> _updateRole(UpdateRole event, Emitter<RoleState> emit) async {
    debugPrint("RoleBloc: handling UpdateRole event");
    debugPrint("updating ${event.updateRoleRequest.toJson()}");
    emit(RoleStateLoading());
    try {
      debugPrint("RoleBloc: calling roleRepo.updateRole");
      await roleRepo.updateRole(event.updateRoleRequest);
      debugPrint("RoleBloc: updateRole success");
      emit(RoleStateUpdateRoleSuccess());
    } catch (e) {
      debugPrint("RoleBloc: updateRole error: $e");
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("Update error: ${e.toString()}");
    }
  }

  Future<void> _getRolePermissions(
    GetRolePermissions event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleStateLoading());
    try {
      final response = await roleRepo.getRolePermissions(event.request);
      emit(RolePermissionsLoaded(response: response));
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("GetRolePermissions error: ${e.toString()}");
    }
  }

  Future<void> _onFetchModules(
    FetchModules event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleStateLoading());
    try {
      final response = await roleRepo.getModules();
      emit(ModulesLoaded(response: response));
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("FetchModules error: ${e.toString()}");
    }
  }

  Future<void> _onFetchDoctypes(
    FetchDoctypes event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleStateLoading());
    try {
      final response = await roleRepo.getDoctypes(event.module);
      emit(DoctypesLoaded(response: response));
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("FetchDoctypes error: ${e.toString()}");
    }
  }

  Future<void> _onAssignRolePermissions(
    AssignRolePermissions event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleStateLoading());
    try {
      final response = await roleRepo.assignPermissions(event.request);
      if (response.success) {
        emit(RolePermissionsAssigned(response: response));
      } else {
        emit(RoleStateFailure(error: response.message));
      }
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("AssignRolePermissions error: ${e.toString()}");
    }
  }

  Future<void> _onGetRoleDetails(
    GetRoleDetails event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleStateLoading());
    try {
      final response = await roleRepo.getRoleDetails(event.roleName);
      if (response.success && response.data != null) {
        emit(RoleDetailsLoaded(role: response.data!));
      } else {
        emit(RoleStateFailure(error: "Failed to fetch role details"));
      }
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("GetRoleDetails error: ${e.toString()}");
    }
  }

  Future<void> _onDisableRole(
    DisableRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(RoleStateLoading());
    try {
      final response = await roleRepo.disableRole(event.roleName);
      if (response.message.success) {
        emit(RoleActionSuccess(message: response.message.message));
        // Refresh roles logic could be triggered here or in UI
      } else {
        emit(RoleStateFailure(error: response.message.message));
      }
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("DisableRole error: ${e.toString()}");
    }
  }

  Future<void> _onEnableRole(EnableRole event, Emitter<RoleState> emit) async {
    emit(RoleStateLoading());
    try {
      final response = await roleRepo.enableRole(event.roleName);
      if (response.message.success) {
        emit(RoleActionSuccess(message: response.message.message));
      } else {
        emit(RoleStateFailure(error: response.message.message));
      }
    } catch (e) {
      emit(RoleStateFailure(error: e.toString()));
      debugPrint("EnableRole error: ${e.toString()}");
    }
  }
}
