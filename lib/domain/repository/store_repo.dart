import 'package:pos/domain/requests/inventory/create_warehouse.dart';
import 'package:pos/domain/requests/inventory/update_warehouse.dart';
import 'package:pos/domain/responses/inventory/create_warehouse.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/inventory/update_warehouse_response.dart';

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
