import 'package:flutter/material.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/domain/responses/users_list.dart';

class AssignStaffBottomSheet extends StatefulWidget {
  final Warehouse store;
  final List<StaffUser> staffList;
  final bool isLoading;
  final String? errorMessage;
  final Function(List<StaffUser>) onAssign;
  final bool isTablet;

  const AssignStaffBottomSheet({
    super.key,
    required this.store,
    required this.staffList,
    required this.onAssign,
    this.isLoading = false,
    this.errorMessage,
    this.isTablet = false,
  });

  @override
  State<AssignStaffBottomSheet> createState() => _AssignStaffBottomSheetState();
}

class _AssignStaffBottomSheetState extends State<AssignStaffBottomSheet> {
  final Set<String> _selectedStaffIds = {};
  String _searchQuery = '';

  List<StaffUser> get _filteredStaff {
    if (_searchQuery.isEmpty) return widget.staffList;
    return widget.staffList.where((staff) {
      final name = (staff.fullName.isNotEmpty ? staff.fullName : staff.name)
          .toLowerCase();
      final email = staff.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  void _toggleStaff(StaffUser staff) {
    setState(() {
      if (_selectedStaffIds.contains(staff.name)) {
        _selectedStaffIds.remove(staff.name);
      } else {
        _selectedStaffIds.add(staff.name);
      }
    });
  }

  void _handleAssign() {
    final selectedStaff = widget.staffList
        .where((staff) => _selectedStaffIds.contains(staff.name))
        .toList();
    widget.onAssign(selectedStaff);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isTablet
            ? BorderRadius.circular(16)
            : const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (widget.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (widget.errorMessage != null)
            Expanded(
              child: Center(
                child: Text(
                  widget.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search staff...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: _filteredStaff.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final staff = _filteredStaff[index];
                        final isSelected = _selectedStaffIds.contains(
                          staff.name,
                        );
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withAlpha(10)
                                : Colors.grey[100],
                            child: Text(
                              (staff.fullName.isNotEmpty
                                      ? staff.fullName
                                      : staff.name)
                                  .characters
                                  .first
                                  .toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            staff.fullName.isNotEmpty
                                ? staff.fullName
                                : staff.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            staff.email,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Transform.scale(
                            scale: 1.1,
                            child: Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              value: isSelected,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (_) => _toggleStaff(staff),
                            ),
                          ),
                          onTap: () => _toggleStaff(staff),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Staff',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'to ${widget.store.warehouseName}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _selectedStaffIds.isEmpty ? null : _handleAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text(
              'Assign ${_selectedStaffIds.length} Staff',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
