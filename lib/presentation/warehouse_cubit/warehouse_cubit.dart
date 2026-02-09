import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

part 'warehouse_state.dart';

class WarehouseCubit extends Cubit<WarehouseState> {
  WarehouseCubit() : super(WarehouseInitial());

  Future<void> loadSavedWarehouse() async {
    try {
      emit(WarehouseLoading());
      final storage = getIt<StorageService>();
      final warehouseJson = await storage.getString('selected_warehouse');

      if (warehouseJson != null) {
        final warehouse = Warehouse.fromJson(jsonDecode(warehouseJson));
        emit(WarehouseLoaded(warehouse));
      } else {
        // null implies "All Warehouses"
        emit(WarehouseLoaded(null));
      }
    } catch (e) {
      emit(WarehouseError('Failed to load warehouse: $e'));
    }
  }

  Future<void> selectWarehouse(Warehouse? warehouse) async {
    try {
      emit(WarehouseLoading());
      final storage = getIt<StorageService>();
      if (warehouse != null) {
        await storage.setString(
          'selected_warehouse',
          jsonEncode(warehouse.toJson()),
        );
      } else {
        await storage.remove('selected_warehouse');
      }
      emit(WarehouseLoaded(warehouse));
    } catch (e) {
      emit(WarehouseError('Failed to save warehouse: $e'));
    }
  }

  Future<void> selectWarehouseByName(
    String name,
    List<Warehouse> warehouses,
  ) async {
    try {
      final warehouse = warehouses.firstWhere(
        (w) => w.name == name || w.warehouseName == name,
        orElse: () => warehouses.firstWhere(
          (w) => w.isDefault,
          orElse: () => warehouses[0],
        ),
      );
      await selectWarehouse(warehouse);
    } catch (e) {
      debugPrint('Error selecting default warehouse: $e');
    }
  }
}
