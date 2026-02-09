import 'package:pos/data/datasource/auth_remote_datasource.dart';
import 'package:pos/domain/repository/users_repo.dart';
import 'package:pos/domain/requests/users/assign_staff_to_store.dart';
import 'package:pos/domain/requests/users/create_staff.dart';
import 'package:pos/domain/requests/users/update_staff_roles.dart';
import 'package:pos/domain/requests/users/update_staff_user_request.dart';
import 'package:pos/domain/responses/users/assign_roles_response.dart';
import 'package:pos/domain/responses/users/assign_staff_to_store_response.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/users/role_response.dart';
import 'package:pos/domain/responses/users/update_staff_user_response.dart';
import 'package:pos/domain/responses/users/users_list.dart';
import 'package:pos/domain/responses/users/get_warehouse_staff_response.dart'
    as ws;
import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';
import 'package:pos/domain/responses/users/remove_staff_response.dart' as rs;

class UserListRepoImpl implements UserListRepo {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final LocalDataSource localDataSource;

  UserListRepoImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.localDataSource,
  });

  @override
  Future<StaffUsersResponse> getAllUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      try {
        final response = await remoteDataSource.getUserList(
          limit: limit,
          offset: offset,
        );
        // Cache the users
        // We catch the 'staffUsers' list
        final usersData = response.message.staffUsers
            .map((u) => u.toJson())
            .toList();
        await localDataSource.cacheStaff(usersData);
        return response;
      } catch (e) {
        // Fallback to cache on error? For now rethrow to let BLoC handle it
        rethrow;
      }
    } else {
      // Offline mode
      final cachedUsers = localDataSource.getCachedStaff();
      if (cachedUsers.isNotEmpty) {
        final usersList = cachedUsers
            .map((json) => StaffUser.fromJson(json))
            .toList();

        return StaffUsersResponse(
          message: StaffUsersMessage(
            staffUsers: usersList,
            count: usersList.length,
            company: '', // Optional: Store company separately if needed
          ),
        );
      } else {
        throw Exception("No internet connection and no cached data available.");
      }
    }
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

  @override
  Future<ws.GetWarehouseStaffResponse> getWarehouseStaff(
    String warehouseName,
  ) async {
    return await remoteDataSource.getWarehouseStaff(warehouseName);
  }

  @override
  Future<rs.RemoveStaffResponse> removeStaffFromWarehouse(
    String email,
    String warehouseName,
  ) async {
    return await remoteDataSource.removeStaffFromWarehouse(
      email,
      warehouseName,
    );
  }
}
