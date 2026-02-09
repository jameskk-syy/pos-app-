import 'package:pos/domain/requests/users/assign_staff_to_store.dart';
import 'package:pos/domain/requests/users/create_staff.dart';
import 'package:pos/domain/requests/users/update_staff_roles.dart';
import 'package:pos/domain/requests/users/update_staff_user_request.dart';
import 'package:pos/domain/responses/users/assign_roles_response.dart';
import 'package:pos/domain/responses/users/assign_staff_to_store_response.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/users/remove_staff_response.dart';
import 'package:pos/domain/responses/users/role_response.dart';
import 'package:pos/domain/responses/users/update_staff_user_response.dart';
import 'package:pos/domain/responses/users/users_list.dart';
import 'package:pos/domain/responses/users/get_warehouse_staff_response.dart';

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
  Future<GetWarehouseStaffResponse> getWarehouseStaff(String warehouseName);
  Future<RemoveStaffResponse> removeStaffFromWarehouse(
    String email,
    String warehouseName,
  );
}
