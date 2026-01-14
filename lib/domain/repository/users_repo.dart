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

abstract class UserListRepo {
  Future<StaffUsersResponse> getAllUsers({int limit = 20, int offset = 0});
  Future<CurrentUserResponse> getCurrentUser();
  Future<RolesResponse> getRoleResponse();
  Future<StaffUsersResponse> createStaff(StaffUserRequest staff);

  Future<AssignWarehousesResponse> assignStaff(
    AssignWarehousesRequest assignWarehousesRequest,
  );
  Future<UpdateStaffUserResponse> updateStaffUser(
    UpdateStaffUserRequest request,
  );
  Future<AssignRolesResponse> assignRolesToStaff(AssignRolesRequest request);
}
