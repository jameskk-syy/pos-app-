import 'package:flutter/material.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/widgets/credit_management_modal.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final Function(Customer) onEdit;
  final Function(String)? onMenuSelected;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withAlpha(25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (customer.customerGroup != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: customer.customerGroup == 'VIP'
                                    ? Colors.amber.withAlpha(25)
                                    : Colors.blue.withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: customer.customerGroup == 'VIP'
                                      ? Colors.amber
                                      : Colors.blue,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                customer.customerGroup!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: customer.customerGroup == 'VIP'
                                      ? Colors.amber[700]
                                      : Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: customer.isActive
                                  ? Colors.green.withAlpha(25)
                                  : Colors.red.withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: customer.isActive
                                    ? Colors.green
                                    : Colors.red,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              customer.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: customer.isActive
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildCardActions(context),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Customer details
            _buildDetailRow(
              Icons.badge_outlined,
              'ID',
              customer.name,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.business_outlined,
              'Type',
              customer.customerType,
            ),
            const SizedBox(height: 8),
            if (customer.mobileNo != null)
              _buildDetailRow(
                Icons.phone_outlined,
                'Mobile',
                customer.mobileNo!,
              ),
            if (customer.mobileNo != null) const SizedBox(height: 8),
            if (customer.territory != null)
              _buildDetailRow(
                Icons.location_on_outlined,
                'Territory',
                customer.territory!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

Widget _buildCardActions(BuildContext context) {
  return PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert, size: 20),
    padding: EdgeInsets.zero,
    color: Colors.white,
    itemBuilder: (context) => [
      const PopupMenuItem<String>(
        value: 'view',
        child: Row(
          children: [
            Icon(Icons.visibility_outlined, size: 18),
            SizedBox(width: 8),
            Text('View Details'),
          ],
        ),
      ),
      const PopupMenuItem<String>(
        value: 'credits',
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 18, color: Colors.black),
            SizedBox(width: 8),
            Text('Manage Credits', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      
      // New loyalty menu items
      const PopupMenuItem<String>(
        value: 'attach_loyalty',
        child: Row(
          children: [
            Icon(Icons.loyalty_outlined, size: 18, color: Colors.black),
            SizedBox(width: 8),
            Text('Attach Loyalty', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      const PopupMenuItem<String>(
        value: 'redeem_points',
        child: Row(
          children: [
            Icon(Icons.currency_exchange_outlined, size: 18, color: Colors.black),
            SizedBox(width: 8),
            Text('Redeem Points', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      const PopupMenuItem<String>(
        value: 'view_point_history',
        child: Row(
          children: [
            Icon(Icons.history_outlined, size: 18, color: Colors.black),
            SizedBox(width: 8),
            Text('View Point History', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      const PopupMenuDivider(),
    
      const PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit_outlined, size: 18),
            SizedBox(width: 8),
            Text('Edit'),
          ],
        ),
      ),
      // const PopupMenuItem<String>(
      //   value: 'delete',
      //   child: Row(
      //     children: [
      //       Icon(Icons.delete_outline, size: 18, color: Colors.red),
      //       SizedBox(width: 8),
      //       Text('Delete', style: TextStyle(color: Colors.red)),
      //     ],
      //   ),
      // ),
    ],
    onSelected: (value) {
      // Handle menu selection
      switch (value) {
        case 'view':
          _showDetailsDialog(context);
          break;
        case 'credits':
          _showCreditManagementModal(context);
          break;
        case 'attach_loyalty':
        case 'redeem_points':
        case 'view_point_history':
          if (onMenuSelected != null) {
            onMenuSelected!(value);
          }
          break;
        case 'edit':
          onEdit(customer);
          break;
        case 'delete':
          _showDeleteDialog(context);
          break;
      }
    },
  );
}
  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogRow('Name', customer.displayName),
              _buildDialogRow('ID', customer.name),
              _buildDialogRow('Type', customer.customerType),
              if (customer.customerGroup != null)
                _buildDialogRow('Group', customer.customerGroup!),
              if (customer.territory != null)
                _buildDialogRow('Territory', customer.territory!),
              if (customer.taxId != null)
                _buildDialogRow('Tax ID', customer.taxId!),
              if (customer.mobileNo != null)
                _buildDialogRow('Mobile', customer.mobileNo!),
              if (customer.emailId != null)
                _buildDialogRow('Email', customer.emailId!),
              if (customer.defaultCurrency != null)
                _buildDialogRow('Currency', customer.defaultCurrency!),
              if (customer.defaultPriceList != null)
                _buildDialogRow('Price List', customer.defaultPriceList!),
              _buildDialogRow(
                'Status',
                customer.isActive ? 'Active' : 'Inactive',
              ),
              _buildDialogRow(
                'Credit Limit',
                customer.creditLimit.toStringAsFixed(2),
              ),
              _buildDialogRow(
                'Outstanding',
                customer.outstandingAmount.toStringAsFixed(2),
              ),
              _buildDialogRow(
                'Available Credit',
                customer.availableCredit.toStringAsFixed(2),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${customer.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customer deleted successfully'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreditManagementModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreditManagementModal(customer: customer),
    );
  }
}