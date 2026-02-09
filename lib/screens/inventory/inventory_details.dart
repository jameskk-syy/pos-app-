import 'package:flutter/material.dart';

class InventoryItemDetailsPage extends StatelessWidget {
  const InventoryItemDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          'Inventory Item Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _inputField(
                  width: w > 900 ? w * 0.45 : w,
                  hint: 'Search items',
                  icon: Icons.search,
                ),
                _dropdownField(width: w > 900 ? w * 0.25 : w),
                _refreshButton(width: w > 900 ? w * 0.2 : w),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 48,
                      dataRowMinHeight: 46,
                      columnSpacing: 40,
                      columns: const [
                        DataColumn(label: Text('Item Code')),
                        DataColumn(label: Text('Item Name')),
                        DataColumn(label: Text('Warehouse')),
                        DataColumn(label: Text('Buying Price')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate(
                        0,
                        (index) => DataRow(
                          cells: [
                            const DataCell(Text('29483')),
                            const DataCell(Text('Bananas')),
                            const DataCell(Text('Main Warehouse')),
                            const DataCell(Text('50')),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required double width,
    required String hint,
    required IconData icon,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 0.8),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({required double width}) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        items: const [
          DropdownMenuItem(
            value: 'Main Warehouse',
            child: Text('Main Warehouse'),
          ),
          DropdownMenuItem(value: 'Store', child: Text('Store')),
        ],
        onChanged: (v) {},
        decoration: InputDecoration(
          hintText: 'Warehouse',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue.shade300, width: 0.8),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _refreshButton({required double width}) {
    return SizedBox(
      width: width,
      height: 48,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.blue.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Refresh', style: TextStyle(color: Colors.blue)),
      ),
    );
  }
}
