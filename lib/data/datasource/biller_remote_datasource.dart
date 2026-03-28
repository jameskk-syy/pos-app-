import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/responses/biller/biller_responses.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';

class BillerRemoteDatasource extends BaseRemoteDataSource {
  BillerRemoteDatasource(super.dio);
  Future<UserContextResponse> getUserContext() async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.biller_api.get_user_context',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint(" your biller data is : ${data.toString()}");
        }
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message == null) {
        throw Exception('Missing message in response');
      }

      return UserContextResponse.fromJson(message);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(e.response?.data?.toString());
      }
      throw Exception(getErrorMessage(e));
    } catch (e) {
      if (kDebugMode) {
        debugPrint(" your biller data is : ${e.toString()}");
      }
      rethrow;
    }
  }

  Future<SetActiveBillerResponse> setActiveBiller(
      SetActiveBillerRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.biller_api.set_active_biller',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message == null) {
        throw Exception('Missing message in response');
      }

      return SetActiveBillerResponse.fromJson(message);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(e.response?.data?.toString());
      }
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<BillerDetailsResponse> getBillerDetails(
      GetBillerDetailsRequest request) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.biller_api.get_biller_details',
        queryParameters: request.toQueryParams(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message == null) {
        throw Exception('Missing message in response');
      }

      return BillerDetailsResponse.fromJson(message);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(e.response?.data?.toString());
      }
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<ListBillersResponse> listBillers(ListBillersRequest request) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.biller_api.list_billers',
        queryParameters: request.toQueryParams(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if(kDebugMode){
        debugPrint(" your list billers data is : ${data.toString()}");
      }
      if (data is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint(" your list billers data is : ${data.toString()}");
        }
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message == null) {
        throw Exception('Missing message in response');
      }

      if (kDebugMode) {
        debugPrint('RAW BILLER LIST: ${message.toString()}');
      }

      final responseModel = ListBillersResponse.fromJson(message);
      if (!responseModel.success) {
        throw Exception(message['message']?.toString() ?? 'Failed to fetch billers');
      }

      return responseModel;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(e.response?.data?.toString());
      }
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<CreateBillerResponse> createBiller(CreateBillerRequest request) async {
    try {
      final response = await dio.post(
        'techsavanna_pos.api.biller_api.create_biller',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if(kDebugMode){
        debugPrint(" your create biller data is : ${data.toString()}");
      }
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      final message = data['message'];
      if (message == null) {
        throw Exception('Missing message in response');
      }

      final responseModel = CreateBillerResponse.fromJson(message);
      if (!responseModel.success) {
        throw Exception(message['message']?.toString() ?? 'Failed to create branch');
      }

      return responseModel;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(e.response?.data?.toString());
      }
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }
}
