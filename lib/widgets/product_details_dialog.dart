import 'package:flutter/material.dart';
import 'package:pos/domain/responses/product_response.dart';

class ProductDetailsDialog extends StatelessWidget {
  final ProductItem product;

  const ProductDetailsDialog({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Item Code:', product.itemCode),
            _buildDetailRow('Item Name:', product.itemName),
            _buildDetailRow('Item Group:', product.itemGroup),
            _buildDetailRow('UOM:', product.stockUom),
            _buildDetailRow('Price:', 'KES ${product.standardRate}'),
            _buildDetailRow(
              'Status:',
              product.disabled == 0 ? 'Enabled' : 'Disabled',
              statusColor: product.disabled == 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: statusColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}