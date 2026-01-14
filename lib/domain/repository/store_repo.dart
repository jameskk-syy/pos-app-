import 'package:pos/domain/requests/create_warehouse.dart';
import 'package:pos/domain/requests/update_warehouse.dart';
import 'package:pos/domain/responses/create_warehouse.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/domain/responses/update_warehouse_response.dart';

abstract class StoreRepo {
  Future<StoreGetResponse> getAllStores(
    String company, {
    int limit = 20,
    int offset = 0,
  });

  Future<CreateWarehouseResponse> createWarehouse(
    CreateWarehouseRequest createWarehouseRequest,
  );
  Future<UpdateWarehouseResponse> updateWarehouse(
    UpdateWarehouseRequest updateWarehouseRequest,
  );
}
