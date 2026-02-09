import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';
import 'package:pos/data/datasource/store_remote_datasource.dart';
import 'package:pos/data/datasource/inventory_datasource.dart';
import 'package:pos/domain/repository/store_repo.dart';
import 'package:pos/domain/requests/inventory/create_warehouse.dart';
import 'package:pos/domain/requests/inventory/update_warehouse.dart';
import 'package:pos/domain/responses/inventory/create_warehouse.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/inventory/update_warehouse_response.dart';

class StoreRepoImpl implements StoreRepo {
  final StoreRemoteDataSource remoteDataSource;
  final InventoryRemoteDataSource inventoryRemoteDataSource;

  final ConnectivityService connectivityService;
  final LocalDataSource localDataSource;

  StoreRepoImpl({
    required this.remoteDataSource,
    required this.inventoryRemoteDataSource,
    required this.connectivityService,
    required this.localDataSource,
  });
  @override
  Future<StoreGetResponse> getAllStores(
    String company, {
    int limit = 20,
    int offset = 0,
  }) async {
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      try {
        final response = await remoteDataSource.getStoresList(company);
        // Cache data
        await localDataSource.cacheWarehouses(
          response.message.data.map((e) => e.toJson()).toList(),
        );
        return response;
      } catch (e) {
        rethrow;
      }
    } else {
      // Offline fallback
      final cached = localDataSource.getCachedWarehouses();
      if (cached.isNotEmpty) {
        final warehouseList = cached.map((e) => Warehouse.fromJson(e)).toList();
        return StoreGetResponse(
          message: ResponseMessage(success: true, data: warehouseList),
        );
      } else {
        throw Exception("No internet connection and no cached warehouses.");
      }
    }
  }

  @override
  Future<CreateWarehouseResponse> createWarehouse(
    CreateWarehouseRequest createWarehouseRequest,
  ) async {
    return await inventoryRemoteDataSource.createWarehouse(
      createWarehouseRequest,
    );
  }

  @override
  Future<UpdateWarehouseResponse> updateWarehouse(
    UpdateWarehouseRequest updateWarehouseRequest,
  ) async {
    return await inventoryRemoteDataSource.updateWarehouse(
      updateWarehouseRequest,
    );
  }
}
