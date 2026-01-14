import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/store_repo.dart';
import 'package:pos/domain/requests/create_warehouse.dart';
import 'package:pos/domain/requests/update_warehouse.dart';
import 'package:pos/domain/responses/create_warehouse.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/domain/responses/update_warehouse_response.dart';

class StoreRepoImpl implements StoreRepo {
  final RemoteDataSource remoteDataSource;

  StoreRepoImpl({required this.remoteDataSource});
  @override
  Future<StoreGetResponse> getAllStores(
    String company, {
    int limit = 20,
    int offset = 0,
  }) async {
    return await remoteDataSource.getAllStores(
      company,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<CreateWarehouseResponse> createWarehouse(
    CreateWarehouseRequest createWarehouseRequest,
  ) async {
    return await remoteDataSource.createWarehouse(createWarehouseRequest);
  }

  @override
  Future<UpdateWarehouseResponse> updateWarehouse(
    UpdateWarehouseRequest updateWarehouseRequest,
  ) async {
    return await remoteDataSource.updateWarehouse(updateWarehouseRequest);
  }
}
