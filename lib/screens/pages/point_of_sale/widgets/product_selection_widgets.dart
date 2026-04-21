import 'package:flutter/material.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/domain/responses/sales/store_response.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBarcodeScannerPressed;
  final VoidCallback onFilterPressed;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onBarcodeScannerPressed,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                suffixIcon: IconButton(
                  icon: Icon(Icons.qr_code_scanner, size: 20, color: Colors.grey.shade600),
                  onPressed: onBarcodeScannerPressed,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
              onPressed: onFilterPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerSelectionCard extends StatelessWidget {
  final Customer? selectedCustomer;
  final VoidCallback onTap;

  const CustomerSelectionCard({
    super.key,
    this.selectedCustomer,
    required this.onTap,
  });

  String _getFirstName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length <= 2) return fullName;
    return nameParts.take(2).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Customer:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getFirstName(selectedCustomer?.customerName ?? 'Walk-in Customer'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WarehouseSelectionCard extends StatelessWidget {
  final Warehouse? selectedWarehouse;
  final bool isLoading;
  final VoidCallback onTap;

  const WarehouseSelectionCard({
    super.key,
    this.selectedWarehouse,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Warehouse*', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedWarehouse?.warehouseName ?? 'Select Warehouse',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey.shade600))
                else
                  Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
