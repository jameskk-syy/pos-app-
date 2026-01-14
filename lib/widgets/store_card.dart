import 'package:flutter/material.dart';
import 'package:pos/domain/responses/store_response.dart';

class StoreCardAssignment extends StatelessWidget {
  final Warehouse store;
  final bool isAssigned;
  final VoidCallback onAssignStaff;
  final bool isTablet;

  const StoreCardAssignment({
    super.key,
    required this.store,
    required this.isAssigned,
    required this.onAssignStaff,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onAssignStaff,
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.store,
                    size: isTablet ? 40 : 32,
                    color: isAssigned ? Colors.green : Colors.blue,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAssigned ? Colors.green[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAssigned ? Colors.green : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    // child: Text(
                    //   isAssigned ? 'Assigned' : 'Not Assigned',
                    //   style: TextStyle(
                    //     fontSize: isTablet ? 14 : 12,
                    //     fontWeight: FontWeight.w600,
                    //     color: isAssigned
                    //         ? Colors.green[800]
                    //         : Colors.grey[700],
                    //   ),
                    // ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                store.warehouseName,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                store.addressLine1 ?? 'No location specified',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onAssignStaff,
                icon: Icon(
                  isAssigned ? Icons.edit : Icons.person_add,
                  size: isTablet ? 20 : 18,
                ),
                label: Text(
                  isAssigned ? 'Change Staff' : 'Assign Staff',
                  style: TextStyle(fontSize: isTablet ? 15 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(isTablet ? 48 : 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
