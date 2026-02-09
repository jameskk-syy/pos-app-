import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/warehouse_cubit/warehouse_cubit.dart';
import 'package:pos/widgets/inventory/warehouse_dropdown.dart';

class WarehouseSelector extends StatelessWidget {
  const WarehouseSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarehouseCubit, WarehouseState>(
      builder: (context, state) {
        String displayText = 'Select Warehouse';
        Warehouse? selectedWarehouse;

        if (state is WarehouseLoaded) {
          if (state.warehouse != null) {
            displayText = state.warehouse!.warehouseName;
            selectedWarehouse = state.warehouse;
          } else {
            displayText = 'All Warehouses';
            selectedWarehouse = null;
          }
        }

        return InkWell(
          onTap: () {
            _showWarehouseSelectionSheet(context, selectedWarehouse);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.store, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWarehouseSelectionSheet(
    BuildContext context,
    Warehouse? currentSelection,
  ) {
    // Current list from StoreBloc in case we want to pass current list,
    // but the bottom sheet fetches it anyway or uses passed list.
    // The bottom sheet defined in warehouse_dropdown.dart takes a list.
    // We should get the list from StoreBloc first or let the sheet handle it.
    // Looking at warehouse_dropdown.dart, it takes `warehouses` as a required parameter.

    final storeState = context.read<StoreBloc>().state;
    List<Warehouse> warehouses = [];
    if (storeState is StoreStateSuccess) {
      warehouses = storeState.storeGetResponse.message.data;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WarehouseSelectionBottomSheet(
        selectedWarehouse: currentSelection,
        warehouses: warehouses,
        onWarehouseSelected: (warehouse) {
          context.read<WarehouseCubit>().selectWarehouse(warehouse);
        },
      ),
    );
  }
}
