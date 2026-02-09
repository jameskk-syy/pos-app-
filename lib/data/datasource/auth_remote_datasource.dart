import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pos/domain/responses/system_responses.dart';
import 'package:flutter/material.dart';
import 'package:pos/domain/models/message.dart';
import 'package:pos/domain/requests/users/assign_staff_to_store.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/requests/sales/create_pos_request.dart';
import 'package:pos/domain/requests/users/create_provisioning_account.dart';
import 'package:pos/domain/requests/users/create_role_request.dart';
import 'package:pos/domain/requests/users/role_permissions_request.dart';
import 'package:pos/domain/requests/users/assign_permissions_request.dart';
import 'package:pos/domain/requests/users/create_staff.dart';
import 'package:pos/domain/requests/users/login.dart';
import 'package:pos/domain/requests/users/register_company.dart';
import 'package:pos/domain/requests/users/register_user.dart';
import 'package:pos/domain/requests/users/update_staff_roles.dart';
import 'package:pos/domain/requests/users/update_staff_user_request.dart';
import 'package:pos/domain/responses/users/assign_staff_to_store_response.dart';
import 'package:pos/domain/responses/users/assign_roles_response.dart';
import 'package:pos/domain/responses/users/create_provisioning_account.dart';
import 'package:pos/domain/responses/users/create_role_response.dart';
import 'package:pos/domain/responses/users/login_response.dart';
import 'package:pos/domain/responses/sales/pos_create_response.dart';
import 'package:pos/domain/responses/users/register_company_response.dart';
import 'package:pos/domain/responses/users/role_permissions_response.dart';
import 'package:pos/domain/responses/users/assign_permissions_response.dart';
import 'package:pos/domain/responses/users/get_role_details_response.dart';
import 'package:pos/domain/responses/users/role_response.dart';
import 'package:pos/domain/responses/users/roles.dart';
import 'package:pos/domain/responses/users/update_staff_user_response.dart';
import 'package:pos/domain/responses/users/users_list.dart';
import 'package:pos/domain/responses/users/get_warehouse_staff_response.dart'
    as ws;
import 'package:pos/domain/responses/users/remove_staff_response.dart' as rs;
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/requests/inventory/create_warehouse.dart';

import 'package:pos/data/datasource/inventory_datasource.dart';

class AuthRemoteDataSource extends BaseRemoteDataSource {
  final InventoryRemoteDataSource inventoryRemoteDataSource;
  final StorageService storageService;

  AuthRemoteDataSource(
    super.dio, {
    required this.inventoryRemoteDataSource,
    required this.storageService,
  });

  Future<Message> registerUser(RegisterRequest registerRequest) async {
    try {
      debugPrint('REGISTER PAYLOAD => ${registerRequest.toJson()}');

      debugPrint('REGISTER PAYLOAD => ${registerRequest.toJson()}');

      final response = await dio.post(
        'techsavanna_pos.api.auth_api.register_user',
        data: registerRequest.toJson(),
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      final data = response.data;
      debugPrint('--- REGISTER RESPONSE START ---');
      debugPrint(const JsonEncoder.withIndent('  ').convert(data));
      debugPrint('--- REGISTER RESPONSE END ---');

      if (data == null) {
        throw Exception('Server returned empty response');
      }
      final message = data['message'];
      if (message == null ||
          message is! Map<String, dynamic> ||
          message.containsKey('error')) {
        String error = 'Registration failed';
        if (message != null &&
            message is Map<String, dynamic> &&
            message['error'] != null) {
          error = message['error'].toString();
        } else if (data['_server_messages'] != null) {
          error = _extractMessageFromServerMessages(data['_server_messages']);
        }
        throw Exception(error);
      }

      // Save full message (user + metadata)
      String userDataJson = jsonEncode(message);
      await storageService.setString('userData', userDataJson);

      // Save access and refresh tokens
      final accessToken = message['access_token'];
      final refreshToken = message['refresh_token'];

      if (accessToken != null) {
        await storageService.setString('access_token', accessToken.toString());
        debugPrint('ACCESS TOKEN SAVED: $accessToken');
      }
      if (refreshToken != null) {
        await storageService.setString(
          'refresh_token',
          refreshToken.toString(),
        );
      }

      return Message.fromJson(message);
    } on DioException catch (e) {
      debugPrint('DIO ERROR in registerUser: ${getErrorMessage(e)}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint('GENERAL ERROR in registerUser => $e');
      throw Exception(e.toString());
    }
  }

  String _extractMessageFromServerMessages(dynamic serverMessages) {
    try {
      if (serverMessages is String) {
        serverMessages = jsonDecode(serverMessages);
      }
      if (serverMessages is List && serverMessages.isNotEmpty) {
        final firstMsg = serverMessages[0];
        Map<String, dynamic>? msgMap;
        if (firstMsg is String) {
          msgMap = jsonDecode(firstMsg);
        } else if (firstMsg is Map<String, dynamic>) {
          msgMap = firstMsg;
        }
        if (msgMap != null && msgMap.containsKey('message')) {
          return msgMap['message'].toString().replaceAll(
            RegExp(r'<[^>]*>'),
            '',
          );
        }
      }
    } catch (_) {}
    return 'Registration failed. Please check your details.';
  }

  Future<LoginResponse> login(LoginRequest request) async {
    debugPrint("DEBUG: Login attempt for ${request.email}");
    final requestBody = {
      'identifier': request.email,
      'password': request.password,
    };
    try {
      debugPrint("DEBUG: Posting to loginuser endpoint...");
      final response = await dio.post(
        'techsavanna_pos.api.auth_api.loginuser',
        data: requestBody,
      );

      final data = response.data;
      debugPrint("DEBUG: Login status code: ${response.data}");

      if (data == null || data['message'] == null) {
        debugPrint("DEBUG: Login failed - Invalid response structure");
        throw Exception('Invalid response from server');
      }

      final messageMap = data['message'];
      if (messageMap is! Map<String, dynamic>) {
        debugPrint("DEBUG: Login failed - message is not a Map");
        throw Exception('Unexpected response structure: message is not a Map');
      }

      if (messageMap['success'] == false) {
        throw Exception(messageMap['message'] ?? 'Authentication failed');
      }

      final loginResponse = LoginResponse.fromJson({'message': messageMap});

      await storageService.setString(
        'userData',
        jsonEncode(loginResponse.message.user.toJson()),
      );
      await storageService.setString(
        'access_token',
        loginResponse.message.accessToken,
      );

      debugPrint("DEBUG: Login successful, calling getCurrentUser...");
      await getCurrentUser();
      debugPrint(
        'DEBUG: USER DATA SAVED: ${loginResponse.message.user.toJson()}',
      );
      debugPrint(
        'DEBUG: ACCESS TOKEN SAVED: ${loginResponse.message.accessToken}',
      );

      return loginResponse;
    } on DioException catch (e) {
      debugPrint("DEBUG: DioException during login: ${e.message}");
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint("DEBUG: General error during login: $e");
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.auth_api.change_password',
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint("Change Password Error: ${e.message}");
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CurrentUserResponse> getCurrentUser() async {
    debugPrint("DEBUG: calling getCurrentUser...");

    try {
      final response = await dio.get(
        'techsavanna_pos.api.auth_api.get_current_user',
      );

      final data = response.data;
      debugPrint("DEBUG: getCurrentUser response: $data");

      if (data == null || data['message'] == null) {
        debugPrint("DEBUG: getCurrentUser failed - Invalid response");
        throw Exception('Invalid response from server');
      }

      final currentUser = CurrentUserResponse.fromJson(data);

      debugPrint(
        "DEBUG: current user parsed successfully: ${currentUser.message.user.fullName}",
      );

      await storageService.setString(
        'current_user',
        jsonEncode(currentUser.toJson()),
      );

      return currentUser;
    } on DioException catch (e) {
      debugPrint("DEBUG: DioException during getCurrentUser: ${e.message}");
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint("DEBUG: General error during getCurrentUser: $e");
      throw Exception(e.toString());
    }
  }

  Future<CreateRoleResponse> createRole(CreateRoleRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());
      final response = await dio.post(
        'techsavanna_pos.api.role_api.create_role',
        data: formData,
      );
      if (response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      return CreateRoleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateRoleResponse> updateRole(CreateRoleRequest request) async {
    try {
      final formData = FormData.fromMap(request.toJson());
      final response = await dio.post(
        'techsavanna_pos.api.role_api.update_role',
        data: formData,
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      return CreateRoleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<RolePermissionsResponse> getRolePermissions(
    RolePermissionsRequest request,
  ) async {
    try {
      final formData = FormData.fromMap(request.toJson());
      final response = await dio.post(
        'techsavanna_pos.api.role_api.get_role_permissions',
        data: formData,
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      return RolePermissionsResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<RoleResponse> getAllRole({
    int page = 1,
    int size = 20,
    String? search,
  }) async {
    debugPrint('Fetching role with page: $page, size: $size, search: $search');

    try {
      final Map<String, dynamic> queryParams = {"page": page, "size": size};
      if (search != null && search.isNotEmpty) {
        queryParams["search"] = search;
      }
      final response = await dio.get(
        'techsavanna_pos.api.role_api.list_roles',
        queryParameters: queryParams,
      );
      debugPrint(response.toString());

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return RoleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to fetch role: $e');
    }
  }

  Future<AssignPermissionsResponse> assignPermissions(
    AssignPermissionsRequest request,
  ) async {
    try {
      final formData = FormData.fromMap(request.toJson());
      final response = await dio.post(
        'techsavanna_pos.api.role_api.assign_permissions_to_role',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return AssignPermissionsResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to assign permissions: $e');
    }
  }

  Future<GetRoleDetailsResponse> getRoleDetails(String roleName) async {
    debugPrint('Fetching details for role: $roleName');
    try {
      final formData = FormData.fromMap({'role_name': roleName});
      final response = await dio.post(
        'techsavanna_pos.api.role_api.get_role_details',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return GetRoleDetailsResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to fetch role details: $e');
    }
  }

  Future<CreateRoleResponse> disableRole(String roleName) async {
    debugPrint('Disabling role: $roleName');
    try {
      final formData = FormData.fromMap({'role_name': roleName});
      final response = await dio.post(
        'techsavanna_pos.api.role_api.disable_role',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateRoleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to disable role: $e');
    }
  }

  Future<CreateRoleResponse> enableRole(String roleName) async {
    debugPrint('Enabling role: $roleName');
    try {
      final formData = FormData.fromMap({'role_name': roleName});
      final response = await dio.post(
        'techsavanna_pos.api.role_api.enable_role',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return CreateRoleResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to enable role: $e');
    }
  }

  Future<StaffUsersResponse> createStaffUser(
    StaffUserRequest createStaffRequest,
  ) async {
    debugPrint('Creating staff user: ${createStaffRequest.email}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.staff_api.create_staff_user',
        data: createStaffRequest.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return StaffUsersResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  Future<StaffUsersResponse> getUserList({
    int limit = 20,
    int offset = 0,
  }) async {
    debugPrint("getting staff users with limit: $limit, offset: $offset");
    try {
      final queryParams = {'enabled_only': false};
      final response = await dio.get(
        'techsavanna_pos.api.staff_api.get_staff_users',
        queryParameters: queryParams,
      );

      final data = response.data;

      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      return StaffUsersResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AssignRolesResponse> assignRolesToStaff(
    AssignRolesRequest request,
  ) async {
    debugPrint("Assign Roles Response: ${request.toJson().toString()}");
    try {
      final response = await dio.post(
        'techsavanna_pos.api.staff_api.assign_roles_to_staff',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      if (!data.containsKey('message')) {
        throw Exception('Response missing required field: message');
      }

      await getCurrentUser();
      return AssignRolesResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<UpdateStaffUserResponse> updateStaffUser(
    UpdateStaffUserRequest request,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.staff_api.update_staff_user',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }

      return UpdateStaffUserResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<RolesResponse> getRolesList() async {
    debugPrint("Getting roles list");
    try {
      final response = await dio.get(
        'techsavanna_pos.api.staff_api.get_all_roles',
      );

      final data = response.data;

      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      return RolesResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint("Error: $e");
      throw Exception(e.toString());
    }
  }

  Future<Message?> getUserData() async {
    String? userDataJson = await storageService.getString('userData');

    if (userDataJson != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      return Message.fromJson(userDataMap);
    }
    return null;
  }

  Future<Message?> getCompanyData() async {
    String? userDataJson = await storageService.getString('companyData');

    if (userDataJson != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
      return Message.fromJson(userDataMap);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await storageService.remove('userData');
    debugPrint('USER DATA CLEARED');
  }

  Future<CompanyProfileResponse> createPosProfile(
    CompanyProfileRequest request,
  ) async {
    debugPrint("Creating POS Profile...");
    try {
      final response = await dio.post(
        'techsavanna_pos.api.onboarding_api.create_pos_profile',
        data: request,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      await getCurrentUser();
      return CompanyProfileResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignWarehousesResponse> assignStaffToWarehouse(
    AssignWarehousesRequest request,
  ) async {
    debugPrint("Assign Staff Request: ${request.toJson()}");
    try {
      final response = await dio.post(
        'techsavanna_pos.api.warehouse_api.assign_warehouses_to_staff',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Response is not a valid JSON object');
      }
      return AssignWarehousesResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<ws.GetWarehouseStaffResponse> getWarehouseStaff(
    String warehouseName,
  ) async {
    try {
      debugPrint('Fetching staff for warehouse: $warehouseName');
      final response = await dio.post(
        'techsavanna_pos.api.warehouse_api.get_warehouse_staff',
        data: {'warehouse': warehouseName},
      );

      debugPrint('GetWarehouseStaff Response: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Invalid response from server');
      }

      return ws.GetWarehouseStaffResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('DIO ERROR in getWarehouseStaff: ${getErrorMessage(e)}');
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint('ERROR in getWarehouseStaff: $e');
      throw Exception(e.toString());
    }
  }

  Future<rs.RemoveStaffResponse> removeStaffFromWarehouse(
    String userEmail,
    String warehouseName,
  ) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.warehouse_api.remove_warehouse_from_staff',
        data: {'user_email': userEmail, 'warehouse': warehouseName},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('Invalid response from server');
      }

      return rs.RemoveStaffResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ProvisionalAccountResponse> createAccountProvisioning(
    ProvisionalAccountRequest provisioningAccounts,
  ) async {
    debugPrint('Creating accounts: ${provisioningAccounts.company}');

    try {
      final response = await dio.post(
        'techsavanna_pos.api.account_provisioning_api.auto_configure_provisional_account',
        data: provisioningAccounts.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        throw Exception(data['error'] ?? 'Unknown error');
      }

      return ProvisionalAccountResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to provision account: $e');
    }
  }

  Future<CompanyResponse> registerCompany(CompanyRequest companyRequest) async {
    debugPrint('--- user_remote_datasource: registerCompany START ---');
    try {
      debugPrint('REGISTER PAYLOAD => ${companyRequest.toJson()}');

      final response = await dio.post(
        'techsavanna_pos.api.onboarding_api.create_company',
        data: companyRequest.toJson(),
      );

      final data = response.data;

      if (data == null || data['message'] == null) {
        throw Exception('Invalid response from server');
      }

      debugPrint('--- user_remote_datasource: registerCompany START ---');
      await storageService.setString('companyData', jsonEncode(data));
      final request = ProvisionalAccountRequest(
        company: companyRequest.companyName,
        createAccountIfMissing: true,
      );
      await createAccountProvisioning(request);

      // Create default warehouse for the company
      await _createDefaultWarehouse(companyRequest);
      await getCurrentUser();
      return CompanyResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      debugPrint('GENERAL ERROR => $e');
      throw Exception(e.toString());
    }
  }

  Future<void> _createDefaultWarehouse(CompanyRequest companyRequest) async {
    try {
      debugPrint(
        'Creating default warehouse for company: ${companyRequest.companyName}',
      );

      final warehouseRequest = CreateWarehouseRequest(
        warehouseName: '${companyRequest.companyName} - Main Warehouse',
        company: companyRequest.companyName,
        warehouseType: 'Transit',
        isMainDepot: true,
        setAsDefault: true,
        addressLine1: companyRequest.companyAddress.addressLine1,
        addressLine2: companyRequest.companyAddress.addressLine2,
        city: companyRequest.companyAddress.city,
        state: companyRequest.companyAddress.state,
        pin: companyRequest.companyAddress.pincode,
        phoneNo: companyRequest.companyAddress.phone,
        emailId: companyRequest.companyAddress.emailId,
      );

      final response = await inventoryRemoteDataSource.createWarehouse(
        warehouseRequest,
      );
      debugPrint(
        'Default warehouse created successfully: ${response.toJson()}',
      );

      /*
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Default warehouse created successfully');
      } else {
        debugPrint(
          'Warehouse creation returned status: ${response.statusCode}',
        );
      }
      */
    } catch (e) {
      debugPrint('Warning: Failed to create default warehouse: $e');
      debugPrint(
        'Company registration will continue despite warehouse creation failure',
      );
    }
  }

  Future<ModuleResponse> getModules() async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.system_api.list_modules',
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
      return ModuleResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<DoctypeResponse> getDoctypes(String module) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.module_api.get_doctypes',
        queryParameters: {'module': module},
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
      return DoctypeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }
}
