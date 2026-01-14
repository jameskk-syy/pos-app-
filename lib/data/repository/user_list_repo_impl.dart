import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/users_repo.dart';
import 'package:pos/domain/requests/assign_staff_to_store.dart';
import 'package:pos/domain/requests/create_staff.dart';
import 'package:pos/domain/requests/update_staff_roles.dart';
import 'package:pos/domain/requests/update_staff_user_request.dart';
import 'package:pos/domain/responses/assign_roles_response.dart';
import 'package:pos/domain/responses/assign_staff_to_store_response.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/role_response.dart';
import 'package:pos/domain/responses/update_staff_user_response.dart';
import 'package:pos/domain/responses/users_list.dart';

class UserListRepoImpl implements UserListRepo {
  final RemoteDataSource remoteDataSource;

  UserListRepoImpl({required this.remoteDataSource});
  @override
  Future<StaffUsersResponse> getAllUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    return await remoteDataSource.getUserList(limit: limit, offset: offset);
  }

  @override
  Future<CurrentUserResponse> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<RolesResponse> getRoleResponse() async {
    return await remoteDataSource.getRolesList();
  }

  @override
  Future<StaffUsersResponse> createStaff(StaffUserRequest staff) async {
    return await remoteDataSource.createStaffUser(staff);
  }

  @override
  Future<AssignWarehousesResponse> assignStaff(
    AssignWarehousesRequest assignWarehousesRequest,
  ) async {
    return await remoteDataSource.assignStaffToWarehouse(
      assignWarehousesRequest,
    );
  }

  @override
  Future<UpdateStaffUserResponse> updateStaffUser(
    UpdateStaffUserRequest request,
  ) async {
    return await remoteDataSource.updateStaffUser(request);
  }

  @override
  Future<AssignRolesResponse> assignRolesToStaff(
    AssignRolesRequest request,
  ) async {
    return await remoteDataSource.assignRolesToStaff(request);
  }
}
