import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
import 'package:pos/data/datasource/base_remote_datasource.dart';
import 'package:pos/domain/responses/sales/store_response.dart';

class StoreRemoteDataSource extends BaseRemoteDataSource {
  StoreRemoteDataSource(super.dio);

  Future<StoreGetResponse> getStoresList(String company) async {
    try {
      final response = await dio.get(
        'techsavanna_pos.api.warehouse_api.list_warehouses',
        queryParameters: {'company': company},
      );

      // debugPrint("all  warehouses ${response.data}");
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return StoreGetResponse.fromJson(data);
    } on DioException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      rethrow;
    }
  }
}
