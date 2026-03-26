import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/top_selling_item_model.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';

class DashboardSalesOverviewWidgets {
  static Widget buildTopSellingItems(BuildContext context, List<TopSellingItem> items) {
    return _buildSectionCard(
      title: "Top Selling Items",
      subtitle: "Best performers for the selected period",
      iconColor: Colors.blue,
          child: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No top selling items'),
              ),
            )
          : DataTable(
                columnSpacing: 12,
                horizontalMargin: 12,
                headingRowHeight: 40,
                dataRowMinHeight: 30,
                dataRowMaxHeight: 45,
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                columns: const [
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'ITEM',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'QTY',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'AMOUNT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    numeric: true,
                  ),
                ],
                rows: items.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          item.itemName ?? item.itemCode ?? '-',
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          item.totalQty?.toStringAsFixed(0) ?? '0',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      DataCell(
                        Text(
                          _formatCurrency(item.totalRevenue ?? 0),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
    );
  }

  static Widget buildLatestOrders(BuildContext context, List<InvoiceListItem> orders) {
    return _buildSectionCard(
      title: "Latest Orders",
      subtitle: "Most recent orders",
      iconColor: Colors.purple,
      child: orders.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recent orders'),
              ),
            )
          : DataTable(
              columnSpacing: 10,
              horizontalMargin: 12,
              headingRowHeight: 40,
              dataRowMinHeight: 30,
              dataRowMaxHeight: 45,
              headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
              columns: const [
                DataColumn(
                  label: Text(
                    'No #',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'CUSTOMER',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'AMOUNT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  numeric: true,
                ),
              ],
              rows: orders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        order.name,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        order.customer,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        'KSh ${_formatCurrency(order.grandTotal)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  static Widget buildRecentPurchases(BuildContext context, List<PurchaseInvoiceData> purchases) {
    return _buildSectionCard(
      title: "Recent Purchases",
      subtitle: "Most recent supplies",
      iconColor: Colors.teal,
      child: purchases.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recent purchases'),
              ),
            )
          : DataTable(
              columnSpacing: 12,
              horizontalMargin: 12,
              headingRowHeight: 40,
              dataRowMinHeight: 30,
              dataRowMaxHeight: 45,
              headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'SUPPLIER',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'AMOUNT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  numeric: true,
                ),
              ],
              rows: purchases.map((purchase) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        purchase.supplierName,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        'KSh ${_formatCurrency(purchase.grandTotal)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  static Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static String _formatCurrency(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }
}
