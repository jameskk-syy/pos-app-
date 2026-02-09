import 'package:flutter/material.dart';
import 'package:pos/domain/responses/users/users_list.dart';

class ViewStaffDetailsDialog extends StatefulWidget {
  final StaffUser staff;

  const ViewStaffDetailsDialog({super.key, required this.staff});

  @override
  State<ViewStaffDetailsDialog> createState() => ViewStaffDetailsDialogState();
}

class ViewStaffDetailsDialogState extends State<ViewStaffDetailsDialog> {
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    if (widget.staff.roles.isNotEmpty) {
      selectedRole = widget.staff.roles.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Colors.blue, width: 0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const CircleAvatar(radius: 32),
            const SizedBox(height: 8),
            Text(
              widget.staff.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.staff.email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _detailRowWithDropdown(),
            _detailRow(
              'Status',
              widget.staff.enabled == 1 ? 'Active' : 'Pending',
            ),
            _detailRow('Company', widget.staff.customCompany),
            _detailRow('Industry', widget.staff.industry),
          ],
        ),
      ),
    );
  }

  Widget _detailRowWithDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text('Role:', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: widget.staff.roles.isEmpty
                ? const Text('No Role')
                : DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    underline: Container(),
                    items: widget.staff.roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newRole) {
                      setState(() {
                        selectedRole = newRole;
                      });
                    },
                    hint: const Text('Select Role'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
