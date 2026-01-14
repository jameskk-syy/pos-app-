import 'package:flutter/material.dart';
import 'package:pos/domain/responses/store_response.dart';

class WarehouseDetailDialog extends StatelessWidget {
  final Warehouse warehouse;
  final VoidCallback onEdit;

  const WarehouseDetailDialog({
    super.key,
    required this.warehouse,
    required this.onEdit,
  });

  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 && 
      MediaQuery.of(context).size.width < 900;

  double _getResponsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (_isMobile(context)) return mobile;
    if (_isTablet(context)) return tablet;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : (isTablet ? 500 : 600),
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warehouse_outlined,
                    color: Colors.white,
                    size: isMobile ? 24 : 28,
                  ),
                  SizedBox(width: isMobile ? 10 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warehouse.warehouseName,
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(
                              context,
                              mobile: 18,
                              tablet: 19,
                              desktop: 20,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (warehouse.warehouseType != null)
                          Text(
                            warehouse.warehouseType!,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(
                                context,
                                mobile: 13,
                                tablet: 14,
                                desktop: 14,
                              ),
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    iconSize: isMobile ? 20 : 24,
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badges
                      if (warehouse.isDefault || 
                          warehouse.disabled == 1 || 
                          warehouse.isGroup == 1 || 
                          warehouse.isMainDepot)
                        Padding(
                          padding: EdgeInsets.only(bottom: isMobile ? 16 : 24),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (warehouse.isDefault)
                                _buildDetailBadge(
                                  context,
                                  'Default Warehouse',
                                  Colors.green,
                                  Icons.check_circle_outline,
                                  isMobile,
                                ),
                              if (warehouse.disabled == 1)
                                _buildDetailBadge(
                                  context,
                                  'Disabled',
                                  Colors.red,
                                  Icons.block,
                                  isMobile,
                                ),
                              if (warehouse.isGroup == 1)
                                _buildDetailBadge(
                                  context,
                                  'Group Warehouse',
                                  Colors.purple,
                                  Icons.group_work_outlined,
                                  isMobile,
                                ),
                              if (warehouse.isMainDepot)
                                _buildDetailBadge(
                                  context,
                                  'Main Depot',
                                  Colors.orange,
                                  Icons.home_work_outlined,
                                  isMobile,
                                ),
                            ],
                          ),
                        ),

                      // Basic Information
                      _buildDetailSection(
                        context,
                        'Basic Information',
                        [
                          _buildDetailRow(
                            context,
                            'Warehouse ID',
                            warehouse.name,
                            Icons.tag,
                            isMobile,
                          ),
                          _buildDetailRow(
                            context,
                            'Company',
                            warehouse.company,
                            Icons.business_outlined,
                            isMobile,
                          ),
                          if (warehouse.parentWarehouse != null)
                            _buildDetailRow(
                              context,
                              'Parent Warehouse',
                              warehouse.parentWarehouse!,
                              Icons.account_tree_outlined,
                              isMobile,
                            ),
                        ],
                        isMobile,
                      ),
                      SizedBox(height: isMobile ? 16 : 24),

                      // Address Information
                      if (warehouse.addressLine1 != null ||
                          warehouse.city != null ||
                          warehouse.state != null)
                        Column(
                          children: [
                            _buildDetailSection(
                              context,
                              'Address Information',
                              [
                                if (warehouse.addressLine1 != null)
                                  _buildDetailRow(
                                    context,
                                    'Address',
                                    warehouse.addressLine1!,
                                    Icons.location_on_outlined,
                                    isMobile,
                                  ),
                                if (warehouse.addressLine2 != null)
                                  _buildDetailRow(
                                    context,
                                    'Address Line 2',
                                    warehouse.addressLine2!,
                                    Icons.location_on_outlined,
                                    isMobile,
                                  ),
                                if (warehouse.city != null)
                                  _buildDetailRow(
                                    context,
                                    'City',
                                    warehouse.city!,
                                    Icons.location_city_outlined,
                                    isMobile,
                                  ),
                                if (warehouse.state != null)
                                  _buildDetailRow(
                                    context,
                                    'State/Province',
                                    warehouse.state!,
                                    Icons.map_outlined,
                                    isMobile,
                                  ),
                                if (warehouse.pin != null)
                                  _buildDetailRow(
                                    context,
                                    'PIN Code',
                                    warehouse.pin!,
                                    Icons.pin_outlined,
                                    isMobile,
                                  ),
                              ],
                              isMobile,
                            ),
                            SizedBox(height: isMobile ? 16 : 24),
                          ],
                        ),

                      // Contact Information
                      if (warehouse.phoneNo != null ||
                          warehouse.mobileNo != null ||
                          warehouse.emailId != null)
                        _buildDetailSection(
                          context,
                          'Contact Information',
                          [
                            if (warehouse.phoneNo != null)
                              _buildDetailRow(
                                context,
                                'Phone Number',
                                warehouse.phoneNo!,
                                Icons.phone_outlined,
                                isMobile,
                              ),
                            if (warehouse.mobileNo != null)
                              _buildDetailRow(
                                context,
                                'Mobile Number',
                                warehouse.mobileNo!,
                                Icons.phone_android_outlined,
                                isMobile,
                              ),
                            if (warehouse.emailId != null)
                              _buildDetailRow(
                                context,
                                'Email',
                                warehouse.emailId!,
                                Icons.email_outlined,
                                isMobile,
                              ),
                          ],
                          isMobile,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer Actions
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isMobile)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Close'),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> children,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              context,
              mobile: 15,
              tablet: 16,
              desktop: 16,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: isMobile ? 10 : 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 10 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isMobile ? 18 : 20, color: Colors.grey[600]),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(
                      context,
                      mobile: 11,
                      tablet: 12,
                      desktop: 12,
                    ),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(
                      context,
                      mobile: 13,
                      tablet: 14,
                      desktop: 14,
                    ),
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBadge(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: color),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 13,
              ),
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}